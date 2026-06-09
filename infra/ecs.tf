resource "aws_ecs_cluster" "main" {
  name = "ec-site"
}

resource "aws_ecs_task_definition" "service" {
  family = "ec-site-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_execution.arn
  
  container_definitions = jsonencode([
    {
      name = "backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 8000 }
      ]
      environment = [
        { name = "DATABASE_URL", value = var.database_url } 
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group =  aws_cloudwatch_log_group.backend.name
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
