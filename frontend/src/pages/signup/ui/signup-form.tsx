import { useState, useTransition } from "react"
import { useNavigate } from "@tanstack/react-router"
import { css } from "styled-system/css"
import { grid, vstack } from "styled-system/patterns"
import { signup } from "@/shared/generated/openapi.gen"

export const SignupForm = () => {
  const navigate = useNavigate()
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(null)
    const form = e.currentTarget
    const email = (form.elements.namedItem("email") as HTMLInputElement).value
    const password = (form.elements.namedItem("password") as HTMLInputElement).value

    startTransition(async () => {
      const res = await signup({ email, password })
      if (res.status !== 201) {
        setError("登録に失敗しました")
        return
      }
      navigate({ to: "/login" })
    })
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit}>
      <div className={styles.body}>
        <label className={styles.label}>
          メールアドレス
          <input type="email" name="email" required className={styles.input} />
        </label>
        <label className={styles.label}>
          パスワード
          <input type="password" name="password" required minLength={8} className={styles.input} />
        </label>
      </div>
      {error && <span className={styles.error}>{error}</span>}
      <div className={grid({})}>
        <button type="submit" disabled={isPending} className={styles.button}>
          {isPending ? "登録中…" : "登録する"}
        </button>
      </div>
    </form>
  )
}

const styles = {
  form: vstack({ display: "grid", gap: "lg" }),
  body: vstack({}),
  error: css({ fontSize: "sm", color: "red.600" }),
  button: css({ padding: "xs", border: "thin solid black" }),
  label: grid({}),
  input: css({ border: "thin solid black", padding: "sm" }),
} as const
