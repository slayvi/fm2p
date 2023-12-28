# Creating Ressource Application Load Balancer:
resource "aws_lb" "default" {
  name            = var.alb_name
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb.id]
}


# Creating Target Group for ALB:
resource "aws_lb_target_group" "lb_target_group" {
  name        = "${var.alb_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"
}


# Defining Listener for ALB and forward incoming HTTP traffic:
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }
}