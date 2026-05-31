import { createFileRoute, Outlet, redirect, useRouter } from "@tanstack/react-router"
import { getMe, logout } from "@/shared/generated/openapi.gen"
import { grid } from "styled-system/patterns/grid"
import { css } from "styled-system/css"

const Signout = () => {
  const router = useRouter()
  const handleSignout = async () => {
    await logout()
    router.navigate({ to: "/login" })
  }
  return (
    <button type="button" className={button} onClick={handleSignout}>
      signout
    </button>
  )
}

export const Route = createFileRoute("/_authenticated")({
  beforeLoad: async () => {
    const res = await getMe()
    if (res.status !== 200) {
      throw redirect({ to: "/login" })
    }
  },
  component: () => (
    <>
      <header className={header}>
        <Signout />
      </header>
      <Outlet />
    </>
  ),
})

const header = grid({
  w: "full",
  paddingBlock: "sm",
  placeContent: "end",
})

const button = css({
  cursor: "pointer",
})
