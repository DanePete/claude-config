---
name: Proxying a Pantheon site through Cloudflare — the SSL mode decides whether it stays up
description: Orange-clouding a Pantheon domain. Flexible redirect-loops the whole site at once; Full (strict) holds only while Pantheon keeps renewing a cert it may stop renewing. Also: check the zone is proxied at all before trusting any WAF rule.
metadata:
  type: reference
---

Pantheon's docs say **Full (strict)** for a proxied ("stacked CDN") setup. Both other choices
bite, and strict has a delayed one of its own.

## Flexible (or "Automatic" picking it) takes the site down instantly

Cloudflare talks to Pantheon over plain HTTP; Pantheon's platform redirects HTTP to HTTPS; the
browser comes back through Cloudflare over HTTP again. Every URL answers `301` with a
`Location` equal to **itself** — a 301 to the identical `https://` URL, carrying an
`x-pantheon-styx-hostname` header, is this and nothing else. Set SSL/TLS to **Custom → Full
(strict)**; "Automatic SSL/TLS" must be switched off first or it chooses for you.

On cal (2026-10-15) the proxy was flipped with the mode still at its default and the site was
down until it changed. Set the mode **before** flipping the cloud, not after.

## Full (strict) has a date on it

Strict validates the origin cert, and the origin cert is Pantheon's Let's Encrypt one. Once DNS
points at Cloudflare, `terminus domain:dns <site>.live` reports every record `action_required`
("Update to required value") — harmless for serving, but Pantheon issues certs only for domains
it can verify, so **renewal likely stops**. When that cert expires, strict refuses it and the
site goes down, months after the change that caused it.

Unconfirmed either way as of writing: Pantheon's docs neither promise nor deny renewal through
the proxy. So, on any newly proxied Pantheon site:

- Note the origin cert's `notAfter` (`openssl s_client … | openssl x509 -noout -enddate` while
  still grey-clouded, or `terminus domain:list` + Pantheon's dashboard after).
- ~30 days before it, check whether it moved. Renewed → nothing to do.
- Not renewed → drop to **Full** (still encrypted, no validation). Pantheon won't accept a
  Cloudflare Origin CA cert on standard plans, so strict can't be rescued with a different cert.
- Keep `/.well-known/` skipped above any geo rule regardless — see [[waf-blocks-acme-renewal]].

Update this note with the outcome once one is observed (cal's cert: Jan 12 2027).

## Rules on a grey-clouded zone do nothing

A zone can hold a full set of custom rules while its records are DNS-only, and none of them
apply. cal had geo, cron and RSS rules sitting inert because someone had unproxied it. Before
reasoning about what a rule does to traffic, confirm the zone is in the path: `dig +short A`
returns `104.x`/`172.6x.x`, not a Pantheon address (`23.185.0.x`, or `185.178.196.x` on
Pantheon's newer edge).

**Cloudflare headers don't prove it.** Pantheon's newer edge is itself Cloudflare-backed:
a DNS-only site answering from `185.178.196.x` still sends `cf-ray`, `cf-cache-status: HIT`
and `cf-mitigated: challenge` (Pantheon's bot protection). On cal (2026-10-19) that read as
"the client's Cloudflare caches HTML with no purge", and a 3-hour purge-on-save fix was
nearly quoted. That cache is Pantheon's, and Pantheon Advanced Page Cache already purges it
on save: re-saving a listing on dev turned a 20-second-old HIT into a MISS on the next
request. Most of our client zones don't cache HTML at all (Kaza). Decide from the DNS answer.

Cloudflare IPs in the origin's X-Forwarded-For are **not** proof — other services hosted on
Cloudflare (Workers, WARP) call the site from those ranges too.

Visitor IPs once proxied: [[visitor-ip-behind-cloudflare]].
