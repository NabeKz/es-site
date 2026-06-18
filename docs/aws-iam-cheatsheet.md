# AWS IAM 早見表（ECS Fargate デプロイ）

このプロジェクト（ECS Fargate + ECR + SSM Parameter Store + CloudWatch + Neon）の文脈に即した IAM ロール／ポリシーの早見表。

## 大原則：どのロールに付けるか

| タイミング | ロール | 主体 |
|---|---|---|
| コンテナの**起動準備**（pull・secrets 解決・ログ出力） | **Execution Role** | ECS / Fargate エージェント（インフラ側） |
| アプリの**実行中**に AWS API を叩く | **Task Role** | コンテナ内のアプリ |

迷ったら「これは**起動するため**の作業か、**起動した後**アプリがやる作業か」で振り分ける。

## やりたいこと → 必要なロールと権限

| やりたいこと | ロール | 必要な権限（managed policy / Action） |
|---|---|---|
| ECR からイメージ pull | Execution | `AmazonECSTaskExecutionRolePolicy`（`ecr:GetAuthorizationToken`, `ecr:BatchGetImage`, `ecr:GetDownloadUrlForLayer`） |
| CloudWatch へログ書き込み | Execution | 同上（`logs:CreateLogStream`, `logs:PutLogEvents`）※ロググループも作るなら `logs:CreateLogGroup` |
| SSM Parameter を secrets で注入（←現状） | Execution | `ssm:GetParameters`（AWS マネージドキー `aws/ssm` なので `kms:Decrypt` **不要**） |
| Secrets Manager を secrets で注入 | Execution | `secretsmanager:GetSecretValue`（+ カスタム KMS なら `kms:Decrypt`） |
| アプリが S3 を読み書き | **Task** | `s3:GetObject` / `s3:PutObject`（特定バケット ARN に絞る） |
| アプリが DynamoDB アクセス | **Task** | `dynamodb:GetItem` / `PutItem` 等 |
| アプリが SQS 送信 | **Task** | `sqs:SendMessage` |
| `aws ecs execute-command`（コンテナに shell） | **Task** | `ssmmessages:CreateControlChannel` 等 4 つ |

> SSM「**注入**」は Execution（起動準備）。アプリが**実行中に自分で** SSM を叩くなら Task。同じ SSM でも責務で分かれる。

## 信頼ポリシー（assume_role）の Principal

「どのロールか」ではなく「**誰がこのロールを引き受けるか**」を決める部分。

| ロールの用途 | Principal Service |
|---|---|
| ECS の Execution / Task role（どちらも） | `ecs-tasks.amazonaws.com` |
| EC2 インスタンスプロファイル | `ec2.amazonaws.com` |
| Lambda 実行ロール | `lambda.amazonaws.com` |
| CodeBuild | `codebuild.amazonaws.com` |

> ECS は execution も task も `ecs-tasks`。`ec2.amazonaws.com` と書きがちなので注意。

## このプロジェクトの現状

| ロール | 付いてる権限 | 評価 |
|---|---|---|
| `ecs_execution` | `AmazonECSTaskExecutionRolePolicy` + `ssm:GetParameters` | pull・log・secrets 注入に必要十分 |
| `ecs_task` | なし（空） | アプリは Neon だけで AWS API を叩かないので正しい |

## ドキュメントの探し方

| 知りたいこと | 見る場所 |
|---|---|
| サービスを動かすのにどんなロールが要るか | 各サービスの Developer Guide → **Security → IAM roles** セクション |
| 特定の操作にどの Action が要るか（逆引き） | **Service Authorization Reference** |
| マネージドポリシーの中身 | **AWS Managed Policy Reference** |

使い分け：
- **「どのロールに付けるか」を知りたい** → そのサービスの Developer Guide の IAM セクション
- **「どの Action か」を知りたい** → Service Authorization Reference

## 公式 URL

### ECS の IAM ロール
- IAM roles for Amazon ECS（全体像）: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-ecs-iam-role-overview.html
- Task execution IAM role: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
- Task IAM role: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
- Best practices for IAM roles in ECS: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-iam-roles.html
- Secrets を secrets で注入: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html

### 横断リファレンス（逆引き）
- Service Authorization Reference（Action / Resource / Condition の辞書）: https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html
- AWS Managed Policy Reference: https://docs.aws.amazon.com/aws-managed-policy/latest/reference/
