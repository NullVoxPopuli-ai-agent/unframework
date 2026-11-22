import type { Toolchain } from "@unframework.dev/codegen";
import {
  lintWithEslint,
  lintWithOxlint,
  mergeLintResults,
} from "@unframework.dev/codegen/toolchain-node";
import type { UserConfig } from "vite";

import { frameworkCompile, frameworkEmit } from "./framework-compile.ts";
import { typecheck } from "./typecheck.ts";

/**
 * The Ember target's toolchain, for tests and tooling: its own `.gts` plugin in Vite
 * (content-tag, Babel and Ember's template compiler), the same steps for L3, Glint for L4,
 * oxlint and eslint-plugin-ember for L5, and `renderComponent` adapters for the browser and the
 * server.
 */
export const toolchain: Toolchain = {
  name: "ember",
  async vite(mode): Promise<UserConfig> {
    // Loaded on demand: reading `client` or `server` should not load Babel.
    const { ember } = await import("./vite.ts");
    return {
      plugins: [ember()],
      resolve: { dedupe: ["ember-source", "@glimmer/component"] },
      // `@glimmer/component` imports `@ember/*` modules, which only the plugin resolves, and
      // `ember-source` is ESM that its own modules import by path: both go through Vite.
      ...(mode === "ssr"
        ? { ssr: { noExternal: ["ember-source", "@glimmer/component"] } }
        : { optimizeDeps: { exclude: ["ember-source", "@glimmer/component"] } }),
    };
  },
  client: "@unframework.dev/target-ember/toolchain/client",
  server: "@unframework.dev/target-ember/toolchain/server",
  frameworkCompile,
  frameworkEmit,
  typecheck,
  // L5 (ADR-0042): ESLint with eslint-plugin-ember and typescript-eslint over the `.gts` files,
  // which oxlint does not parse, and oxlint's shared baseline over a `.ts` module beside them.
  lint: async (files, context) => {
    const components = files.filter((file) => file.endsWith(".gts"));
    const modules = files.filter((file) => !file.endsWith(".gts"));
    return mergeLintResults(
      await Promise.all([
        ...(components.length ? [lintWithEslint(components, context)] : []),
        ...(modules.length ? [lintWithOxlint(modules, context)] : []),
      ]),
    );
  },
};

export default toolchain;
