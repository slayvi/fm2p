from flask import Flask, render_template, request, send_from_directory, url_for, redirect, session, make_response
import os
from werkzeug.utils import secure_filename
import boto3
from dotenv import load_dotenv
import logging
import tensorflow as tf 
from tensorflow.keras.preprocessing import image
import numpy as np
from datetime import datetime

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY')

custom_logger = logging.getLogger('custom_app')
custom_logger.setLevel(logging.INFO)  # Set the logging level for custom logs
file_handler = logging.FileHandler(f"logs/{datetime.now().strftime('%Y-%m-%d')}.log")
file_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
custom_logger.addHandler(file_handler)



############################################################################################################################################
################################################# L O G I N    A N D   I N D E X ###########################################################
############################################################################################################################################


def get_user_credentials():
    users_str = os.getenv('FLASK_USERS', '')
    users = [user.split(':') for user in users_str.split(',')]
    return {username: password for username, password in users}


@app.route('/')
#@auth.login_required
def index():
    if 'username' in session:
        return render_template('index.html')    
    return "You are not logged in <br><a href = '/login'>" + "click here to log in</a>"



@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        entered_username = request.form['username']
        entered_password = request.form['password']  # Add a password field to the form

        user_credentials = get_user_credentials()
        if entered_username in user_credentials and entered_password == user_credentials[entered_username]:
            session['username'] = entered_username
            custom_logger.info(f"User '{entered_username}' logged in successfully.")
            return redirect(url_for('index'))
        else:
            custom_logger.info(f"Failed login attempt for user '{entered_username}'.")
            return "Invalid username or password. <br><a href='/login'>Try again</a>"

    return '''
    <form action="/login" method="POST">
        <p><input type="text" name="username" placeholder="Username" /></p>
        <p><input type="password" name="password" placeholder="Password" /></p>
        <p><input type="submit" value="Login" /></p>
    </form>
    '''


@app.route('/logout')
def logout():
    session.clear()  # Clear the entire session

    # Send a 401 response to ensure logging out succeeds: 
    response = make_response(redirect(url_for('index')))
    response.headers['Cache-Control'] = 'no-store, must-revalidate'
    response.status_code = 401

    return redirect(url_for('index'))




############################################################################################################################################
################################################### U P L O A D   A N D  S A F E ###########################################################
############################################################################################################################################


# Get access:
AWS_ACCESS_KEY = os.getenv('AWS_ACCESS_KEY')
AWS_SECRET_KEY = os.getenv('AWS_SECRET_KEY')
AWS_BUCKET_NAME = "bucketfm2p"


app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['ALLOWED_EXTENSIONS'] = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']


def upload_to_s3(local_file_path, s3_file_name):
    s3 = boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY, aws_secret_access_key=AWS_SECRET_KEY)

    try:        
        s3.upload_file(local_file_path, AWS_BUCKET_NAME, s3_file_name)
        return True
    except FileNotFoundError:
        return False



@app.route('/upload')
#@auth.login_required
def upload():

    current_user = session.get('username', 'Unknown')  # Get the current user from the session

    user_credentials = get_user_credentials()    
    if 'username' in session and session['username'] == user_credentials[current_user]:
        # User is logged in, proceed with upload
        response = make_response(render_template('upload.html'))
        response.headers['Cache-Control'] = 'no-store'
        return response
    else:
        # User is not logged in, redirect to login page
        return redirect(url_for('login'))


@app.route('/uploaddone', methods=['POST'])
def uploaddone():
    current_user = session.get('username', 'Unknown')  # Get the current user from the session

    # Check if the post request has the file part
    if 'files[]' not in request.files:
        return 'No file part'

    uploaded_files = request.files.getlist('files[]')

    for file in uploaded_files:
        if file.filename == '':
            return 'No selected file'

        # Check if the file is allowed
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)

            # Save the file locally
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

            # Upload the file to S3
            if upload_to_s3(os.path.join(app.config['UPLOAD_FOLDER'], filename), filename):
                custom_logger.info(f"User '{current_user}' uploaded file '{filename}' at {datetime.now()}")

        else:
            custom_logger.info(f"User '{current_user}' failed to upload file (wrong type) '{filename}' at {datetime.now()}")
            return f"File type not allowed for file '{filename}'. <a href='/'>Back</a>"

    return "Files uploaded and sent to S3 successfully. <a href='/'>Back</a>"


############################################################################################################################################
########################################## D O W N L O A D   A N D   C L A S S I F Y #######################################################
############################################################################################################################################

DOWNLOAD_FOLDER = "downloads"
app.config['DOWNLOAD_FOLDER'] = DOWNLOAD_FOLDER
app.config['STATIC_FOLDER'] = 'static'

model = tf.keras.models.load_model('model_final')

class_names = ["T-shirt/top", "Trouser", "Pullover", "Dress", "Coat", "Sandal", "Shirt", "Sneaker", "Bag", "Ankle boot"]

def classify_image(file_path):
    img = image.load_img(file_path, target_size=(28, 28), color_mode="grayscale")
    img_array = image.img_to_array(img)
    img_array = img_array / 255.0
    print(img_array)
    img_array = np.expand_dims(img_array, axis=0)
    pred = model.predict(img_array)
    return pred[0]


def predict_images_in_folder(folder_path):
    results = []
    for filename in os.listdir(folder_path):
        if filename.endswith(('.png', '.jpg', '.jpeg', '.gif')):
            file_path = os.path.join(folder_path, filename)
            predictions = classify_image(file_path)

            result_perc = np.round(predictions, 2)
            product = class_names[np.argmax(predictions)]

            results.append({'filename': filename, 'product': product, 'resultperc': result_perc})

    return results

@app.route('/classification')
def classification():
    current_user = session.get('username', 'Unknown')  # Get the current user from the session

    user_credentials = get_user_credentials()    
    if 'username' in session and session['username'] == user_credentials[current_user]:

        folder_path = app.config['DOWNLOAD_FOLDER']
        results = predict_images_in_folder(folder_path)
        print(results)  # Print results to console for debugging
        
        custom_logger.info(f"User '{current_user}' watched classified products.")
        custom_logger.info(f"Results: '{results}'")

        return render_template('classification.html', foldername='Batch', results=results)    
    else:
        # User is not logged in, redirect to login page
        return redirect(url_for('login'))


# Serve static files
@app.route('/static/downloads/<filename>')
def serve_static(filename):
    return send_from_directory(app.config['DOWNLOAD_FOLDER'], filename)
    

############################################################################################################################################
################################################################# M A I N ##################################################################
############################################################################################################################################

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
