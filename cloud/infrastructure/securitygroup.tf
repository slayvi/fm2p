# Creating Security Group for ALB:
resource "aws_security_group" "alb" {
  name   = "${var.alb_name}-securtiy-group"
  vpc_id = aws_vpc.default.id

  # Inbound rules: Ingress TCP from customer IP only:
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.ip_customer
  }

  # Outbound rules: Egress to Container port:          
  egress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create Security Group for ECS Task:
resource "aws_security_group" "task" {
  name   = var.cluster_name
  vpc_id = aws_vpc.default.id

  # Inbound rules: Ingress only from Container Port and ALB security group:
  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.alb.id]
  }

  # Outbound rules: Egress All:                
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}