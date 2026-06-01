# バリデーション方針

## Unvalidated → Validated の型変換

command 層はバリデーション済みの値のみ受け付ける。`opaque` 型で構築を制限し、型システムで保証する。

```gleam
// command.gleam
pub opaque type ValidProductInput {
  ValidProductInput(name: String, price: Int, stock: Int, description: String)
}

pub fn validate(input: CreateProductInput) -> Result(ValidProductInput, List(String))

pub fn create(save: SaveProduct) -> fn(ValidProductInput) -> Result(Product, String)
```

`ValidProductInput` は `validate` を通らないと生成できないため、`create` に未検証の値が渡ることをコンパイル時に防げる。

## 各層の責務

| 層 | 責務 |
|---|---|
| `generated/requests.gleam` の `parse_*` | JSON decode + 型レベルの基本検証（minLength・minimum 等） |
| `command.validate` | ドメインルールの検証 |
| `command.create` | `Valid*Input` のみ受け付けて実行 |

## ハンドラーのフロー

```gleam
parse_create_product_input(raw)  // decode + 基本検証
  → command.validate(input)      // ドメイン検証
  → command.create(save)(valid)  // 実行
```

## 全エラーを収集して返す

`validate` は最初のエラーで止まらず、全エラーを収集して返す。`use <- result.try` は使わない。

```gleam
pub fn validate(input: CreateProductInput) -> Result(ValidProductInput, List(String)) {
  let errors =
    []
    |> check_price_limit(input.price, 100_000)
    |> check_name_forbidden(input.name)
  case errors {
    [] -> Ok(ValidProductInput(name: input.name, price: input.price, ...))
    _ -> Error(errors)
  }
}

fn check_price_limit(errors: List(String), price: Int, max: Int) -> List(String) {
  case price <= max {
    True -> errors
    False -> ["price must be at most " <> int.to_string(max), ..errors]
  }
}
```

`create` 内でアダプターを呼ぶ処理（在庫チェック等）は順番に依存するためフェイルファストで構わない（`use <- result.try` を使う）。

## テストの書き方

バリデーションのテストは `command.validate` に対して書く。`command.create` のテストはドメインロジックに対して書く。

```gleam
// バリデーションのテスト
pub fn validate_price_too_high_test() {
  let input = CreateProductInput(price: 1_000_001, ...)
  command.validate(input) |> should.be_error
}

// command のテスト（Valid 型を通して渡す）
pub fn create_product_test() {
  let assert Ok(valid) = command.validate(fixture_input())
  let save = fn(product: Product) { Ok(product) }
  command.create(save)(valid) |> should.be_ok
}
```
