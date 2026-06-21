// User Story: 顧客として、カート内の商品の数量を変更したい（requirements.md / UC-4）

// test: 在庫数以内であれば数量を変更できる（UC-4 基本）
pub fn update_cart_item_success_test() {
  todo
  // 新しい数量 <= 在庫 なら更新が成功する
}

// test: 在庫数を超える数量には変更できない（UC-4 例外）
pub fn update_cart_item_exceeds_stock_test() {
  todo
  // 新しい数量 > 在庫 のときエラー。
  // 現状の command.update は在庫チェックを一切行わない
}
