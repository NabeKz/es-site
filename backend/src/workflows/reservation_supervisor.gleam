import gleam/erlang/process
import gleam/otp/actor
import gleam/otp/factory_supervisor
import gleam/otp/supervision
import gleam/result
import gleam/string
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

import workflows/adaptor/rdb as rdb_adaptor
import workflows/create_reservation
import workflows/lesson_reservation_actor
import workflows/lesson_reservation_registry

pub type ActorArgs {
  ActorArgs(lesson_id: Uuid, starts_at: Timestamp)
}

pub type ReservationSupervisor {
  ReservationSupervisor(
    factory: factory_supervisor.Supervisor(
      ActorArgs,
      process.Subject(lesson_reservation_actor.Message),
    ),
    registry: process.Subject(lesson_reservation_registry.RegistryMessage),
  )
}

pub fn start(
  conn: pog.Connection,
) -> Result(ReservationSupervisor, actor.StartError) {
  use registry_started <- result.try(lesson_reservation_registry.start())
  let registry = registry_started.data

  let reserve =
    create_reservation.create(
      rdb_adaptor.get_lesson(conn),
      rdb_adaptor.has_reservation(conn),
      rdb_adaptor.save_reservation(conn),
    )

  let template = fn(args: ActorArgs) {
    let on_shutdown = fn(lesson_id) {
      lesson_reservation_registry.deregister(registry, lesson_id)
    }
    lesson_reservation_actor.start(args.lesson_id, args.starts_at, reserve, on_shutdown)
  }

  use factory_started <- result.try(
    factory_supervisor.worker_child(template)
    |> factory_supervisor.restart_strategy(supervision.Temporary)
    |> factory_supervisor.start(),
  )
  let factory = factory_started.data

  Ok(ReservationSupervisor(factory:, registry:))
}

pub fn start_actor(
  sup: ReservationSupervisor,
  lesson_id: Uuid,
  starts_at: Timestamp,
) -> Result(Nil, String) {
  factory_supervisor.start_child(
    sup.factory,
    ActorArgs(lesson_id:, starts_at:),
  )
  |> result.map(fn(started) {
    lesson_reservation_registry.register(sup.registry, lesson_id, started.data)
  })
  |> result.map_error(fn(e) { string.inspect(e) })
}

pub fn find_actor(
  sup: ReservationSupervisor,
  lesson_id: Uuid,
) -> Result(process.Subject(lesson_reservation_actor.Message), String) {
  lesson_reservation_registry.lookup(sup.registry, lesson_id)
}
