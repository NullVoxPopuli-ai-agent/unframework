---
"@unframework.dev/compiler": minor
"@unframework.dev/codegen": minor
"@unframework.dev/unplugin": minor
"@unframework.dev/testing": minor
"@unframework.dev/cli": minor
---

Add `ember`, an opt-in target that compiles a component to an Ember 7.4 `.gts` file: a template-only component, or a `@glimmer/component` class whose members hold what the template cannot. It emits the static and props subset of components, with listeners, emits, template refs, watchers, lifecycle hooks, `useId`, `nextTick` and scoped stylesheets, so far. A module that uses anything else has no Ember output, and the compiler reports UF4001 as an error there. The default targets stay the seven. `build --package` does not package `ember` yet. A component with no output for a target no longer takes its scoped sheet there.
