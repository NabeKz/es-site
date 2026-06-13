resource "aws_lb" "backend" {
  name               = "backend-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  # 無効化するまで削除が失敗するようになる（本番向け。学習環境では destroy の邪魔になるので無効）
  # enable_deletion_protection = true

}

resource "aws_lb_target_group" "backend" {
  name        = "backend-lb-tg-tf"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
