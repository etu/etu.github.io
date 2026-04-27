{ pkgs, ... }:
pkgs.writers.writePython3Bin "compute-colors"
  {
    libraries = [ pkgs.python3Packages.ruamel-yaml ];
  }
  ''
    import sys
    import colorsys
    from ruamel.yaml import YAML

    # --- color math ---


    def _parse(h):
        h = h.lstrip("#")
        return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


    def _hex(r, g, b):
        return "#{:02X}{:02X}{:02X}".format(
            int(round(r)), int(round(g)), int(round(b))
        )


    def _lin(c):
        c /= 255
        return c / 12.92 if c < 0.04045 else ((c + 0.055) / 1.055) ** 2.4


    def _lum(r, g, b):
        return 0.2126 * _lin(r) + 0.7152 * _lin(g) + 0.0722 * _lin(b)


    def _contrast(bg, fg):
        lb, lf = _lum(*bg) + 0.05, _lum(*fg) + 0.05
        return max(lb, lf) / min(lb, lf)


    def darken(color, pct):
        r, g, b = _parse(color)
        hue, lit, sat = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        r2, g2, b2 = colorsys.hls_to_rgb(hue, max(0.0, lit - pct / 100), sat)
        return _hex(r2 * 255, g2 * 255, b2 * 255)


    def lighten(color, pct):
        r, g, b = _parse(color)
        hue, lit, sat = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        r2, g2, b2 = colorsys.hls_to_rgb(hue, min(1.0, lit + pct / 100), sat)
        return _hex(r2 * 255, g2 * 255, b2 * 255)


    def contrast_color(fg_hex, bg_hex, min_contrast=7.0):
        fg = list(_parse(fg_hex))
        bg = list(_parse(bg_hex))
        max_contrast = min_contrast + 0.1
        is_dark_bg = _lum(*bg) < 0.5
        c = _contrast(bg, fg)
        for _ in range(300):
            if min_contrast <= c <= max_contrast:
                break
            hue, lit, sat = colorsys.rgb_to_hls(
                fg[0] / 255, fg[1] / 255, fg[2] / 255
            )
            delta = abs(min_contrast - c) * 0.01
            darken_fg = (
                (is_dark_bg and c > max_contrast)
                or (not is_dark_bg and c < min_contrast)
            )
            if darken_fg:
                lit = max(0.0, lit - delta)
            else:
                lit = min(1.0, lit + delta)
            r2, g2, b2 = colorsys.hls_to_rgb(hue, lit, sat)
            fg = [r2 * 255, g2 * 255, b2 * 255]
            c = _contrast(bg, fg)
        return _hex(*fg)


    # --- derive all style values from colors ---


    def compute_style(c):
        lb = c["light-background-color"]
        lm = c["light-menu-background"]
        db = c["dark-background-color"]
        dm = c["dark-menu-background"]
        lmhb = darken(lm, 5)
        dmhb = lighten(dm, 5)
        ll = c["light-link-intent"]
        lv = c["light-link-visited-intent"]
        dl = c["dark-link-intent"]
        dv = c["dark-link-visited-intent"]
        return {
            # typography (pass-through)
            "font-size": c["font-size"],
            "font-family": c["font-family"],
            "page-content-width-factor": c["page-content-width-factor"],
            "page-i18n-padding": c["page-i18n-padding"],
            "font-size-h1": c["font-size-h1"],
            "font-size-h2": c["font-size-h2"],
            "font-size-h3": c["font-size-h3"],
            "font-size-h4": c["font-size-h4"],
            # light — base
            "light-background-color": lb,
            "light-border-color": c["light-border-color"],
            "light-menu-background": lm,
            # light — derived
            "light-foreground-color": contrast_color("#000000", lb),
            "light-link-default-color": contrast_color(ll, lb),
            "light-link-visited-color": contrast_color(lv, lb),
            "light-menu-foreground": contrast_color(ll, lm),
            "light-menu-item-hover-background": lmhb,
            "light-menu-item-hover-foreground": contrast_color("#000000", lmhb),
            "light-tag-background-color": darken(lb, 10),
            # dark — base
            "dark-background-color": db,
            "dark-border-color": c["dark-border-color"],
            "dark-menu-background": dm,
            # dark — derived
            "dark-foreground-color": contrast_color("#FFFFFF", db),
            "dark-link-default-color": contrast_color(dl, db),
            "dark-link-visited-color": contrast_color(dv, db),
            "dark-menu-foreground": contrast_color(dl, dm),
            "dark-menu-item-hover-background": dmhb,
            "dark-menu-item-hover-foreground": contrast_color("#FFFFFF", dmhb),
            "dark-tag-background-color": lighten(db, 10),
            # code highlight (pass-through)
            "code-background-color": c["code-background-color"],
            "code-foreground-color": c["code-foreground-color"],
            "code-chroma-bg": c["code-chroma-bg"],
            "code-chroma-fg": c["code-chroma-fg"],
            "code-chroma-dark-red-fg": c["code-chroma-dark-red-fg"],
            "code-chroma-dark-red-bg": c["code-chroma-dark-red-bg"],
            "code-chroma-dark-gray-fg": c["code-chroma-dark-gray-fg"],
            "code-chroma-light-gray-fg": c["code-chroma-light-gray-fg"],
            "code-chroma-light-blue-fg": c["code-chroma-light-blue-fg"],
            "code-chroma-red-fg": c["code-chroma-red-fg"],
            "code-chroma-green-fg": c["code-chroma-green-fg"],
            "code-chroma-purple-fg": c["code-chroma-purple-fg"],
            "code-chroma-yellow-fg": c["code-chroma-yellow-fg"],
            "code-chroma-medium-gray-fg": c["code-chroma-medium-gray-fg"],
        }


    # --- main ---


    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.explicit_start = True
    yaml.width = 120

    args = sys.argv[1:]
    validate = "--validate" in args
    args = [a for a in args if a != "--validate"]
    path = args[0] if args else "config.yaml"

    with open(path) as f:
        config = yaml.load(f)

    colors = config["params"]["colors"]
    expected = compute_style(colors)

    if validate:
        actual = dict(config["params"].get("style") or {})
        diffs = {
            k: (expected[k], actual.get(k))
            for k in expected
            if str(expected[k]) != str(actual.get(k))
        }
        if diffs:
            print(f"ERROR: params.style in {path} is out of date.")
            print("Run: just compute-colors")
            for k, (exp, got) in diffs.items():
                print(f"  {k}: expected {exp!r}, got {got!r}")
            sys.exit(1)
        print(f"OK: params.style in {path} is up to date.")
    else:
        config["params"]["style"] = expected
        with open(path, "w") as f:
            yaml.dump(config, f)
        print(f"Updated style in {path}")
  ''
