import { css } from "styled-system/css"
import { hstack } from "styled-system/patterns"
import { cancelReservation } from "@/shared/generated/openapi.gen"
import { isOk, toResult } from "@/shared/lib/api"
import { useState, useTransition } from "react"

type CancelState = "idle" | "pending" | "success" | "deadline_passed" | "error"

const errorMessage: Record<Exclude<CancelState, "idle" | "pending" | "success">, string> = {
  deadline_passed: "キャンセル期限を過ぎています",
  error: "キャンセルに失敗しました",
}

export const CancelButton = ({
  reservationId,
  onCancelled,
}: {
  reservationId: string
  onCancelled: () => void
}) => {
  const [isPending, startTransition] = useTransition()
  const [state, setState] = useState<CancelState>("idle")

  const handleCancel = () => {
    startTransition(async () => {
      setState("pending")
      const result = await toResult(cancelReservation(reservationId))
      if (isOk(result)) {
        setState("success")
        onCancelled()
      } else {
        setState(result.status === 409 ? "deadline_passed" : "error")
      }
    })
  }

  if (state === "success") {
    return <span className={successBadge}>キャンセル済み</span>
  }

  const message = state in errorMessage ? errorMessage[state as keyof typeof errorMessage] : null

  return (
    <div className={hstack({ gap: "sm" })}>
      {message && <span className={errorText}>{message}</span>}
      <button onClick={handleCancel} disabled={isPending} className={cancelBtn}>
        {isPending ? "キャンセル中…" : "予約済み・キャンセルする"}
      </button>
    </div>
  )
}

const cancelBtn = css({
  px: "md",
  py: "sm",
  borderRadius: "md",
  fontSize: "sm",
  fontWeight: "medium",
  cursor: "pointer",
  bg: "red.50",
  color: "red.700",
  borderWidth: "1px",
  borderColor: "red.300",
  _hover: { bg: "red.100" },
  _disabled: { opacity: "0.5", cursor: "not-allowed" },
})

const successBadge = css({
  px: "sm",
  py: "xs",
  borderRadius: "full",
  fontSize: "sm",
  fontWeight: "medium",
  bg: "gray.100",
  color: "gray.500",
})

const errorText = css({ fontSize: "xs", color: "red.600" })
