---
title: My experience of migrating from Google G-Suite to ProtonMail
date: '2026-02-24T21:40:00+0100'
url: /blog/2026/02/migrating-from-g-suite-to-protonmail/
tags: [Email, Privacy]
---

For about 9 years, I've been a customer of Google G-Suite, using it
for email, file storage, and photos. I've never fully trusted them,
however I have always claimed the following.

> As a paying customer, I hope that they mine my data less than they
> do for free users.

There's a lot of uncertainty in that sentence. Words like **hope** and
**less** aren't exactly reassuring, and there's no proof it's actually
the case either. With a recent price increase warning at renewal time
and the current state of politics between the EU and USA, I decided to
switch to an EU provider.

Here’s how the journey actually went.

## 1. Planning and Preparation

At first, it seemed overwhelming. I had multiple email accounts,
shared folders, and years of accumulated emails and photos. With one
of the accounts belonging to a parent who isn't always tech-savvy, I
wanted to ensure the transition would be smooth for everyone involved.

I needed to assess:
- How many accounts I had
- How much data was stored
- Which features needed to migrate
- What could stay behind

Proton's tools for mail import, combined with manually syncing files
(via Google Takeout and upload to Proton Drive), made the transition
manageable. Proton's migration interface for email, calendar, and
contacts is excellent.

## 2. Mail / Calendar / Contacts Migration

Migrating mail from Google to Proton was straightforward with the
built-in import tools. I synced emails using a one-time import through
Proton Easy Switch, and it worked well.

It took some time, especially with large mailboxes, but it just works.

## 3. Files and Photos

Files and photos required more work. Google Takeout was useful for
export, but it comes with quirks:

Photos export with separate JSON metadata files containing timestamps
and location data, rather than embedding them in the actual images.

Without correcting EXIF metadata, Proton Photos would display
incorrect dates.

I wrote a script to read the exported JSON and embed the correct
timestamps and GPS data back into the photos before uploading. This
ensured Proton Photos would index most of them correctly.

With Proton Drive syncing files and photos locally first, uploads and
indexing afterward worked smoothly.

## 4. DNS and Cut-over

Once everything was migrated and tested, I pointed my domain’s DNS
records (MX, SPF, DKIM) to Proton. The cutover was seamless—mail flow
switched over quickly once DNS propagated.

Google G Suite stopped delivering mail at that point, as expected.

## 5. Closing Google G Suite

Here's where things got messy compared to how most subscriptions
behave.

If you have a gym membership for a year and cancel it after half a
year, one of two things would happen:

- (Most likely) You get to use the membership for the remaining period
  of time, you don't get any money back.
- (Less likely) You don't get to use the membership for the remaining
  period of time, but you do get the money back.

However, Google decided to go the third route:

- You cancel, they lock you out right away even though you've already
  pre-paid for a period of time. And they don't give you any money
  back.

However, they do warn about it. So I pressed on and canceled right
after everything was moved.

## 6. Preserving Cloud Identities

When you cancel a G Suite subscription, you'll probably still want to
keep your Google account for things like YouTube, Play Store, Sign in
with Google, and other services.

In the admin console, you can add the **Cloud Identity Free** license
type and assign it to all users.

This allows you to keep the account but with zero storage for
**Email**, **Drive**, and **Photos**. This creates a catch-22: I can't
access Gmail to delete my emails, so they remain there and I'm over my
storage limit.  But it's not actually a problem for my use case.

You can still access Google Drive, which is great for viewing shared
files and folders owned by other users.

My Sign in with Google, Play Store, and other services still work,
which is exactly what I wanted.

## 7. Final Thoughts

Overall, the migration was less risky and more straightforward than
expected once broken down into steps:

- Mail migrated reliably
- Files and photos moved with mostly correct metadata
- Accounts kept their identity without losing Play purchases or Google
  login capabilities

### 7.1 Proton Docs and Sheets

I'm fortunate not to be a demanding user of Google Docs or Sheets.  I
actually prefer Proton Docs—you can type markdown syntax and it
formats automatically, which is lovely.

Proton Sheets is more limited, and I'm a heavier user there for
personal data tracking. Some of my imported sheets needed adjustments.

But I'll adapt. It'll take some time, but it's manageable.

### 7.2 My Recommendation

Migrate first, then cancel G Suite. If you want to preserve your
Google account identity, convert to Cloud Identity Free after
canceling.

That's the cleanest path I found. It left me with Proton for daily use
and a preserved Google identity for the services I still need.
