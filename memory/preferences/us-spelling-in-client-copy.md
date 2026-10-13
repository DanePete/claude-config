---
name: Write client copy in the client's English
description: "Before writing any copy a visitor reads on a client site: page text, labels, messages, alt text, field labels. Claude drifts into British spelling, and a client's own audit caught it."
type: feedback
---

# Write client copy in the client's English

Our clients are US companies, so anything a visitor or editor reads is US spelling: color, behavior,
labor, honor, labeled, canceled, gray, center, catalog, -ize. That covers page copy, component
props, product text, form labels and messages, field labels, and alt text.

**Why:** Claude drifts into British spelling when it writes long-form copy. On md (DMX Power,
2026-10), an audit the client ran on live flagged "labour", "behaviour", "behavioural",
"honouring", "labelled" and "grey" in the warranty, privacy and support pages and a product body,
plus "Map colour" on an admin field label. We had written all of them. That was one of only two
real issues in an otherwise strong audit, the other being alt text, so it was the kind of
avoidable flaw that undercuts good work. See [[fix-what-nobody-sees]].

**How to apply:**

- Use US spelling in every string that renders: twig, `t()`, config labels, content written by
  deploy hooks, and webform messages.
- Code identifiers and comments can stay as they are (`field_map_colour`, `colourOf()`). Renaming
  a machine name to fix spelling costs a migration and buys nothing.
- When you finish a copy-heavy piece, grep it for `our\b|ise\b|isation|lled\b|grey|centre|
  catalogue|whilst`.
- Copy the client wrote themselves, such as their legal terms, is theirs. Flag it; don't silently
  respell it.
