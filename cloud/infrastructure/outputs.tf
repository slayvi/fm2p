# Prints the URL to the command line:
output "load_balancer_url" {
  value = "The Application can be accessed at:\n ${aws_lb.default.dns_name}"
}