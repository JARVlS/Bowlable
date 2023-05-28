module.exports = {
  plugins: {
    // https://dev.to/kenzysc/vite-internal-server-error-cannot-read-properties-of-undefined-reading-length-for-tailwind-and-postcss-5g7
    tailwindcss: require("./tailwind.config.js"),
    autoprefixer: {},
  },
};
