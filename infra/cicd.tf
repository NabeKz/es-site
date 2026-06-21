# GitHub Actions から AWS へ OIDC で認証するための構成。
# 長期アクセスキーを GitHub に置かず、一時クレデンシャルを引き受ける。

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
}

resource "aws_iam_role" "github_actions" {
  name = "ec-site-github-actions"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # environment を付けたジョブの OIDC sub は environment スコープになる。
            # main ブランチ縛りより強く、production 環境を通った実行のみに限定する。
            "token.actions.githubusercontent.com:sub" = "repo:NabeKz/es-site:environment:production"
          }
        }
      }
    ]
  })
}

# ECR への push に必要な最小権限。
# GetAuthorizationToken はリソースレベル権限を持てないため Resource = "*"。
resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "ecr-push"
  role = aws_iam_role.github_actions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "EcrPushPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          # buildx の cache-from がキャッシュイメージ（:buildcache）を読むのに必要。
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]
        Resource = aws_ecr_repository.backend.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_ecs_deploy" {
  name = "ecs-deploy"
  role = aws_iam_role.github_actions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcsDeploy"
        Effect   = "Allow"
        Action   = ["ecs:UpdateService", "ecs:DescribeServices"]
        Resource = aws_ecs_service.backend.id
      }
    ]
  })
}
