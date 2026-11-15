---
"@unframework.dev/codegen": patch
---

Write a bound `value` beside a radio's or a checkbox group's `v-model` as `value={…}` on Svelte, so Svelte's server render marks the input whose value the model holds as `checked`, as every other target does. The object spread it used before, `{...{ value: … }}`, rendered no `checked` on the server.
