---
name: update-popular-posts
description: Refresh the homepage's "~elis/popular-posts/" list using real Matomo traffic data. Use when asked to update, refresh, or recompute which blog posts are "popular", or to re-run the Matomo-based popular-posts analysis.
---

# Update popular posts from Matomo

The homepage (`themes/albatross/layouts/index.html`) renders a "Popular
posts" section from any blog post whose front matter sets a numeric
`popularRank` field (1 = most visits), sorted ascending:

```
{{ $popularPosts := where .Site.RegularPages "Params.popularrank" "!=" nil }}
{{ with sort $popularPosts "Params.popularrank" }}
```

It's empty/hidden automatically when nothing sets the field, so it's safe
to have zero, some, or all ranks change between updates.

## 1. Get a Matomo API token

This requires a bearer token for `matomo.elis.nu` (site ID `3`, from
`config.yaml`'s `params.matomo`). The user needs to generate one:

1. Log in at `https://matomo.elis.nu/`.
2. Go directly to the token page: `https://matomo.elis.nu/index.php?module=UsersManager&action=securityPage`
   (or via the UI: **Administration** (gear icon) → **Personal** → **Security**).
3. Under **Auth tokens**, create a new token — give it a description
   like "popular-posts skill" and, if offered, the shortest reasonable
   expiry, since it only needs to live long enough for this session.
4. Paste the token into the conversation.

The user must supply this fresh each time — **never write the token to a
file, commit, or memory.** It's only ever used inline in a single `curl`
call for this session. Once done, the user can revoke it from that same
Security page if they generated a long-lived one.

## 2. Pull page-view data

The endpoint is Matomo's `Actions.getPageUrls` API method, called on the
Matomo instance itself (`module=API`, not a separate REST host).
`WebFetch` cannot send custom headers, so use `curl` directly:

```bash
curl -s -H "Authorization: Bearer <TOKEN>" \
  "https://matomo.elis.nu/?module=API&method=Actions.getPageUrls&idSite=3&period=range&date=last90&format=JSON&flat=1&filter_limit=25" \
  -o /tmp/matomo-pages.json
jq -r '.[] | "\(.nb_visits)\t\(.label)"' /tmp/matomo-pages.json | sort -rn
```

`last90` is a reasonable default window; adjust if the user wants a
different period. Delete the temp file when done — it's just working
data, not something to keep around.

## 3. Pick the cutoff

Don't hardcode a fixed top-N. Look at the actual numbers for a natural
drop-off (e.g. last time: 110+ visits formed a clear top tier, then a gap
down to 88). Only blog posts count — skip `/`, `/about/`, `/tags/*`, etc.

## 4. Update front matter

For each post in the new ranking, set/update in its front matter:

```yaml
popularRank: 1   # 1 = most visits, increasing from there
```

Remove the field entirely from any post that was ranked before but no
longer makes the cutoff — don't leave stale ranks lying around.

## 5. Verify and commit

```bash
hugo --minify -d /tmp/build && grep -o '<h2>~elis/popular-posts/</h2>.\{0,900\}' /tmp/build/index.html
rm -rf /tmp/build
```

Confirm the order matches the new ranking, then commit as a `post:` or
`feat:` change per this repo's commit conventions (see root `CLAUDE.md`).
