export default {
  content: [
    "./index.html",
    "./pages/**/*.html",
    "./src/**/*.{js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {
      colors: {
        primary:        "#007bff",
        secondary:      "#6f42c1",
        accent:         "#e83e8c",
        success:        "#28a745",
        warning:        "#ffc107",
        danger:         "#dc3545",
        info:           "#17a2b8",
        background:     "#f8f9fa",
        textMain:       "#343a40",
        textSecondary:  "#6c757d",
      },

      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        title: ["Poppins", "sans-serif"],
      },

      borderRadius: {
        pill: "9999px",
      }
    }
  },
  plugins: [],
}