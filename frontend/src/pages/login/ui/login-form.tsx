import { useState, useTransition } from "react"
import { useNavigate } from "@tanstack/react-router"
import { css } from "styled-system/css"
import { grid, vstack } from "styled-system/patterns"
import { login } from "@/shared/generated/openapi.gen"

export const LoginForm = () => {
  const navigate = useNavigate()
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState(false)

  const handleSubmit = (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(false)
    const form = e.currentTarget
    const email = (form.elements.namedItem("email") as HTMLInputElement).value
    const password = (form.elements.namedItem("password") as HTMLInputElement).value

    startTransition(async () => {
      const res = await login({ email, password })
      if (res.status !== 200) {
        setError(true)
        return
      }
      navigate({ to: "/" })
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
          <input type="password" name="password" required className={styles.input} />
        </label>
      </div>
      {error && (
        <span className={styles.error}>メールアドレスまたはパスワードが正しくありません</span>
      )}
      <div className={grid({})}>
        <button type="submit" disabled={isPending} className={styles.button}>
          {isPending ? "ログイン中…" : "ログイン"}
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
