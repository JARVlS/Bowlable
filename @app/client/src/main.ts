// import "./style.css";

import viteSSR, { ClientOnly } from "vite-ssr";

import urql from "@urql/vue";
import { ssr, client as urqlClient } from "@src/graphql/client";
import App from "@src/App.vue";
// eslint-disable-next-line import/no-unresolved
import routes from "~pages";

if (!import.meta.env.SSR) {
  await import("@src/style.css");
}

export default viteSSR(
  App,
  {
    routes,
  },
  async (context) => {
    const { app, router, initialState, request } = context;
    app.use(urql, urqlClient).component(ClientOnly.name, ClientOnly);

    // prepare initial state
    if (import.meta.env.SSR) {
      if (request) initialState.csrfToken = request.headers["X-CSRF-TOKEN"];
    }

    // prepare router
    router.beforeEach(async (to: any, from: any, next: () => void) => {
      console.debug(`changing route from ${from.fullPath} to ${to.fullPath}`);
      next();
    });

    // serialize or load initial state for graphql
    if (import.meta.env.SSR) {
      initialState.urql = JSON.stringify(ssr.extractData());
    } else if (initialState.uqrl) {
      ssr.restoreData(JSON.parse(initialState.uqrl));
    }

    return { app, router, initialState };
  }
);
