resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/ec-site-backend"
  retention_in_days = 7
}
