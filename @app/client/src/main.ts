import "./style.css";

import viteSSR, { ClientOnly } from "vite-ssr";

import routes from "~pages";

console.log("routes", routes);

import App from "./App.vue";

export default viteSSR(
  App,
  {
    routes,
  },
  async (context) => {
    const { app, router, initialState, request } = context;
    app.component(ClientOnly.name, ClientOnly);

    // prepare initial state
    if (import.meta.env.SSR) {
      if (request) initialState.csrfToken = request.headers["X-CSRF-TOKEN"];
    }

    // prepare router
    router.beforeEach(async (to: any, from: any, next: () => void) => {
      console.debug(`changing route from ${from.fullPath} to ${to.fullPath}`);
      next();
    });

    app.provide("initialState", initialState);
  }
);
