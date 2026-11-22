#!/usr/bin/env python3
"""Kio stock images: find free stock photos for a page and emit ready-to-paste HTML + credits.

Providers (picked automatically, or with --provider):
  unsplash   needs UNSPLASH_ACCESS_KEY. Unsplash API guidelines: hotlink the returned image
             URLs (never re-host), trigger the photo's download_location when it is used, and
             credit "Photo by <name> on Unsplash" with utm_source/utm_medium=referral links.
  pexels     needs PEXELS_API_KEY. Pexels guidelines: link to Pexels prominently and credit the
             photographer where possible. Downloading and self-hosting is allowed.
  openverse  no key. Openly licensed images (CC0, public domain, CC BY, CC BY-SA) filtered to
             commercial use. Downloading is allowed; the attribution line is mandatory except for
             CC0/PDM.

Usage:
  stock_images.py search "nail salon manicure" --count 6 [--provider auto] [--orientation landscape]
  stock_images.py fetch  "spa massage stones" --name hero --out assets/img [--width 1600] \
                         [--alt "Phòng massage đá nóng"] [--eager]

`fetch` picks the best result, downloads it when the provider allows (Pexels, Openverse) or
builds hotlink URLs (Unsplash), prints an <img> snippet with width/height/srcset/alt, and appends
the credit to <out>/CREDITS.json and <out>/CREDITS.html. Stdlib only; Pillow, if installed,
converts downloads to WebP at several widths.
"""
from __future__ import annotations

import argparse

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

APP_NAME = os.environ.get("KIO_STOCK_APP_NAME", "kio_frontend_craft")
UA = "kio-frontend-craft-stock-images/1.0"
TIMEOUT = 20


class StockError(RuntimeError):
    pass


def _get(url: str, headers: dict | None = None) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA, **(headers or {})})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
            return r.read()
    except urllib.error.HTTPError as e:
        hint = {401: "API key missing or invalid", 403: "forbidden (key, quota or blocked host)",
                429: "rate limited; wait and retry or use another provider"}.get(e.code, "")
        raise StockError(f"HTTP {e.code} from {urllib.parse.urlsplit(url).netloc} {hint}".strip()) from None
    except urllib.error.URLError as e:
        raise StockError(f"cannot reach {urllib.parse.urlsplit(url).netloc}: {e.reason} "
                         "(no network, proxy or firewall?)") from None


def _get_json(url: str, headers: dict | None = None) -> dict:
    return json.loads(_get(url, headers).decode("utf-8"))


def attr(value: str) -> str:
    """Attribute/text value without HTML entities: keep '&' and accents as real characters
    (valid in HTML5); only a double quote would end the attribute, so swap it for a typographic one."""
    return str(value).replace('"', "”").replace("<", "‹").replace(">", "›")


def _utm(url: str) -> str:
    sep = "&" if "?" in url else "?"
    return f"{url}{sep}utm_source={APP_NAME}&utm_medium=referral"


# --- providers -----------------------------------------------------------------------------
def search_unsplash(query: str, count: int, orientation: str | None) -> list[dict]:
    key = os.environ.get("UNSPLASH_ACCESS_KEY")
    if not key:
        raise StockError("UNSPLASH_ACCESS_KEY is not set")
    params = {"query": query, "per_page": min(count, 30), "content_filter": "high"}
    if orientation:
        params["orientation"] = orientation
    data = _get_json("https://api.unsplash.com/search/photos?" + urllib.parse.urlencode(params),
                     {"Authorization": f"Client-ID {key}", "Accept-Version": "v1"})
    out = []
    for p in data.get("results", []):
        out.append({
            "provider": "unsplash", "id": p["id"], "width": p["width"], "height": p["height"],
            "alt": p.get("alt_description") or p.get("description") or "",
            "raw": p["urls"]["raw"], "download": None, "hotlink_only": True,
            "download_location": p["links"].get("download_location"),
            "page": _utm(p["links"]["html"]),
            "author": p["user"]["name"], "author_url": _utm(p["user"]["links"]["html"]),
            "license": "Unsplash License", "license_url": "https://unsplash.com/license",
            "credit_html": (f'Photo by <a href="{attr(_utm(p["user"]["links"]["html"]))}">'
                            f'{attr(p["user"]["name"])}</a> on '
                            f'<a href="{attr(_utm("https://unsplash.com/"))}">Unsplash</a>'),
        })
    return out


def search_pexels(query: str, count: int, orientation: str | None) -> list[dict]:
    key = os.environ.get("PEXELS_API_KEY")
    if not key:
        raise StockError("PEXELS_API_KEY is not set")
    params = {"query": query, "per_page": min(count, 80)}
    if orientation:
        params["orientation"] = {"squarish": "square"}.get(orientation, orientation)
    data = _get_json("https://api.pexels.com/v1/search?" + urllib.parse.urlencode(params),
                     {"Authorization": key})
    out = []
    for p in data.get("photos", []):
        out.append({
            "provider": "pexels", "id": str(p["id"]), "width": p["width"], "height": p["height"],
            "alt": p.get("alt") or "", "raw": None, "download": p["src"]["original"],
            "sizes": {"640": p["src"].get("medium"), "940": p["src"].get("large"),
                      "1880": p["src"].get("large2x")},
            "hotlink_only": False, "page": p["url"],
            "author": p["photographer"], "author_url": p["photographer_url"],
            "license": "Pexels License", "license_url": "https://www.pexels.com/license/",
            "credit_html": (f'Photo by <a href="{attr(p["photographer_url"])}">'
                            f'{attr(p["photographer"])}</a> on '
                            f'<a href="https://www.pexels.com">Pexels</a>'),
        })
    return out


def search_openverse(query: str, count: int, orientation: str | None) -> list[dict]:
    params = {"q": query, "page_size": min(count * 2, 40), "license_type": "commercial",
              "mature": "false"}
    if orientation:
        params["aspect_ratio"] = {"landscape": "wide", "portrait": "tall", "squarish": "square"}[orientation]
    data = _get_json("https://api.openverse.org/v1/images/?" + urllib.parse.urlencode(params))
    out = []
    for p in data.get("results", []):
        if not p.get("url") or not p.get("width"):
            continue
        lic = (p.get("license") or "").lower()
        lic_name = "CC0" if lic == "cc0" else "Public Domain Mark" if lic == "pdm" else \
            f"CC {lic.upper()} {p.get('license_version') or ''}".strip()
        author = p.get("creator") or "Unknown author"
        title = p.get("title") or "Image"
        author_html = (f'<a href="{attr(p["creator_url"])}">{attr(author)}</a>'
                       if p.get("creator_url") else attr(author))
        out.append({
            "provider": "openverse", "id": p["id"], "width": p["width"], "height": p["height"],
            "alt": title, "raw": None, "download": p["url"], "hotlink_only": False,
            "page": p.get("foreign_landing_url") or p["url"], "author": author,
            "author_url": p.get("creator_url"), "license": lic_name, "license_url": p.get("license_url"),
            "credit_html": (f'"<a href="{attr(p.get("foreign_landing_url") or p["url"])}">'
                            f'{attr(title)}</a>" by {author_html}, '
                            f'<a href="{attr(p.get("license_url") or "")}">{attr(lic_name)}</a>'),
        })
        if len(out) >= count:
            break
    return out


PROVIDERS = {"unsplash": search_unsplash, "pexels": search_pexels, "openverse": search_openverse}


def pick_provider(name: str) -> list[str]:
    if name != "auto":
        return [name]
    order = []
    if os.environ.get("UNSPLASH_ACCESS_KEY"):
        order.append("unsplash")
    if os.environ.get("PEXELS_API_KEY"):
        order.append("pexels")
    order.append("openverse")
    return order


def search(query: str, count: int = 6, provider: str = "auto", orientation: str | None = None) -> list[dict]:
    errors = []
    for name in pick_provider(provider):
        try:
            res = PROVIDERS[name](query, count, orientation)
        except StockError as e:
            errors.append(f"{name}: {e}")
            continue
        if res:
            return res
        errors.append(f"{name}: no results for '{query}'")
    raise StockError("; ".join(errors) or "no provider available")


# --- choosing and emitting ------------------------------------------------------------------
def best(results: list[dict], orientation: str | None) -> dict:
    def score(r):
        ratio = r["width"] / max(r["height"], 1)
        want = {"landscape": 1.6, "portrait": 0.7, "squarish": 1.0}.get(orientation or "", ratio)
        return (-abs(ratio - want), min(r["width"], 4000))
    return sorted(results, key=score, reverse=True)[0]


def slug(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")[:60] or "image"


def unsplash_url(raw: str, width: int) -> str:
    sep = "&" if "?" in raw else "?"
    return f"{raw}{sep}w={width}&q=80&auto=format&fit=crop"


def save_variants(data: bytes, out_dir: str, name: str, widths: list[int]) -> list[tuple[str, int, int]]:
    """Write WebP variants with Pillow when available; otherwise the original bytes once."""
    os.makedirs(out_dir, exist_ok=True)
    try:
        from io import BytesIO
        from PIL import Image  # type: ignore
        img = Image.open(BytesIO(data)).convert("RGB")
        files = []
        for w in sorted({min(w, img.width) for w in widths}):
            h = round(img.height * w / img.width)
            path = os.path.join(out_dir, f"{name}-{w}.webp")
            img.resize((w, h)).save(path, "WEBP", quality=80, method=6)
            files.append((path, w, h))
        return files
    except ImportError:
        ext = ".png" if data[:8] == b"\x89PNG\r\n\x1a\n" else ".jpg"
        path = os.path.join(out_dir, name + ext)
        open(path, "wb").write(data)
        return [(path, 0, 0)]


def img_tag(srcset: list[tuple[str, int]], width: int, height: int, alt: str, eager: bool,
            sizes: str = "100vw") -> str:
    src = srcset[-1][0]
    attrs = [f'src="{attr(src)}"']
    if len(srcset) > 1 or srcset[0][1]:
        attrs.append('srcset="' + ", ".join(f"{attr(u)} {w}w" for u, w in srcset if w) + '"')
        attrs.append(f'sizes="{sizes}"')
    attrs += [f'width="{width}"', f'height="{height}"', f'alt="{attr(alt)}"']
    attrs += ['fetchpriority="high"', 'decoding="async"'] if eager else ['loading="lazy"', 'decoding="async"']
    return "<img " + " ".join(attrs) + ">"


def append_credit(out_dir: str, rec: dict) -> None:
    os.makedirs(out_dir, exist_ok=True)
    jpath = os.path.join(out_dir, "CREDITS.json")
    items = json.load(open(jpath)) if os.path.exists(jpath) else []
    items = [i for i in items if i.get("file") != rec["file"]] + [rec]
    json.dump(items, open(jpath, "w"), indent=2, ensure_ascii=False)
    lines = ["<!-- Kio stock image credits: paste into the footer or a credits page -->",
             '<p class="text-xs">Ảnh minh họa / Illustrative photos: ' +
             "; ".join(i["credit_html"] for i in items) + "</p>"]
    open(os.path.join(out_dir, "CREDITS.html"), "w").write("\n".join(lines) + "\n")


def fetch(query: str, name: str, out_dir: str, provider: str = "auto", orientation: str | None = None,
          width: int = 1600, alt: str | None = None, eager: bool = False) -> dict:
    r = best(search(query, 10, provider, orientation), orientation)
    alt = alt or r["alt"] or query
    widths = [640, 1024, width]
    if r["hotlink_only"]:  # Unsplash: hotlink + count the download, never re-host
        if r.get("download_location"):
            try:
                _get(r["download_location"], {"Authorization": f"Client-ID {os.environ['UNSPLASH_ACCESS_KEY']}"})
            except StockError as e:
                print(f"warning: could not trigger Unsplash download event: {e}", file=sys.stderr)
        srcset = [(unsplash_url(r["raw"], w), w) for w in widths]
        h = round(r["height"] * width / r["width"])
        files = []
    else:
        data = _get(r["download"])
        files = save_variants(data, out_dir, f"{name}-{slug(r['author'])}", widths)
        if files[0][1]:
            srcset = [(p.replace(os.sep, "/"), w) for p, w, _ in files]
            width, h = files[-1][1], files[-1][2]
        else:
            srcset = [(files[0][0].replace(os.sep, "/"), 0)]
            h = round(r["height"] * width / r["width"])
    tag = img_tag(srcset, width, h, alt, eager)
    rec = {"file": name, "query": query, "provider": r["provider"], "id": r["id"], "page": r["page"],
           "author": r["author"], "author_url": r["author_url"], "license": r["license"],
           "license_url": r["license_url"], "credit_html": r["credit_html"],
           "files": [p for p, _, _ in files], "hotlinked": r["hotlink_only"], "img": tag}
    append_credit(out_dir, rec)
    return rec


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Find free stock photos (Unsplash, Pexels, Openverse) for a page.")
    sub = ap.add_subparsers(dest="cmd", required=True)
    for c in ("search", "fetch"):
        p = sub.add_parser(c)
        p.add_argument("query", help="English keywords work best, e.g. 'nail salon manicure pastel'")
        p.add_argument("--provider", default="auto", choices=["auto", *PROVIDERS])
        p.add_argument("--orientation", choices=["landscape", "portrait", "squarish"])
    sub.choices["search"].add_argument("--count", type=int, default=6)
    sub.choices["search"].add_argument("--json", action="store_true")
    f = sub.choices["fetch"]
    f.add_argument("--name", required=True, help="slot name, e.g. hero, gallery-1")
    f.add_argument("--out", default="assets/img")
    f.add_argument("--width", type=int, default=1600)
    f.add_argument("--alt", help="alt text in the page's language (recommended)")
    f.add_argument("--eager", action="store_true", help="above the fold / LCP image")
    a = ap.parse_args(argv)
    try:
        if a.cmd == "search":
            res = search(a.query, a.count, a.provider, a.orientation)
            if a.json:
                print(json.dumps(res, indent=2, ensure_ascii=False))
            else:
                for r in res:
                    print(f"[{r['provider']}] {r['id']} {r['width']}x{r['height']} — {r['alt'][:60]!r} — "
                          f"{r['author']} ({r['license']}) {r['page']}")
        else:
            rec = fetch(a.query, a.name, a.out, a.provider, a.orientation, a.width, a.alt, a.eager)
            print(rec["img"])
            print(f"credit: {rec['credit_html']}", file=sys.stderr)
    except StockError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        print("No stock photo fetched. Keep the CSS/SVG illustration for this slot and say so.", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
