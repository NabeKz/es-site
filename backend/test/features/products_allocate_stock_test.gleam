// User Story: 顧客として、注文確定時に在庫が売り越されずに引き当てられてほしい（usecase.md UC-6 手順4）

import features/products/application/command
import gleeunit/should

// test: 在庫を引き当てるとき同じ商品を売り越さない（UC-6 手順4）
pub fn allocate_stock_prevents_overselling_test() {
  // 在庫が注文数を満たせば引き当て成功。書き込む在庫変動は負の delta
  command.allocate_stock(available: 5, requested: 3) |> should.equal(Ok(-3))
  // ちょうど在庫ぴったりでも成功する（境界: available - requested == 0）
  command.allocate_stock(available: 3, requested: 3) |> should.equal(Ok(-3))
  // 在庫が注文数を満たさなければ失敗する（単一集約の不変条件を破らない）
  command.allocate_stock(available: 2, requested: 3) |> should.be_error
}
