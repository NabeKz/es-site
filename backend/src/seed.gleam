import app/db
import wisp

pub fn main() {
  wisp.configure_logger()
  let _conn = db.start()

  // TODO: EC サイト向けのシードデータを追加する
}
