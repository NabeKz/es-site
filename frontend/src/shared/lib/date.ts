export const parseDate = (iso: string) => new Date(iso)

export const formatDateTime = (d: Date) =>
  d.toLocaleString("ja-JP", { month: "numeric", day: "numeric", hour: "2-digit", minute: "2-digit" })

export const formatTime = (d: Date) =>
  d.toLocaleString("ja-JP", { hour: "2-digit", minute: "2-digit" })
