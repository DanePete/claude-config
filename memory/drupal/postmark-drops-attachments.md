---
name: The Postmark mail plugin sends no attachments, and a webform's crash it
description: "drupal/postmark 1.x never passes attachments to the API, and webform's attachment arrays fatal its file_exists() check — tick 'Include files as attachments' on a Postmark site and the submit throws"
type: reference
---

# Postmark sends no attachments; webform's make it throw

Applies to `drupal/postmark` 1.x (checked 1.5) as the mail sender, which is how our sites send
transactional mail (see [[transactional-email-on-our-account]]).

## Two defects, one checkbox

1. **Attachments never reach Postmark.** `PostmarkMail::mail()` collects
   `$message['params']['attachments']` into `$postmark_message['attachment']`, but
   `PostmarkHandler::sendMail()` never reads that key — it calls `sendEmail()` with no
   attachments argument. Even a correctly shaped attachment is silently dropped.
2. **Webform's shape is fatal.** Webform hands attachments over as arrays
   (`filename`/`filemime`/`filepath`/`filecontent`); Postmark runs `file_exists($attachment)` on
   each, which on PHP 8 is a `TypeError` (array given). So ticking *Include files as
   attachments* on an email handler doesn't just fail to attach — the submission request throws
   at send time.

Webform offers the checkbox anyway: its `supportsAttachments()` returns TRUE whenever the
mailsystem module is installed, regardless of which sender plugin it resolves to.

## Why local doesn't show it

Locally mail goes through `php_mail` to Mailpit ([[mailsystem-per-module-overrides-defaults]]),
which never reads `params.attachments` either — the email simply arrives without the file. The
failure exists only where Postmark actually sends: dev/test/live.

## How to apply

Leave `attachments: false` on webform email handlers. The values dump already links each
upload (a private file, so the recipient logs in to open it) — the same as the warranty form's
proof of purchase. If a client genuinely needs the file in the inbox, that's a sender that
supports attachments (or a patch to postmark), not this checkbox.

Found on md (DMX careers form, resume upload), 2026-10-12.
