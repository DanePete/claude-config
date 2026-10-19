---
name: launcher-deploy
description: Pantheon deploys go through Kaza's launcher script (`l t.<site>.<env>`), which walks dev → test → live and runs drush deploy at each step. Never hand-roll terminus env:deploy.
metadata:
  type: reference
---

# Deploys run through launcher

The deployment tool is **launcher** — [kazajhodo/launcher](https://github.com/kazajhodo/launcher),
cloned at `~/Projects/launcher`, aliased `l` (`alias l="$projects/launcher/launcher.sh"`).
It started as a PHP-version swapper, which is all its README describes; the deploy lives in
`include/terminus`, so reading the README tells you nothing about it. Other devs may use it
too — if `l` isn't defined on their machine, ask rather than assume.

```
l t.<site>.<env>        # t. = terminus.   e.g. l t.aaisisal.live
```

One invocation walks **dev → test → live** up to the named env. Per env: wait for in-flight
workflows, `terminus env:deploy` (skipped on dev), then `terminus drush <site>.<env> -- deploy -y`
— updb, cim, cr, deploy hooks. WordPress sites get core + WooCommerce DB updates instead.
A failed step stops the walk before the next environment.

**Why this is its own memory:** the knowledge lived in per-project auto-memory on two sites,
so every other project re-learned it — Claude reached for raw `terminus env:deploy`, got told
"we use launcher all the time", and had to go hunting. It's the rule, not a preference: Kaza
stopped a hand-rolled deploy mid-command to say so.

## How to apply

- **Use the tool, never raw `terminus env:deploy` / `terminus drush … deploy`**, and don't
  bolt a `workflow:list` polling loop around it — it has its own wait.
- **Don't narrate the procedure** — say what the deploy carries ([[dont-narrate-the-deploy]]).
- **When asked to deploy to live, run it.** The alias isn't defined in Claude's shell, so call
  the script: `~/Projects/launcher/launcher.sh t.<site>.live` (backgrounded — the walk takes
  minutes). Auto mode's classifier has refused production deploys before; only if it refuses,
  hand it over as `! l t.<site>.live`. Don't hand it over pre-emptively — on sisal
  2026-10-16 Claude did, and Kaza answered "I said run it"; it then ran clean. Dev is fine
  to run once asked ([[confirm-before-live-terminus]]).
- **Run it straight after the push.** Launcher waits for the pushed commit to show on dev and
  for its build to finish before promoting (launcher `02660e4`, 2026-09-29), and since
  `cdb665d` (2026-10-08) does the same on a multidev, reading its own branch; before that a
  multidev deploy ran on the old code and reported success. So don't poll
  `workflow:list` for the dev sync yourself — Claude still did on kow 2026-10-02 from the old
  advice here. [[pantheon-build-lag]] still applies to scripts run *outside* launcher.
- **A failed "Sync code" stays failed; re-running launcher won't rebuild it.** Launcher reads
  the sync workflow for the pushed commit, so every retry reports the same "the code never
  landed" without starting a build. When the failure was Pantheon's (on md 2026-10-12 it fell
  in an outage: dashboard erroring, no workflow log, a clean build log), retrigger with
  `terminus env:code-rebuild <site>.dev`, then run launcher again. Not an empty commit — that
  works but leaves a commit behind (what Claude did before Kaza pointed at the command).
- **Copying content DOWN is plain Terminus, not the launcher** — it has no clone command.
  `terminus env:clone-content <site>.live test --yes` (then `dev`) copies database and files;
  add `--db-only` only when you are sure no uploads differ. Clear caches on each target after
  (`terminus remote:drush <site>.<env> -- cr`); the clone does not. Reading from live is fine
  once asked; it writes only the lower environment.
- **If the tool is wrong, change the tool** — it's Kaza's repo (push to `origin master`).
  Fixing a bug needs no ceremony; ask before changing wait semantics he'd feel day to day.
  Test first: `zsh -n include/terminus`, a real `l t.<site>.dev` run (idempotent), and a
  stub-`$terminus` harness for the failure branch.
