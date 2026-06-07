# syntax=docker/dockerfile:1

# ---- build stage ----
# Gleam ツールチェーン入りのイメージで erlang-shipment を作る
FROM ghcr.io/gleam-lang/gleam:v1.17.0-erlang-alpine AS build

COPY . /build
WORKDIR /build

# 自己完結した Erlang リリースを build/erlang-shipment に出力する
RUN gleam export erlang-shipment

# ---- runtime stage ----
# 実行に必要なのは Erlang ランタイムだけ。イメージを小さく保つ
FROM erlang:28-alpine

# shipment の成果物だけをコピーする
COPY --from=build /build/build/erlang-shipment /app
WORKDIR /app

# Wisp/mist は 8000 番で待ち受ける（backend.gleam でハードコード）
EXPOSE 8000

# DATABASE_URL は実行時に注入する（未設定だと起動時 panic）
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
