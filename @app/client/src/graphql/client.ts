import { cacheExchange, Client, fetchExchange, ssrExchange } from "@urql/core";

const isServerSide = import.meta.env.SSR;

// The `ssrExchange` must be initialized with `isClient` and `initialState`
export const ssr = ssrExchange({
  isClient: !isServerSide,
  initialState: !isServerSide
    ? (window as any)?.__INITIAL_STATE__?.urql
    : undefined,
});

export const client = new Client({
  url: "/graphql",
  exchanges: [
    cacheExchange,
    ssr, // Add `ssr` in front of the `fetchExchange`
    fetchExchange,
  ],
});
