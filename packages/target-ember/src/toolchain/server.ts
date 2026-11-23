// `ember-source` publishes its modules' types as ambient declarations.
/// <reference types="ember-source/types" />
import { get } from "@ember/helper";
import { renderSettled } from "@ember/renderer";
import Route from "@ember/routing/route";
import EmberRouter from "@ember/routing/router";
import { template } from "@ember/template-compiler/runtime";
import type { SsrRenderer } from "@unframework.dev/codegen";
import EmberApp from "ember-strict-application-resolver";
import { createEmberApp } from "vite-ember-ssr/server";

/** The router of the app that renders one component: its one route is the application's. */
class Router extends EmberRouter {
  override location = "none";
  override rootURL = "/";
}

/**
 * What the render waits for before it serializes: the render again for what an immediate watcher
 * writes, as Vue's render shows it. A render error reaches Node as an unhandled rejection a timer
 * later, so this waits a timer first, as `@ember/test-helpers`' `settled` does, and the render
 * reports the error.
 */
async function settled(): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve));
  await renderSettled();
}

/**
 * Renders a compiled Ember component on the server as an app renders it there: vite-ember-ssr
 * boots an application under a happy-dom window and serialises what it renders. The app's
 * application template invokes the component with the props as its arguments, read from the
 * route's model, and returns only the component's HTML: the body holds nothing else.
 */
export const renderToString: SsrRenderer = async (component, { props = {} }) => {
  // Glimmer spreads no arguments, so the template names each prop the case passes.
  const args = Object.keys(props)
    .map((name) => `@${name}={{get @model ${JSON.stringify(name)}}}`)
    .join(" ");
  const application = template(`<Component ${args} />`, {
    scope: () => ({ Component: component, get }),
  });
  class ApplicationRoute extends Route {
    override model(): Record<string, unknown> {
      return props;
    }
  }
  class App extends EmberApp {
    modulePrefix = "uf-ssr";
    override modules = {
      "./router": Router,
      "./routes/application": ApplicationRoute,
      "./templates/application": application,
    };
  }
  const app = await createEmberApp("uf-ssr", {
    dev: {
      ssrLoadModule: async () => ({
        createSsrApp: () => App.create({ autoboot: false }),
        settled,
      }),
    },
  });
  try {
    const { body, error } = await app.renderRoute("/");
    if (error) throw error;
    return body;
  } finally {
    await app.destroy();
  }
};
