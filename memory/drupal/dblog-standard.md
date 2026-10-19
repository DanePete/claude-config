---
name: dblog-standard
description: Every Drupal site we maintain runs with cron logging off and a 10,000-row dblog limit; check it each update round.
metadata:
  type: project
---

# Standard log settings

Every Drupal site we maintain runs with:

| Config | Value | Default |
|---|---|---|
| `system.cron:logging` | `false` | `true` |
| `dblog.settings:row_limit` | `10000` | `1000` |

**Why:** with cron logging on, every run writes a "Starting execution of X_cron()" line per
module. On Pantheon, where cron runs often, that crowds the 1,000-row log until real errors
and 404s roll off within hours. On cal (2026-10-19) 783 of the 1,000 rows were cron lines and
live's log reached back about three hours, so an error from the morning was already gone by
afternoon. Kaza made it the standard for every site the same day.

**How to apply:** site-update checks it each round, on every plan:

```bash
ddev drush cget system.cron logging; ddev drush cget dblog.settings row_limit
ddev drush cset -y system.cron logging 0 && ddev drush cset -y dblog.settings row_limit 10000
ddev drush cex -y
```

It ships through config like any other change. If `git diff` shows nothing straight after the
export, that's Mutagen lag ([[ddev-mutagen-sync-lag]]); run `ddev mutagen sync` before
concluding it didn't write. A site whose dblog is off (syslog only) has nothing to raise;
turning cron logging off still applies.
