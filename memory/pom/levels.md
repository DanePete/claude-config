---
name: pom-levels
description: The POM maintenance plans, what each adds, and which clients are on which. Read before a site-update round to know what the round owes, and before offering a client a higher plan.
metadata:
  type: project
---

# POM plans

Each plan includes everything in the one before it.

| Plan | Adds | Status |
|---|---|---|
| **POM** | Updates and defense: the [site-update](../../skills/site-update/SKILL.md) round. | Live. Every client not listed below. |
| **POM+** | Every round: access log and error log review, performance across the cache layers (host, site, CDN), bot protection, SEO audit. Quarterly: an accessibility scan; the first year opens with a full audit and a year plan. Procedure: [pom-plus](../../skills/pom-plus/SKILL.md). | Live. |
| **POM+FR** | First Response: monitoring and response (Vincent). | **Not yet approved.** Recorded here only. Never name or offer it in a client document until it is. |

## Clients on POM+

ABDO, CAL, GIF, LOFT, NORTH, TCF

The code is the project's short name, upper-cased (`cal` → CAL). Every other client is on
POM. When a client moves plans, edit this list; the accessibility tracker
([accessibility.json](accessibility.json)) gains or loses their key at the same time.

## Offering the next plan

A client document may offer the next plan up, and only when it is the right plan for that
site. A commerce site, or one carrying real traffic, sensitive forms or a history of bot
trouble, likely belongs higher. A small brochure site with little traffic likely doesn't, and
then nothing is offered. While POM+FR is unapproved, the most a document offers is POM+.

**Why:** Kaza's rule (2026-10-19). "If we're having them pay more for something of little
value, we're not helping them, we're helping ourselves. If we are more important than them, it
will come out eventually, and they will not want to work with someone that behaves like that."
He treats clients the way he would want to be treated. It is the same aim as client-report's
opening: help the client grow, and the work follows.
