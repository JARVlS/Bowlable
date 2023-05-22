import Vue from "@vitejs/plugin-vue";
import { defineConfig } from "vite";
import Pages from "vite-plugin-pages";
import viteSSR from "vite-ssr/plugin.js";
// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
        viteSSR(),
        Vue({
            include: [/\.vue$/, /\.md$/],
            template: {
            //ssr: true,
            },
        }),
        Pages({
            extensions: ["vue", "md"],
        }),
    ],
});
