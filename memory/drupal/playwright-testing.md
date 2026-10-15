---
name: Playwright UI test writing
description: Conventions for tests/ui Playwright suites — run resource-heavy tests serially, wait on conditions not time, warm caches before timing-sensitive tests.
type: feedback
---

Lessons for writing Playwright tests against our sites:

- **Run resource-heavy tests serially.** Tests that drive lots of backend work — paging a large listing through many renders, anything that hits PHP-FPM + Solr + first-hit image-derivative generation repeatedly — *starve each other* when run in parallel against a constrained backend. Symptom: timeout flakes / "stuck" element counts under `fullyParallel: true`, but green when run one at a time (`--workers=1`). Scope it with `test.describe.configure({ mode: 'serial' })` on the heavy describe; don't disable parallelism globally. This is a local/test resource artifact, **not** a production concern (a cache warmer + per-URL caching keep prod requests warm).

- **Wait on the observable, never a fixed delay.** (See [[no-time-based-test-waits]].) For infinite scroll: scroll, then `await locator.nth(n).waitFor()` for the next element rather than `waitForTimeout`. Keep the timeout generous so a cold render doesn't trip it, while warm runs stay fast.

- **Cold-cache first-hit is the sneaky flake.** The very first request after a cache clear pays the cold cost (full render + derivative generation), and the IntersectionObserver may not fire promptly while the page is still settling. A larger timeout helps but isn't bulletproof. The reliable fix: **warm the URLs under test in a `beforeAll`** (fetch the landing page + the AJAX/load-more pages) so tests run against the warm steady state — which is also what real users get.

- **baseURL via env.** Suites default `baseURL` to the live site and accept a `BASE_URL` override for local (e.g. the ddev URL). A feature not yet deployed must be tested against local, not live. WebKit projects need `npx playwright install webkit` before they'll run.

- **A site with `scroll-behavior: smooth` makes `window.scrollBy` glide.** The call returns at
  once while the page is still moving for ~0.5s, so a test that scrolls, then measures or scrolls
  again, races the animation: positions come back off by a varying amount and retries overshoot.
  It reads as a flaky layout bug. Scroll with `scrollBy({ top, behavior: 'instant' })` (sisal,
  2026-10-15: a sticky-bar case failed 1 in 3 with gaps of 2–176px until this; the product was
  exact all along, which a timed trace showed).

- **A local site can be 20× slower to answer a script's fetch than Pantheon.** ddev serves CSS
  and JS unaggregated (~160 requests a page against ~50), all on a few PHP workers, so a request a
  script makes during load queues behind them: 21s locally against 0.2s on a multidev. The site
  never goes `networkidle` either (third-party scripts poll). Wait on the element the fetch fills,
  with a timeout sized for local, and say why next to the constant.

- **Whether the browser revalidated a cached file can't be seen from outside.** Routing a request
  turns Playwright's HTTP cache off, and a response that varies on `Cookie` is refetched anyway
  once the site sets a cookie. A request-header assertion then passes with the fix removed. Pin
  the ask instead: wrap `window.fetch` in `addInitScript` and assert the `cache` mode it was given.
