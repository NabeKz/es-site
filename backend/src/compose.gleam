import gleam/list
import gleam/result
import pog
import shared/date

import app/handlers
import app/handlers/auth
import app/handlers/lessons
import app/handlers/reservations
import features/lessons/adaptor/rdb as lessons_rdb
import features/lessons/application as lessons_app
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/reservations/adaptor/rdb as reservations_rdb
import features/reservations/application as reservations_app
import features/sessions/adaptor/rdb as sessions_rdb
import features/sessions/application as sessions_app
import workflows/adaptor/actor as actor_adaptor
import workflows/reservation_supervisor

pub fn restore_actors(
  conn: pog.Connection,
  sup: reservation_supervisor.ReservationSupervisor,
) -> Nil {
  case lessons_rdb.list(conn)(date.now()) {
    Error(_) -> Nil
    Ok(rows) ->
      list.each(rows, fn(row) {
        let _ = reservation_supervisor.start_actor(sup, row.id, row.starts_at)
      })
  }
}

pub fn build(
  conn: pog.Connection,
  pepper: String,
  sup: reservation_supervisor.ReservationSupervisor,
) -> handlers.Handlers {
  let create_lesson = fn(input) {
    use lesson <- result.try(lessons_app.create(lessons_rdb.create(conn))(input))
    let _ = reservation_supervisor.start_actor(sup, lesson.id, lesson.starts_at)
    Ok(lesson)
  }

  handlers.Handlers(
    auth: auth.new(
      members_app.signup(
        members_rdb.save(conn),
        members_rdb.find_by_email(conn),
        pepper,
      ),
      sessions_app.login(
        members_rdb.find_by_email(conn),
        sessions_rdb.save_session(conn),
        pepper,
      ),
      sessions_app.logout(sessions_rdb.delete_session(conn)),
      sessions_app.me(
        sessions_rdb.find_member_id_by_token(conn),
        members_rdb.find_by_id(conn),
      ),
    ),
    lessons: lessons.new(
      create_lesson,
      conn |> lessons_rdb.read |> lessons_app.read,
      conn |> lessons_rdb.list |> lessons_app.list,
    ),
    reservations: reservations.new(
      sessions_rdb.find_member_id_by_token(conn),
      actor_adaptor.create(sup),
      reservations_app.cancel(
        reservations_rdb.read_reservation_info(conn),
        reservations_rdb.delete_reservation(conn),
        conn |> lessons_rdb.read |> lessons_app.read,
      ),
      reservations_app.list_my(reservations_rdb.list_my_reservations(conn)),
    ),
  )
}
