import app/handlers/auth
import app/handlers/lessons
import app/handlers/reservations

pub type Handlers {
  Handlers(
    auth: auth.AuthHandler,
    lessons: lessons.LessonHandler,
    reservations: reservations.ReservationHandler,
  )
}
