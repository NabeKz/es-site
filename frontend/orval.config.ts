import { defineConfig } from "orval"

export default defineConfig({
  gymApp: {
    input: "../docs/openapi.yaml",
    output: {
      baseUrl: "/api",
      target: "src/shared/generated/openapi.gen.ts",
      client: "fetch",
      clean: true,
    },
  },
})
