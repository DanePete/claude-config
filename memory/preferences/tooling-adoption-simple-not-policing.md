---
name: Shared tooling gets adopted only if it is easy and not policing
description: Before choosing defaults, install steps or enforcement for shared dev tooling (CI, linters, hooks, scaffolds), optimise for adoption — one-step install, warn by default, blocking is opt-in — without ever letting "not policing" become "silently green".
metadata:
  type: feedback
---

# Shared tooling gets adopted only if it is easy and not policing

**Dane, 2026-10-06, redesigning drupal-qa's CI:** *"Simplicity and execution are the priorities —
if it's not easy users won't adopt or if it's too policing they won't adopt."*

**Why:** team tooling only pays off once teams actually run it. drupal-qa v1 spread ten inputs over
four workflow files to install, GrumPHP quietly installing commit-blocking git hooks, and blocking defaults,
and mnair was its only adopter at August Ash. Every knob is something a team has to understand before saying
yes, and every surprise block is a reason to rip the thing out.

**How to apply** to any shared dev tooling — CI workflows, linters, git hooks, scaffolds:

- **One-step install, detected defaults.** Read what the project already says (`composer.json`,
  `.ddev/config.yaml`, `pantheon.yml`) instead of asking for it. Cut knobs before adding them.
- **Warn by default; blocking is opt-in, by name.** The exception is a real breakage: a failed
  deploy step or a test that exists and fails is the site being broken, not policy.
- **Never install hooks or overwrite project files unasked.** Scaffold only what is missing.
- **"Not policing" never means "silently green".** A warned failure has to be visible in the run
  summary, and a step that crashed or ran zero tests is a failure in every mode. drupal-qa v1
  reported Behat and Gitleaks green for months while neither had run once.

Related: [[prefer-existing-tooling]] is the same economy from the other side: what we don't build
we don't have to get adopted.
