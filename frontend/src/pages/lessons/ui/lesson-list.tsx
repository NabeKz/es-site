import { vstack, hstack } from "styled-system/patterns"
import { css, cva } from "styled-system/css"
import { getLessons, getMyReservations } from "@/shared/generated/openapi.gen"
import { use } from "react"
import type { Lesson } from "@/shared/generated/openapi.gen"
import { parseDate, formatDateTime, formatTime } from "@/shared/lib/date"
import { ReserveButton } from "./reserve-button"
import { CancelButton } from "./cancel-button"
import { emptyText } from "@/shared/ui/styles"

type LessonsWithReservationsPromise = Promise<
  [Awaited<ReturnType<typeof getLessons>>, Awaited<ReturnType<typeof getMyReservations>>]
>

const LessonCard = ({
  lesson,
  reservationId,
  onRefresh,
}: {
  lesson: Lesson
  reservationId: string | undefined
  onRefresh: () => void
}) => {
  const startsAt = parseDate(lesson.startsAt)
  const endsAt = parseDate(lesson.endsAt)

  const isFull = lesson.remainingSlots === 0
  const isAlmostFull = !isFull && lesson.remainingSlots <= 3
  const slotsStatus = isFull ? "full" : isAlmostFull ? "almostFull" : "available"

  return (
    <div className={card}>
      <div className={hstack({ justify: "space-between" })}>
        <div className={vstack({ gap: "xs", alignItems: "flex-start" })}>
          <h2 className={lessonName}>{lesson.name}</h2>
          <span className={instructorLabel}>講師: {lesson.instructor}</span>
        </div>
        <span className={slotsBadge({ status: slotsStatus })}>
          残席 {lesson.remainingSlots} / {lesson.capacity}
        </span>
      </div>

      <div className={timeRow}>
        {formatDateTime(startsAt)} 〜 {formatTime(endsAt)}
      </div>

      {lesson.description && <p className={descText}>{lesson.description}</p>}

      <div className={hstack({ justify: "flex-end" })}>
        {reservationId ? (
          <CancelButton reservationId={reservationId} onCancelled={onRefresh} />
        ) : (
          <ReserveButton lesson={lesson} onReserved={onRefresh} />
        )}
      </div>
    </div>
  )
}

export const LessonList = ({
  promise,
  onRefresh,
}: {
  promise: LessonsWithReservationsPromise
  onRefresh: () => void
}) => {
  const [lessonsResult, reservationsResult] = use(promise)
  const items = lessonsResult.data
  const reservationMap = new Map(
    reservationsResult.status === 200
      ? reservationsResult.data.map((r) => [r.lessonId, r.id])
      : [],
  )

  if (items.length === 0) {
    return <p className={emptyText}>現在予約できるレッスンはありません</p>
  }

  return (
    <div className={vstack({ gap: "md", alignItems: "stretch", w: "full" })}>
      {items.map((item) => (
        <LessonCard
          key={item.id}
          lesson={item}
          reservationId={reservationMap.get(item.id)}
          onRefresh={onRefresh}
        />
      ))}
    </div>
  )
}

const card = css({
  borderWidth: "1px",
  borderStyle: "solid",
  borderColor: "gray.200",
  borderRadius: "lg",
  p: "lg",
  bg: "white",
  boxShadow: "sm",
  display: "flex",
  flexDirection: "column",
  gap: "sm",
})

const lessonName = css({ fontSize: "lg", fontWeight: "semibold" })
const instructorLabel = css({ fontSize: "sm", color: "gray.500" })
const timeRow = css({ fontSize: "sm", color: "gray.600" })
const descText = css({ fontSize: "sm", color: "gray.700", whiteSpace: "pre-wrap" })

const slotsBadge = cva({
  base: {
    fontSize: "xs",
    fontWeight: "medium",
    px: "sm",
    py: "xs",
    borderRadius: "full",
  },
  variants: {
    status: {
      full: { bg: "red.100", color: "red.700" },
      almostFull: { bg: "orange.100", color: "orange.700" },
      available: { bg: "green.100", color: "green.700" },
    },
  },
})
