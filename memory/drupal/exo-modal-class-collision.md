---
name: An exo modal whose class is another modal's id is deleted
description: exo_modal finds a modal's element by a CLASS named for its id and removes every match but the first, so a shared or reused class silently deletes another modal from the page
type: reference
---

`ExoModal.getElement()` (exo_modal `src/ts/exo.modal/_exo.modal.ts`) looks a
modal's markup up by **class**, not id: `$('.' + id.replace(/_/g, '-'))`. The
server puts that class on every modal (`ExoModal::addModalClass($id)` under the
hood). Because a cached page can hold a modal twice, it then **removes every
match after the first**.

So any other element carrying a class equal to some modal's id is taken for a
duplicate of that modal. Whichever comes later in the DOM is deleted the first
time the earlier modal is looked up. Nothing is logged.

## How it shows

Seen on sisal (2026-10-15): two modals, `sisal-search-size-modal` and
`sisal-list-size-modal`, both given `addModalClass('sisal-search-size-modal')`
as a shared styling hook. The list page's modal was in the server HTML, its
settings were in drupalSettings, and `Drupal.ExoModal.getById()` resolved it,
but the element was gone. `open()` then died on
`this.$overlay is undefined`, and the trigger did nothing at all.

Diagnose by comparing a `fetch(location.href)` of the page against the live
DOM: present in the HTML, absent from the document, means something removed it.

## Rule

A class shared between modals, or given to any element near one, must not
equal any modal's id (underscores read as hyphens). Give shared hooks a name
no modal is ever called, such as `sisal-size-modal` beside ids ending
`-size-modal`, and leave a comment saying why, since the obvious name is the
broken one.
