// User Story: 会員として、自分の予約一覧を確認したい（requirements.md）

import features/reservations/application/query
import generated/responses.{Reservation}
import gleeunit/should
import youid/uuid

// test: 自分の予約一覧を取得できる
pub fn list_my_success_test() {
  let member_id = uuid.v4()
  let reservation = Reservation(id: uuid.v4(), lesson_id: uuid.v4())
  let adaptor = fn(_: uuid.Uuid) { Ok([reservation]) }

  query.list_my(adaptor)(member_id) |> should.equal(Ok([reservation]))
}

// test: 予約がない場合は空リストを返す
pub fn list_my_empty_test() {
  let adaptor = fn(_: uuid.Uuid) { Ok([]) }

  query.list_my(adaptor)(uuid.v4()) |> should.equal(Ok([]))
}

// test: DB エラー時は Error を返す
pub fn list_my_adaptor_error_test() {
  let adaptor = fn(_: uuid.Uuid) { Error("db error") }

  query.list_my(adaptor)(uuid.v4()) |> should.be_error
}
