---
name: neo_modal lets Tab out of an open modal
description: "Tab walks out of a neo modal into the page or the modal underneath, and closing one leaves focus on <body>."
type: project
---

# neo_modal lets Tab out of an open modal

neo_modal marks each modal `role="dialog" aria-modal="true"` but makes nothing behind it
inert, so keyboard focus walks out of an open modal into the page. With a nested modal it
walks into the faded modal underneath, including its form. Closing a modal also leaves focus
on `<body>` instead of on the link that opened it.

What neo does give you to build on:

- `NeoModal::restack()` stamps every modal below the top with `data-neo-modal--depth`, so the
  top one is the open `.neo-modal` without that attribute.
- The `.neo-modals` wrapper is **removed when the last modal closes** and recreated on the next
  open. An observer attached to the first wrapper silently goes deaf after one open/close cycle.

**Why:** Found on md (DMX Power, 2026-10-13): the careers modal opens a position modal over
itself. The site fix is `web/modules/custom/md_core/js/modal-inert.js`. It makes the page,
the toolbars and the modals underneath inert, snapshots the focused element when a modal
opens over a layer, and returns focus to it when that modal closes.

**How to apply:** On another neo site, reuse that script rather than writing a new one. The
real fix belongs in neo_modal, so propose it to Cyle as a Neo PR. When testing it in headless Firefox,
note that a scripted `focus()` fires no `focusin` while the window lacks system focus, so
design around what is focused at the moment a modal opens rather than tracking focus events.
