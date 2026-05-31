import { createRootRoute, Outlet } from "@tanstack/react-router"
import { vstack } from "styled-system/patterns"

export const Route = createRootRoute({
  component: () => (
    <div className={wrapper}>
      <Outlet />
    </div>
  ),
})

const wrapper = vstack({
  maxW: "breakpoint-lg",
  margin: "0 auto",
})
