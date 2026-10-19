---
name: A scheduled transition with no state saves a revision every cron run
description: Scheduler + content moderation; cron logs "Unpublishing failed for X … returned a failure code" forever and the node quietly grows tens of thousands of revisions
type: reference
---

Scheduler retries a failed transition by restoring `unpublish_on`/`publish_on` and **saving the
node**, and under content moderation every save is a new revision. A failure that never clears
saves a revision on every cron run, forever. The only outward sign is a warning per run:
`Unpublishing failed for %title. scheduler_content_moderation_integration_scheduler_unpublish_process returned a failure code.`

## The usual cause

scheduler_content_moderation_integration (SCMI) returns `-1` when the node's
`unpublish_state`/`publish_state` is empty: there's no transition to a NULL state. Its own
validator **skips** an empty state ("No need to validate if a moderation state has not been
set"), so an editor can schedule a date with no state and the form accepts it.

On sites carried over from Scheduler 1.x it's usually made worse by a leftover legacy
`hook_scheduler_{publish,unpublish}_action` that forces `moderation_state` and returns 1. That
hook was the workaround before SCMI 2+/Scheduler 2. Now it archives the node (so the site looks
right) while SCMI still fails and the loop keeps running. On metro (2026-10-16) two events had
**~99.5k revisions each**, 92% of all `node_revision` rows, and loading them timed out MySQL
inside cron.

## Check

```sql
SELECT nid, COUNT(*) c FROM node_revision GROUP BY nid ORDER BY c DESC LIMIT 5;
SELECT nid, type, unpublish_on, unpublish_state, publish_on, publish_state
  FROM node_field_data WHERE unpublish_on IS NOT NULL OR publish_on IS NOT NULL;
```

Also `grep -rn "scheduler_.*publish_action" web/modules/custom`.

## Fix

- Stop the loop: clear the date on the stuck nodes (`setSyncing(TRUE)` so that save adds no
  revision).
- Delete the legacy action hooks; let SCMI own the transition.
- Default an empty state when a date is set (`published` / `archived`) in an **entity builder**
  on the node form, so SCMI's validator sees it, *and* in presave for programmatic saves.
  metro_alterations (`72b3eb140`) is the reference. With the builder, a draft scheduled to
  unpublish is refused at save time where it used to loop, because editorial has no
  draft→archived transition.
- Purge the junk with `$storage->deleteRevision()`, which also takes the content_moderation_state
  revisions. On Pantheon live that runs at only ~15 revisions/s (about 100/s on ddev), so
  budget hours for 200k, run it in batches of separate requests, and don't overlap a deploy:
  the container swap SIGKILLs the running batch.
