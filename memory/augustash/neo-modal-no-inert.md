---
name: neo_modal focus — Tab is trapped since 1.0.83, focus return on close is not
description: "Closing a neo modal leaves focus on <body>; also before reaching for inert to keep focus in a modal, and before reusing md's modal-inert.js."
type: project
---

# neo_modal focus: Tab is trapped since 1.0.83, focus return on close is not

Before **neo_modal 1.0.83**, Tab walked out of an open modal into the page, or into the faded
modal underneath with a nested one. 1.0.83 (`a9a8885`, 2026-10-15) fixes that with a
document-level Tab handler that wraps Tab at the top modal's edges. It makes nothing inert.

**Don't make the page inert to keep focus in a modal.** That was our first fix: md's
`web/modules/custom/md_core/js/modal-inert.js` (DMX Power, 2026-10-13), and our upstream PR
built on `contain()`. jacerider rejected the PR because inert also kills clicks, and libraries
render popups for fields inside the modal into `<body>`: CKEditor 5 balloons, autocomplete
menus, tooltips, select dropdowns. Upstream's wrap leaves focus alone whenever it sits
outside the modal, so those popups keep working.

**Still unfixed upstream:** closing a modal leaves focus on `<body>`, not on the link that
opened it. md's script also does this, by snapshotting the focused element when a modal opens
over a layer.

Building on neo: `NeoModal::restack()` stamps every modal below the top with
`data-neo-modal--depth`. The `.neo-modals` wrapper is **removed when the last modal closes**
and recreated on the next open, so an observer attached to the first wrapper silently goes
deaf after one open/close cycle.

**How to apply:** once md is on ≥1.0.83, cut `modal-inert.js` down to the focus-return part
(the inert half now duplicates the trap and breaks body-level popups), and drop it entirely
once neo returns focus itself. Don't reuse the inert script on another neo site. When testing
focus in headless Firefox, a scripted `focus()` fires no `focusin` while the window lacks
system focus, so design around what is focused at the moment a modal opens rather than
tracking focus events.
