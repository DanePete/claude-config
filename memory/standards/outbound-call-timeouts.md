---
name: outbound-call-timeouts
description: Standard — every call a site makes to a third-party service during a page request has a short timeout.
metadata:
  type: project
---

# Standard: short timeouts on outbound calls

Any call a site makes to an outside service while a visitor waits (a newsletter signup, a
CRM push, a geocoder, a payment or shipping lookup) gets a short timeout: about 15 seconds
for the call and 5 for the connection. The library defaults are often far longer.

**Why:** a PHP worker held by a slow vendor serves no one else. On Pantheon's smaller plans
that's a large share of the site: cal (2026-10-19) has four workers, its Campaign Monitor
library defaults to a 120-second call and a 120-second socket timeout, the signup call was the
top entry in php-slow (8 of 23), and live ran out of workers 146 times since July. One slow
vendor afternoon can make the whole site queue. Kaza marked it Urgent.

**How to apply:** find the outbound calls (`grep -rn "Guzzle\|curl_\|CS_REST\|http_client" web/modules/custom`,
plus the contrib modules that integrate a vendor) and set each library's timeout; many read
a constant or a settings value. For Campaign Monitor:

```php
// Fail fast instead of holding one of the site's few PHP workers.
define('CS_REST_CALL_TIMEOUT', 15);
define('CS_REST_SOCKET_TIMEOUT', 5);
```

Don't route around it by queuing the call to cron unless the queue keeps every field: the
campaignmonitor module's queue mode drops the subscriber's name.

Applying it is work on the client's site, so in an audit it's a *Next* item with a Work row,
marked Urgent when the vendor is on a visitor's path and the site has few workers.
