# =============================================================
# セキュリティグループ（チャンク A）
#
# 作るもの:
#   - ALB 用 SG  : インターネットから 80 を受ける
#   - タスク用 SG: ALB からだけ 8000 を受ける
# ルールは SG 本体とは別リソースに分けて書く（現行のベストプラクティス）
# =============================================================

# -------------------------------------------------------------
# 1) ALB 用のセキュリティグループ（箱だけ。中身のルールは下で定義）
# -------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "ec-site-alb"
  description = "ALB: allow HTTP from internet"
  vpc_id      = data.aws_vpc.default.id # デフォルト VPC に所属させる
}

# -------------------------------------------------------------
# 2) タスク（Fargate）用のセキュリティグループ（箱だけ）
# -------------------------------------------------------------
resource "aws_security_group" "task" {
  name        = "ec-site-task"
  description = "Fargate task: allow 8000 from ALB only"
  vpc_id      = data.aws_vpc.default.id
}

# -------------------------------------------------------------
# 3) ALB の受信ルール: 80/tcp をインターネット全体から
# -------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id # どの SG に付けるか
  cidr_ipv4         = "0.0.0.0/0"               # 全 IP から（公開窓口なので）
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# -------------------------------------------------------------
# 4) タスクの受信ルール: 8000/tcp を「ALB の SG から」だけ
#    ここが肝。CIDR ではなく SG を参照することで、
#    ALB を経由したトラフィックしかタスクに届かなくなる。
# -------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "task_from_alb" {
  security_group_id            = aws_security_group.task.id
  referenced_security_group_id = aws_security_group.alb.id # ← ALB SG を参照
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

# -------------------------------------------------------------
# 5) 送信ルール（egress）: 両方とも全許可
#    ALB → タスク転送、タスク → ECR pull / Neon DB 接続に必要。
#    全許可なので ip_protocol = "-1" だけ書けばよい（ポート指定不要）。
# -------------------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "task_all" {
  security_group_id = aws_security_group.task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
