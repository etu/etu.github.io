{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "update-popular-posts";
  runtimeInputs = [
    pkgs.curl
    pkgs.jq
    pkgs.gawk
    pkgs.hugo
    pkgs.coreutils
    pkgs.gnugrep
  ];
  text = ''
    # Refresh `popularRank` front matter on blog posts from Matomo page views.
    #
    # Usage: update-popular-posts <matomo-token>
    #    or: MATOMO_TOKEN=... update-popular-posts
    #
    # Optional env: DAYS (default 90), MIN_POSTS (default 5), MAX_POSTS (default 10)

    token="''${1:-''${MATOMO_TOKEN:-}}"
    if [[ -z "''${token}" ]]; then
      echo "Usage: update-popular-posts <matomo-token>  (or set MATOMO_TOKEN)" >&2
      exit 1
    fi

    days="''${DAYS:-90}"
    min_posts="''${MIN_POSTS:-5}"
    max_posts="''${MAX_POSTS:-10}"

    root="$(git rev-parse --show-toplevel)"
    cd "''${root}"

    matomo_host=$(awk '/^  matomo:/{f=1;next} f&&/^    url:/{print $2;exit}' config.yaml)
    site_id=$(awk '/^  matomo:/{f=1;next} f&&/^    siteId:/{gsub(/\x27|"/,"",$2);print $2;exit}' config.yaml)

    tmpdir=$(mktemp -d)
    trap 'rm -rf "''${tmpdir}"' EXIT

    echo "Fetching last ''${days} days of page views from ''${matomo_host} (site ''${site_id})..."
    curl -sSf -H "Authorization: Bearer ''${token}" \
      "https://''${matomo_host}/?module=API&method=Actions.getPageUrls&idSite=''${site_id}&period=range&date=last''${days}&format=JSON&flat=1&filter_limit=200" \
      -o "''${tmpdir}/matomo.json"

    if jq -e 'type == "object" and .result == "error"' "''${tmpdir}/matomo.json" >/dev/null; then
      echo "Matomo API error: $(jq -r .message "''${tmpdir}/matomo.json")" >&2
      exit 1
    fi

    # Normalize every row to "<path>\t<visits>", where path is like /blog/.../
    jq -r '.[]
      | ((.url // .label)
          | sub("^[a-z]+://[^/]+"; "")
          | sub("[?#].*$"; "")
          | sub("/index$"; "/")
          | (if startswith("/") then . else "/" + . end)
          | (if endswith("/") then . else . + "/" end)) as $path
      | "\($path)\t\(.nb_visits)"' "''${tmpdir}/matomo.json" > "''${tmpdir}/visits.tsv"

    # Map permalink path -> content file for published English blog posts.
    # `hugo list all` is CSV; path is the first column and permalink/kind/section
    # are the last columns, none of which contain commas.
    hugo list all 2>/dev/null | awk -F, 'NR > 1 {
      path = $1; draft = $(NF-3); permalink = $(NF-2); kind = $(NF-1); section = $NF
      if (kind != "page" || section != "blog" || draft != "false" || path ~ /\.sv\.md$/) next
      sub(/^https?:\/\/[^\/]+/, "", permalink)
      print permalink "\t" path
    }' > "''${tmpdir}/posts.tsv"

    # Sum visits per post (multiple Matomo rows can map to the same page),
    # sorted by visits descending: "<visits>\t<file>"
    awk -F'\t' '
      NR == FNR { file[$1] = $2; next }
      ($1 in file) { visits[file[$1]] += $2 }
      END { for (f in visits) print visits[f] "\t" f }
    ' "''${tmpdir}/posts.tsv" "''${tmpdir}/visits.tsv" \
      | sort -t$'\t' -k1,1nr -k2,2 > "''${tmpdir}/ranked.tsv"

    echo
    echo "Top blog posts by visits:"
    head -n $((max_posts + 3)) "''${tmpdir}/ranked.tsv" | awk -F'\t' '{printf "  %3d. %6d  %s\n", NR, $1, $2}'

    count=$(wc -l < "''${tmpdir}/ranked.tsv")
    if (( count < min_posts )); then
      echo "Only ''${count} blog posts found in Matomo data, need at least ''${min_posts}; aborting." >&2
      exit 1
    fi

    # Pick the cutoff at the largest relative drop in visits between
    # positions MIN_POSTS..MAX_POSTS (a natural tier boundary).
    cutoff=$(awk -F'\t' -v min="''${min_posts}" -v max="''${max_posts}" '
      { v[NR] = $1 }
      END {
        if (NR <= min) { print NR; exit }
        best = min; best_ratio = 0
        for (i = min; i <= max && i < NR; i++) {
          ratio = (v[i+1] > 0) ? v[i] / v[i+1] : 1e9
          if (ratio > best_ratio) { best_ratio = ratio; best = i }
        }
        print best
      }' "''${tmpdir}/ranked.tsv")

    echo
    echo "Cutoff: top ''${cutoff} posts"

    # Front matter helpers: only touch lines inside the leading --- block.
    remove_rank() {
      awk '
        NR == 1 && /^---[[:space:]]*$/ { fm = 1; print; next }
        fm && /^---[[:space:]]*$/ { fm = 0; print; next }
        fm && /^popularRank:/ { next }
        { print }
      ' "$1" > "''${tmpdir}/edit" && cat "''${tmpdir}/edit" > "$1"
    }

    set_rank() {
      awk -v rank="$2" '
        NR == 1 && /^---[[:space:]]*$/ { fm = 1; print; next }
        fm && /^---[[:space:]]*$/ { fm = 0; print "popularRank: " rank; print; next }
        { print }
      ' "$1" > "''${tmpdir}/edit" && cat "''${tmpdir}/edit" > "$1"
    }

    # Clear stale ranks everywhere, then apply the new ones.
    grep -rl --include='*.md' '^popularRank:' content/blog | while read -r file; do
      remove_rank "''${file}"
    done

    rank=0
    head -n "''${cutoff}" "''${tmpdir}/ranked.tsv" | while IFS=$'\t' read -r _ file; do
      rank=$((rank + 1))
      set_rank "''${file}" "''${rank}"
      echo "  popularRank: ''${rank}  ''${file}"
    done

    echo
    echo "Done. Review with: git diff -- content/blog"
  '';
}
