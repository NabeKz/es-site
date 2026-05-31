import gleam/io
import gleam/list
import pog
import wisp

import app/db
import features/lessons/adaptor/rdb as lessons_rdb
import features/lessons/application as lessons_app
import generated/requests

pub fn main() {
  wisp.configure_logger()
  let conn = db.start()

  let assert Ok(_) =
    pog.query("TRUNCATE app.reservations, app.lessons")
    |> pog.execute(conn)

  let create = conn |> lessons_rdb.create |> lessons_app.create

  let seed_lessons = [
    requests.CreateLessonInput(
      name: "ヨガ入門",
      instructor: "田中 花子",
      starts_at: "2026-05-13T09:00:00Z",
      ends_at: "2026-05-13T10:00:00Z",
      capacity: 15,
      description: "ゆっくりとしたペースで基本のポーズを学ぶ初心者向けヨガクラスです。",
    ),
    requests.CreateLessonInput(
      name: "パワーヨガ",
      instructor: "田中 花子",
      starts_at: "2026-05-13T11:00:00Z",
      ends_at: "2026-05-13T12:00:00Z",
      capacity: 12,
      description: "体幹強化と柔軟性向上を目的とした中級者向けヨガクラスです。",
    ),
    requests.CreateLessonInput(
      name: "ピラティス",
      instructor: "佐藤 美咲",
      starts_at: "2026-05-13T14:00:00Z",
      ends_at: "2026-05-13T15:00:00Z",
      capacity: 10,
      description: "インナーマッスルを鍛え、姿勢改善を目指すピラティスクラスです。",
    ),
    requests.CreateLessonInput(
      name: "ズンバ",
      instructor: "鈴木 健太",
      starts_at: "2026-05-14T10:00:00Z",
      ends_at: "2026-05-14T11:00:00Z",
      capacity: 20,
      description: "ラテン系の音楽に合わせて楽しく踊るダンスフィットネスクラスです。",
    ),
    requests.CreateLessonInput(
      name: "スピニング",
      instructor: "高橋 亮",
      starts_at: "2026-05-14T07:00:00Z",
      ends_at: "2026-05-14T08:00:00Z",
      capacity: 15,
      description: "インドアサイクリングで有酸素運動と下半身強化を図るクラスです。",
    ),
    requests.CreateLessonInput(
      name: "ボクシングエクササイズ",
      instructor: "伊藤 大輝",
      starts_at: "2026-05-15T19:00:00Z",
      ends_at: "2026-05-15T20:00:00Z",
      capacity: 12,
      description: "ボクシングの動きを取り入れた全身有酸素運動クラスです。ストレス発散にも最適。",
    ),
    requests.CreateLessonInput(
      name: "ストレッチ＆リラクゼーション",
      instructor: "渡辺 さくら",
      starts_at: "2026-05-15T21:00:00Z",
      ends_at: "2026-05-15T21:45:00Z",
      capacity: 20,
      description: "1日の疲れをほぐす、全身ストレッチとリラクゼーションのクラスです。",
    ),
    requests.CreateLessonInput(
      name: "HIITトレーニング",
      instructor: "中村 翔",
      starts_at: "2026-05-16T06:30:00Z",
      ends_at: "2026-05-16T07:15:00Z",
      capacity: 10,
      description: "高強度インターバルトレーニング。短時間で最大限の効果を引き出します。",
    ),
  ]

  list.each(seed_lessons, fn(input) {
    case create(input) {
      Ok(lesson) -> io.println("created: " <> lesson.name)
      Error(err) -> io.println("error: " <> err)
    }
  })
}
