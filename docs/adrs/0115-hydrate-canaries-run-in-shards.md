# ADR-0115: Canaries whose hydrate specs run are sharded too

- **Status:** Accepted
- **Date:** 2026-11-19
- **Plan:** §7.7, §7.9; P2; ADR-0052, ADR-0095, ADR-0106; amends ADR-0052

## Context

ADR-0052 shards a canary whose browser specs run, because each corrupted spec waits out a 5 s
timeout. Its rule names `browser` evidence: "Each canary with browser evidence (its tests run)
runs in two shards". It is older than the hydrate projects (ADR-0095), which run the same specs in
a page that hydrates the server's render, on React, Vue, Svelte, Solid, Solid 2 and Angular
(ADR-0106).

The two L12 canaries have `hydrate` evidence alone, so the rule never reached them, and each ran
in one job of the whole corpus: 253 specs on six hydrate projects. `L12-unwired-listener`
removes every element listener on the cases whose specs act, and each of those specs waits out
its timeout.

In the last 60 pull request runs of `ci.yml`, the `Canaries` step of `L12-unwired-listener` took 470 to 516 s
on 17 passes, and 524 to 540 s on the three that GitHub cancelled at the job's 600 s. Setup
takes about a minute of the ten. `L12-client-text` took 350 to 463 s on 20 passes. The same
corruption in the browser projects, `L9-unwired-handler`, runs in two shards of 202 to 347 s.

`canaries.unit.test.ts` keeps the rule. It looked for shards only among the canaries whose
projects include `browser`, so it passed an unsharded L12 entry.

## Decision

- **A canary whose specs run in the hydrate projects is sharded, as one whose specs run in the
  browser projects is.** The rule covers a canary with `browser` or `hydrate` evidence.
- **Both L12 canaries run in two shards,** one job each, in `ci.yml` and in `nightly.yml`.
- **`canaries.unit.test.ts` checks the rule over each entry's own canaries,** not over its
  browser canaries alone, so an unsharded canary with `hydrate` evidence fails it.
- **When a shard nears the ten minutes, the count goes up.** The job's timeout stays, as
  ADR-0052 decided.

ADR-0052's other points stand: how a shard filters its specs, and how the verdict judges each
case once.

## Consequences

**Positive:**

- Each L12 job runs half of the cases. Locally, on React alone, `L12-unwired-listener` took 60.2 s
  for shard 1/2 and 54.5 s for shard 2/2, against 107.1 s for the whole corpus, and caught its
  corruption in each shard.
- The next canary with `hydrate` evidence can't be left in one job.

**Negative:**

- The matrix has two more jobs, and each installs the workspace again (about a minute).
- A seventh hydrate target, such as Vue Vapor, adds about a sixth to each shard's work.

## Alternatives considered

- **A longer job timeout.** §7.9 sets a budget, and the time grows with the corpus and the
  targets.
- **Run only the specs a canary corrupts.** It removes the specs a canary leaves alone, but the
  corrupted specs still take most of the time, and it changes how the runner picks a canary's
  projects. ADR-0052 chose the shard count as the lever.
- **Three shards for `L12-unwired-listener`.** It gives more margin for one more install. Two
  shards fit inside the budget with room for a seventh target, and the rule above raises the count
  when they no longer do.
