import gleam/list
import gleam/result
import gleam/string
import pog
import wisp

/// クエリ実行を 1 枚かぶせるミドルウェア。
///
/// 失敗時はエラーをログ出力して固定メッセージに変換し、成功時のみ next に進む。
/// `use` 構文で被せることで、ログが構造的に必ずここを通る。
///
/// wisp への依存はこのモジュールに閉じる。
pub fn query(
  run run: fn() -> Result(a, e),
  on_error message: String,
  next next: fn(a) -> Result(b, String),
) -> Result(b, String) {
  case run() {
    Error(err) -> {
      wisp.log_error(string.inspect(err))
      Error(message)
    }
    Ok(value) -> next(value)
  }
}

/// 単一行を取り出す。行が無ければ not_found メッセージでエラーにする。
pub fn first_row(
  returned: pog.Returned(row),
  not_found message: String,
) -> Result(row, String) {
  returned.rows
  |> list.first()
  |> result.map_error(fn(_) { message })
}
