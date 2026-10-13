---
name: A fixed media alt still renders the old one
description: "An image's alt is corrected on the media entity and pages keep printing the old text. The media_thumbnail formatter reads a second copy."
type: project
---

# A fixed media alt still renders the old one

A media image carries its alt twice: on the source field (`field_media_image.alt`) and on the
media's own `thumbnail` field. The **media_thumbnail** formatter, the usual way a media
reference is rendered on cards and product pages, prints the `thumbnail` alt. Media only
copies the source alt into the thumbnail when the source FILE changes
(`Media::updateThumbnail()`), so a corrected alt, whether set in a script or in the form,
changes the edit screen and nothing on the page.

**Why:** On md (DMX Power, 2026-10-13) a deploy hook rewrote 155 filename alts ("IMG_1585.jpg")
on `field_media_image`. The DB showed the new text, cache was cleared, and every product
page still printed the filenames. The rendered alt came from `media_field_data.thumbnail__alt`.

**How to apply:**

- When you write an alt in code, set both: `$item->set('alt', $alt)` on the source field and
  `$media->get('thumbnail')->first()->set('alt', $alt)`, then save.
- When diagnosing, check `thumbnail__alt` in `media_field_data` before blaming a cache.
- A migration that copies filenames into alts leaves both copies stale. Fix both in the same
  pass, and let an editor's own alt on the source field win, with the thumbnail following it.
