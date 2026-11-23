// The Vite plugin the Ember toolchain runs `.gts` modules through: what @embroider/vite does for
// an app, cut to what a component module needs. `@ember/*` and `@glimmer/tracking` are modules
// of `ember-source`, which publishes a package as `ember-source/@ember/component/index.js` and a
// module inside one as `ember-source/@ember/component/template-only.js`.
import type { Plugin } from "vite";

import { compileGts } from "./gts.ts";

/** The modules `ember-source` holds, which no package of their own name publishes. */
const EMBER_SOURCE_MODULE = /^(?:@ember\/[\w-]+(?:\/[\w-]+)*|@glimmer\/tracking)$/;

/** A `.gts` module's id, with any query. */
const GTS = /\.gts(?:\?.*)?$/;

/** Compiles `.gts` modules and resolves `ember-source`'s modules, from the Vite root. */
export function ember(): Plugin {
  let root = process.cwd();
  return {
    name: "unframework:ember",
    enforce: "pre",
    configResolved(config) {
      root = config.root;
    },
    async resolveId(source, importer, options) {
      if (!EMBER_SOURCE_MODULE.test(source)) return null;
      const resolve = (path: string) =>
        this.resolve(`ember-source/${path}`, importer, { ...options, skipSelf: true });
      return (await resolve(`${source}/index.js`)) ?? resolve(`${source}.js`);
    },
    async transform(code, id) {
      if (!GTS.test(id)) return null;
      const { code: compiled, map } = await compileGts(code, id.replace(/\?.*$/, ""), root);
      return { code: compiled, map: map as never };
    },
  };
}
