import tensorflow as tf
import os
import numpy as np
from tensorflow.keras.preprocessing import image
import logging 
from datetime import datetime 

# Load model
model = tf.keras.models.load_model('/app/model_final')
class_names = ["T-shirt/top", "Trouser", "Pullover", "Dress", "Coat", "Sandal", "Shirt", "Sneaker", "Bag", "Ankle boot"]

logging.basicConfig(filename=f"/app/logs/results-{datetime.now().strftime('%Y-%m-%d')}.log", level=logging.INFO)
logging.info(f"Predictions of Day: {datetime.now().strftime('%Y-%m-%d')}")

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

results = predict_images_in_folder("/app/downloads")
logging.info(f"Results: '{results}'")
logging.info("_ _ _ _ _ _ _ _ _ _ _ _ _ _")
