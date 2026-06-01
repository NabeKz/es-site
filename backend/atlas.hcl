env "neon" {
  src     = "file://db/schema.hcl"
  url     = getenv("DATABASE_URL")
  dev     = getenv("DEV_DATABASE_URL")
  schemas = ["public", "app"]
}

env "local" {
  src     = "file://db/schema.hcl"
  url     = "postgresql://postgres:dev@localhost:5432/gym_app?sslmode=disable"
  dev     = "docker://postgres/17/dev"
  schemas = ["public", "app"]
}
