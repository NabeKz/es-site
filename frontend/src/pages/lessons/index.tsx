import { vstack } from "styled-system/patterns"
import { css } from "styled-system/css"

export const Page = () => {
  return (
    <div className={container}>
      <header className={vstack({ gap: "xs", alignItems: "flex-start" })}>
        <h1 className={title}>レッスン一覧</h1>
        <p className={subtitle}>気になるレッスンを予約しよう</p>
      </header>
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
