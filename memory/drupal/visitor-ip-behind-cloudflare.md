---
name: Visitor IPs behind Cloudflare go through reverse_proxy, not a $_SERVER rewrite
description: Drupal logs and flood control see Cloudflare edge IPs on a proxied site. The widely-pasted CF-Connecting-IP → REMOTE_ADDR snippet in settings.php is too late on D8+; use reverse_proxy with Cloudflare's ranges.
metadata:
  type: reference
---

On a Cloudflare-proxied Pantheon site, `REMOTE_ADDR` is the Cloudflare edge. Watchdog, flood
control (login lockouts lumping strangers together) and ban all key on it.

**The common fix doesn't work on D8+.** `$_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_CF_CONNECTING_IP']`
in settings.php runs after `index.php` has already built the Request from `$_SERVER`; the
request's ServerBag is a copy, so `getClientIp()` never sees the change.

What works, in settings.php:

```php
$settings['reverse_proxy'] = TRUE;
$settings['reverse_proxy_addresses'] = [/* https://www.cloudflare.com/ips/ — v4 and v6 CIDRs */];
$settings['reverse_proxy_trusted_headers'] = \Symfony\Component\HttpFoundation\Request::HEADER_X_FORWARDED_FOR;
```

Symfony walks X-Forwarded-For right to left, dropping trusted addresses, and returns the first
untrusted one. Because it only reads the header when `REMOTE_ADDR` is itself a Cloudflare
address, a forged XFF can't claim an IP, and an un-proxied environment (local, dev) is
untouched. Limiting trusted headers to `FOR` keeps it from also trusting forwarded host/proto.

Pantheon delivers `client, cf-edge, cf-edge` to PHP with `REMOTE_ADDR` = the edge (visible as
the last quoted field of its nginx log, plus the 10.x LB). Verified against that shape on
sisal/cal 2026-10-15, including a spoofed header — reusable as a `Request::create()` check with
the site's own `vendor/autoload.php`.

Background on the proxy itself: [[proxying-pantheon-ssl-mode]].
