import {
  cacheExchange,
  Client,
  fetchExchange,
  ssrExchange,
  subscriptionExchange,
} from "@urql/core";
import { createClient as createWSClient, Client as WsClient } from "graphql-ws";

// urql with server side rendering: https://formidable.com/open-source/urql/docs/advanced/server-side-rendering/

const isServerSide = import.meta.env.SSR;

let wsClient: WsClient | null = null;
if (import.meta.env.SSR) {
  const WebSocket = (await import("ws")).default;
  wsClient = createWSClient({
    url: `ws://localhost:5678/graphql`,
    webSocketImpl: WebSocket,
  });
} else {
  wsClient = createWSClient({
    url: `ws://localhost:5678/graphql`,
  });
}

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
    subscriptionExchange({
      forwardSubscription(request) {
        const input = { ...request, query: request.query || "" };
        return {
          subscribe(sink) {
            if (!wsClient) throw new Error("wsClient is null");
            const unsubscribe = wsClient.subscribe(input, sink);
            return { unsubscribe };
          },
        };
      },
    }),
  ],
});
