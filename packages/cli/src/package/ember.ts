import type { Packager } from "./packager.ts";

/**
 * Plan §8.4 for Ember is a v2 addon: the components as JavaScript with their templates for the
 * app's template compiler, and Glint's declarations. It is not built yet, so a package that selects
 * `ember` fails here (UF7009) rather than ship `.gts` files an app does not compile in a dependency.
 */
export const ember: Packager = {
  peer: [
    { name: "ember-source", range: ">=7.4 <8" },
    { name: "@glimmer/component", range: "^2.0.0" },
  ],
  needs: [],
  exports: { types: "./ember/index.d.ts", default: "./ember/index.js" },
  run: () =>
    Promise.reject(new Error("The Ember packager is not built yet (uxfront-com/unframework#236).")),
};
