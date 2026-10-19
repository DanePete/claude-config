---
name: how-they-work
description: What an August Ash standard is, how one gets made, and how a dev overrides one on a project.
metadata:
  type: project
---

# August Ash standards

A standard is the baseline every site we maintain should run with: a setting, a module, a
config shape. Each one is a memory in `memory/standards/`, listed under *August Ash
standards* in the index. Standards are guidelines, not rules. A dev may override one on any
project; the point is that every site starts from the same baseline.

**They're made as we go.** The update round is where they come from. When the round turns
up a fix that every site should have, not just this one, write it here as a standard rather
than leaving it as one site's fix. The first, [[drupal-log-settings]], came out of cal's
first POM+ round (Kaza, 2026-10-19).

**Applying them.** [site-update](../../skills/site-update/SKILL.md) walks the list every
round, on every plan, and applies any standard a site is missing in its own commit. A
standard that would take real hours on a given site is quoted rather than applied.

**Overriding one.** When a dev decides a standard doesn't fit a site, record it in that
project's `.claude/memory/standards-overrides.md`: the standard, and why. The round reads
that file and leaves the overridden standard alone, so nobody re-applies what someone
deliberately declined.

**Writing one.** Name the setting and its value, say why in one paragraph with the incident
that prompted it, and give the check-and-apply commands. Keep it to one standard per file,
so overriding one never means overriding a bundle.
