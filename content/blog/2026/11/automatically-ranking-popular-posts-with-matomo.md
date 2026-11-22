---
title: Automatically ranking popular posts with Matomo
date: '2026-11-17T09:00:00+0100'
tags: [Nix, Hugo, Matomo, GitHub Actions, GitHub Pages]
popularRank: 9
---

If you've been to the [start page](/) of this site lately, you may have
noticed the `~elis/popular-posts/` section. It lists the blog posts that
people actually read, based on the last 90 days of traffic. It used to
be something I updated by hand every now and then, but now it refreshes
itself every Sunday night.

## How the section works

The section is driven by a single front matter field, `popularRank`.
Any blog post that sets it is listed on the start page, sorted by the
rank:

```yaml
---
title: 'NixOS ❄: tmpfs as root'
date: '2020-05-02T10:00:00+0100'
url: /blog/2020/05/nixos-tmpfs-as-root/
tags: [NixOS, Linux, tmpfs, Impermanence]
popularRank: 2
---
```

The template in the theme picks those up, sorts them and appends any
posts marked as `featured`:

```go-html-template
{{ $popularPosts := sort (where .Site.RegularPages "Params.popularrank" "!=" nil) "Params.popularrank" }}
{{ $featuredPosts := where .Site.RegularPages "Params.featured" true }}
{{ with $popularPosts | append $featuredPosts }}
    <h2>~elis/popular-posts/</h2>
    <ul>
        {{ range . }}
            <li><a href="{{ .RelPermalink }}">{{ .Title }}</a></li>
        {{ end }}
    </ul>
{{ end }}
```

Hugo lowercases front matter keys, which is why it's `popularrank` in
the template. Because of the `with`, the whole section disappears if no
page sets either field. `.Site.RegularPages` only contains pages in the
current language, and only the English posts get ranked, so the Swedish
start page just lists the featured posts.

## Where the numbers come from

I already run a self-hosted [Matomo](https://matomo.org/) instance for
the analytics on this site, so all the data I need is there. The
`Actions.getPageUrls` API method returns visits per URL over a date
range:

```sh
curl -sSf -H "Authorization: Bearer ${token}" \
  "https://${matomo_host}/?module=API&method=Actions.getPageUrls&idSite=${site_id}&period=range&date=last${days}&format=JSON&flat=1&filter_limit=200"
```

The host and site ID are read from the `params.matomo` section of
`config.yaml`, which the theme already uses for the tracking snippet, so
there's only one place to change them.

The first few rounds of this I did by hand, pulling the numbers out of
Matomo, deciding where the cutoff should be and editing the front
matter. After doing it a few times it became clear that it's a very
mechanical process, which made it a good candidate for a script.

## The script

The script is a Nix package in `packages/update-popular-posts.nix`,
built with `writeShellApplication` so it gets `curl`, `jq`, `gawk` and
`hugo` on its `PATH` and is checked with ShellCheck at build time. Since
the flake uses [blueprint](https://github.com/numtide/blueprint), the
file is all it takes for it to show up as a package, and running it is
just:

```sh
MATOMO_TOKEN=... nix run .#update-popular-posts
```

It does roughly this:

1. Fetches the visits for the last 90 days from Matomo.
2. Normalizes every URL to a path like `/blog/2020/05/nixos-tmpfs-as-root/`
   by stripping the host, query strings and fragments, and making sure
   it ends with a slash.
3. Asks Hugo which content file each permalink belongs to.
4. Sums the visits per post, ranks them and picks a cutoff.
5. Removes every existing `popularRank` and writes the new ones.

### Mapping URLs to files

The part I like the most is step 3. Instead of trying to guess the file
name from the URL, which breaks as soon as a post sets its own `url`
(like the tmpfs post above, which lives in `content/blog/2020/` but is
published under `/blog/2020/05/`) or is a page bundle, the script asks Hugo directly using `hugo list all`.
It prints a CSV of every page with its source path, draft status,
permalink, kind and section:

```sh
hugo list all 2>/dev/null | awk -F, 'NR > 1 {
  path = $1; draft = $(NF-3); permalink = $(NF-2); kind = $(NF-1); section = $NF
  if (kind != "page" || section != "blog" || draft != "false" || path ~ /\.sv\.md$/) next
  sub(/^https?:\/\/[^\/]+/, "", permalink)
  print permalink "\t" path
}'
```

Titles can contain commas, but the last few columns never do, so
reading them from the end with `$(NF-n)` is safe. This gives a mapping
from permalink to file for published English blog posts, and everything
else in the Matomo data, such as the start page or the 3D models page,
simply falls out when it's joined with the visits.

Several Matomo rows can end up pointing at the same post, for example
with and without a trailing `index` or with different query strings, so
the visits are summed per file before sorting.

### Picking the cutoff

A fixed top 10 would sometimes include a post with barely more visits
than the ones that didn't make it. Instead the script looks at the
ranked list between position 5 and 10 and cuts where the relative drop
in visits to the next post is the largest:

```awk
{ v[NR] = $1 }
END {
  if (NR <= min) { print NR; exit }
  best = min; best_ratio = 0
  for (i = min; i <= max && i < NR; i++) {
    ratio = (v[i+1] > 0) ? v[i] / v[i+1] : 1e9
    if (ratio > best_ratio) { best_ratio = ratio; best = i }
  }
  print best
}
```

So the list is always somewhere between five and ten posts long, and it
ends at a natural boundary between tiers rather than at an arbitrary
number. The window and the range are all overridable with `DAYS`,
`MIN_POSTS` and `MAX_POSTS` if I want to experiment.

### Editing front matter

Finally the script clears all existing ranks and writes the new ones.
The edits are done with `awk` and only touch lines inside the leading
`---` block, so a post that happens to have the text `popularRank:` in
a code block won't get mangled. Clearing everything first means a post
that drops off the list loses its rank, and the diff in git shows
exactly what moved.

## Running it every week

With the script in place, the last step was a scheduled GitHub Actions
workflow:

```yaml
'on':
  schedule:
    - cron: '0 3 * * 0'  # At 03:00 on Sunday.
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-22.04
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v7
      - uses: DeterminateSystems/nix-installer-action@v23

      - run: 'nix run .#update-popular-posts'
        env:
          MATOMO_TOKEN: ${{ secrets.MATOMO_TOKEN }}

      - id: changes
        run: |
          if git diff --quiet -- content/blog; then
            echo "changed=false" >> "$GITHUB_OUTPUT"
          else
            git diff --stat -- content/blog
            echo "changed=true" >> "$GITHUB_OUTPUT"
          fi

      - if: steps.changes.outputs.changed == 'true'
        run: 'nix build'

      # Commits pushed with GITHUB_TOKEN don't trigger publish.yml, so deploy here.
      - if: steps.changes.outputs.changed == 'true'
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./result

      - if: steps.changes.outputs.changed == 'true'
        uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: 'cron(popular-posts): Refresh popular posts'
          file_pattern: 'content/blog'
```

The Matomo token lives as a repository secret and is only passed as an
environment variable to the script. If nothing changed in the ranking,
the job stops there.

One thing that's easy to miss is that pushes made with the built-in
`GITHUB_TOKEN` don't trigger other workflows. That's a deliberate
GitHub feature to avoid workflows triggering each other in a loop, but
it means that the commit made by this job would never be deployed by
my regular publish workflow. So the job builds the site and deploys it
itself, and then commits the result so the repository matches what's
live.

I also ran into a small bug on the first run. I originally had the
file pattern for the auto-commit as `content/blog/**/*.md`, which looks
right but gets expanded by the shell without `globstar`, so `**` only
matched a single directory level. Posts under year *and* month
directories were updated but never committed. Just using
`content/blog` as the pattern fixed it.

## Wrapping up

Now the section mostly takes care of itself. Every Sunday a
`cron(popular-posts): Refresh popular posts` commit shows up in the
history when the ranking has changed, and if I want to see what the
list would look like with a different window I can still run the script
locally with a token. It's a small thing, but it's nice that the start
page reflects what people actually find useful, rather than what I
remembered to update.
