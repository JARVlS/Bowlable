import Vue from "@vitejs/plugin-vue";
import { fileURLToPath } from "url";
import { defineConfig } from "vite";
import Pages from "vite-plugin-pages";
import viteSSR from "vite-ssr/plugin.js";
import tsconfigPaths from "vite-tsconfig-paths";
import path from "path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
console.log(__dirname);

// https://vitejs.dev/config/
export default defineConfig({
  resolve: {
    alias: [{ find: "@src", replacement: path.resolve(__dirname, "src") }],
  },
  plugins: [
    viteSSR(),
    Vue({
      include: [/\.vue$/, /\.md$/],
    }),
    tsconfigPaths({
      root: "../..",
    }),
    Pages({
      extensions: ["vue", "md"],
    }),
  ],
});
