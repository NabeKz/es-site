import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import { tanstackRouter } from "@tanstack/router-plugin/vite"
import { resolve } from "node:path"

export default defineConfig({
  plugins: [tanstackRouter({ routesDirectory: "./src/app/routes" }), react()],
  server: {
    proxy: {
      "/api": {
        target: "http://localhost:8000",
        rewrite: (path) => path.replace(/^\/api/, ""),
      },
    },
  },
  resolve: {
    alias: {
      "@": resolve(import.meta.dirname, "src"),
      "styled-system": resolve(import.meta.dirname, "styled-system"),
    },
  },
})
