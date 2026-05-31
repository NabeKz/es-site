import { vstack } from "styled-system/patterns"
import { css } from "styled-system/css"
import { getLessons, getMyReservations } from "@/shared/generated/openapi.gen"
import { useState, useTransition, Suspense } from "react"
import { LessonList } from "./ui/lesson-list"
import { emptyText } from "@/shared/ui/styles"

const fetchAll = () => Promise.all([getLessons(), getMyReservations()])

export const Page = () => {
  const [promise, setPromise] = useState(fetchAll)
  const [, startTransition] = useTransition()
  const refetch = () => startTransition(() => setPromise(fetchAll()))

  return (
    <div className={container}>
      <header className={vstack({ gap: "xs", alignItems: "flex-start" })}>
        <h1 className={title}>レッスン一覧</h1>
        <p className={subtitle}>気になるレッスンを予約しよう</p>
      </header>

      <Suspense fallback={<p className={emptyText}>読み込み中…</p>}>
        <LessonList promise={promise} onRefresh={refetch} />
      </Suspense>
    </div>
  )
}

const container = vstack({
  w: "full",
  maxW: "[720px]",
  mx: "[auto]",
  px: "md",
  py: "2xl",
  gap: "xl",
  alignItems: "stretch",
})

const title = css({ fontSize: "2xl", fontWeight: "bold" })
const subtitle = css({ color: "gray.500", fontSize: "sm" })
