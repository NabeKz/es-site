import { defineConfig } from "@pandacss/dev"

export default defineConfig({
  preflight: true,
  strictTokens: true,

  include: ["./src/**/*.{js,jsx,ts,tsx}", "./pages/**/*.{js,jsx,ts,tsx}"],
  exclude: [],

  theme: {
    tokens: {
      sizes: {
        "0": { value: "0" },
        xs: { value: "4px" },
        sm: { value: "8px" },
        md: { value: "16px" },
        lg: { value: "24px" },
        xl: { value: "32px" },
        "2xl": { value: "40px" },
        "3xl": { value: "48px" },
        "4xl": { value: "56px" },
        "5xl": { value: "64px" },
        "6xl": { value: "72px" },
        "7xl": { value: "80px" },
        "8xl": { value: "88px" },
        "9xl": { value: "96px" },
        full: { value: "100%" },
      },
      spacing: {
        "0": { value: "0" },
        xs: { value: "4px" },
        sm: { value: "8px" },
        md: { value: "16px" },
        lg: { value: "24px" },
        xl: { value: "32px" },
        "2xl": { value: "40px" },
        "3xl": { value: "48px" },
        "4xl": { value: "56px" },
        "5xl": { value: "64px" },
        "6xl": { value: "72px" },
        "7xl": { value: "80px" },
        "8xl": { value: "88px" },
        "9xl": { value: "96px" },
      },
    },
  },

  outdir: "styled-system",
})
