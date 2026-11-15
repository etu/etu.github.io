---
name: update-popular-posts
description: Refresh the homepage's "~elis/popular-posts/" list using real Matomo traffic data. Use when asked to update, refresh, or recompute which blog posts are "popular", or to re-run the Matomo-based popular-posts analysis.
---

# Update popular posts from Matomo

The homepage (`themes/albatross/layouts/index.html`) renders a "Popular
posts" section from any blog post whose front matter sets a numeric
`popularRank` field (1 = most visits), sorted ascending, followed by any
featured posts. It's hidden automatically when nothing sets either, so
it's safe to have zero, some, or all ranks change between updates.

This already runs automatically every Sunday at 03:00 UTC via
`.github/workflows/popular-posts.yml` (using the `MATOMO_TOKEN` repo
secret), which also deploys and commits the result. Only run it locally
when the user wants an ad-hoc refresh or a different window. To just
trigger the CI job instead, use `gh workflow run popular-posts.yml`.

## 1. Get a Matomo API token

This requires a bearer token for `matomo.elis.nu` (site ID `3`, from
`config.yaml`'s `params.matomo`). The user needs to generate one:

1. Log in at `https://matomo.elis.nu/`.
2. Go directly to the token page: `https://matomo.elis.nu/index.php?module=UsersManager&action=userSecurity`
   (or via the UI: **Administration** (gear icon) → **Personal** → **Security**).
3. Under **Auth tokens**, create a new token — give it a description
   like "popular-posts skill" and, if offered, the shortest reasonable
   expiry, since it only needs to live long enough for this session.
4. Paste the token into the conversation.

The user must supply this fresh each time — **never write the token to a
file, commit, or memory.** It's only ever passed inline to the command
below for this session. Once done, the user can revoke it from that same
Security page if they generated a long-lived one.

## 2. Run the update

```bash
MATOMO_TOKEN=<TOKEN> nix run .#update-popular-posts
```

The script (`packages/update-popular-posts.nix`) fetches page views from
Matomo, maps them to published English blog posts, picks a cutoff at the
largest relative drop in visits between positions 5 and 10, clears all
existing `popularRank` fields, and writes the new ranks. It prints the
top posts with visit counts and the ranks it applied.

Optional environment overrides:

- `DAYS` — lookback window (default `90`)
- `MIN_POSTS` / `MAX_POSTS` — range the cutoff is chosen from (default `5` / `10`)

Show the user the printed ranking and the cutoff it chose.

## 3. Verify and commit

```bash
git diff -- content/blog
hugo --minify -d /tmp/build && grep -o '<h2>~elis/popular-posts/</h2>.\{0,900\}' /tmp/build/index.html
rm -rf /tmp/build
```

Confirm the order matches the new ranking, then commit as a `feat:`
change per this repo's commit conventions (see root `CLAUDE.md`).
