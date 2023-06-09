import {
  ApolloLink,
  FetchResult,
  NextLink,
  Observable,
  Operation,
} from "@apollo/client";
import { Request, Response } from "express";
import { execute, hookArgs, isAsyncIterable } from "grafast";
import type {} from "grafserv/express/v4";
import { getOperationAST } from "graphql";
import type { PostGraphileInstance } from "postgraphile";

export interface GraphileApolloLinkInterface {
  /** The request object. */
  req: Request;

  /** The response object. */
  res: Response;

  /** The instance of the express middleware returned by calling `postgraphile()` */
  pgl: PostGraphileInstance;
}

/**
 * A Graphile Apollo link for use during SSR. Allows Apollo Client to resolve
 * server-side requests without requiring an HTTP roundtrip.
 */
export class GraphileApolloLink extends ApolloLink {
  constructor(private options: GraphileApolloLinkInterface) {
    super();
  }

  request(
    operation: Operation,
    _forward?: NextLink
  ): Observable<FetchResult> | null {
    const { pgl, req, res } = this.options;
    return new Observable((observer) => {
      (async () => {
        try {
          const {
            operationName,
            variables: variableValues,
            query: document,
          } = operation;
          const op = getOperationAST(document, operationName);
          if (!op || op.operation !== "query") {
            if (!observer.closed) {
              /* Only do queries (not subscriptions) on server side */
              observer.complete();
            }
            return;
          }
          const schema = await pgl.getSchema();
          const args = {
            schema,
            document,
            variableValues,
            operationName,
          };
          await hookArgs(args, pgl.getResolvedPreset(), {
            node: {
              req,
              res,
            },
            expressv4: {
              req,
              res,
            },
          });
          const data = await execute(args);
          if (isAsyncIterable(data)) {
            data.return?.();
            throw new Error("Iterable not supported by GraphileApolloLink");
          }
          if (!observer.closed) {
            observer.next(data);
            observer.complete();
          }
        } catch (e: any) {
          if (!observer.closed) {
            observer.error(e);
          } else {
            console.error(e);
          }
        }
      })();
    });
  }
}
