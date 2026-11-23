import io
import json
import os
import sys
import tempfile
import unittest
import urllib.error
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import stock_images as si  # noqa: E402

UNSPLASH = {"results": [
    {"id": "u1", "width": 6000, "height": 4000, "alt_description": "woman getting manicure",
     "urls": {"raw": "https://images.unsplash.com/photo-u1?ixid=abc"},
     "links": {"html": "https://unsplash.com/photos/u1", "download_location": "https://api.unsplash.com/photos/u1/download"},
     "user": {"name": "Jane Roe", "links": {"html": "https://unsplash.com/@jane"}}},
    {"id": "u2", "width": 3000, "height": 4500, "alt_description": "nail polish",
     "urls": {"raw": "https://images.unsplash.com/photo-u2"},
     "links": {"html": "https://unsplash.com/photos/u2", "download_location": "https://api.unsplash.com/photos/u2/download"},
     "user": {"name": "Ann", "links": {"html": "https://unsplash.com/@ann"}}}]}
PEXELS = {"photos": [
    {"id": 42, "width": 5000, "height": 3333, "url": "https://www.pexels.com/photo/42/", "alt": "spa stones",
     "photographer": "Minh Tran", "photographer_url": "https://www.pexels.com/@minh",
     "src": {"original": "https://images.pexels.com/photos/42/o.jpeg", "medium": "m", "large": "l", "large2x": "l2"}}]}
OPENVERSE = {"results": [
    {"id": "ov1", "title": "Nail art", "url": "https://live.staticflickr.com/1/ov1.jpg", "width": 1600, "height": 1067,
     "creator": "Bob", "creator_url": "https://flickr.com/bob", "license": "by", "license_version": "2.0",
     "license_url": "https://creativecommons.org/licenses/by/2.0/", "foreign_landing_url": "https://flickr.com/p/ov1"},
    {"id": "ov2", "title": "No size", "url": "https://x/ov2.jpg", "width": None, "height": None, "license": "cc0"}]}
JPEG = b"\xff\xd8\xff\xe0" + b"0" * 64


def fake_get(responses, calls):
    def _get(url, headers=None):
        calls.append((url, headers or {}))
        for key, body in responses.items():
            if key in url:
                if isinstance(body, Exception):
                    raise body
                return body if isinstance(body, bytes) else json.dumps(body).encode()
        raise AssertionError(f"unexpected url {url}")
    return _get


class ProviderTests(unittest.TestCase):
    def setUp(self):
        self.env = mock.patch.dict(os.environ, {}, clear=False)
        self.env.start()
        for k in ("UNSPLASH_ACCESS_KEY", "PEXELS_API_KEY"):
            os.environ.pop(k, None)
        self.calls = []

    def tearDown(self):
        self.env.stop()

    def test_auto_order_without_keys_uses_openverse(self):
        self.assertEqual(si.pick_provider("auto"), ["openverse"])
        os.environ["PEXELS_API_KEY"] = "p"; os.environ["UNSPLASH_ACCESS_KEY"] = "u"
        self.assertEqual(si.pick_provider("auto"), ["unsplash", "pexels", "openverse"])

    def test_unsplash_parse_auth_and_attribution(self):
        os.environ["UNSPLASH_ACCESS_KEY"] = "KEY"
        with mock.patch.object(si, "_get", fake_get({"api.unsplash.com/search": UNSPLASH}, self.calls)):
            res = si.search("manicure", 2, "unsplash", "landscape")
        url, headers = self.calls[0]
        self.assertEqual(headers["Authorization"], "Client-ID KEY")
        self.assertIn("orientation=landscape", url)
        self.assertTrue(res[0]["hotlink_only"])
        self.assertIn("utm_source=", res[0]["author_url"])
        self.assertIn("utm_medium=referral", res[0]["credit_html"])
        self.assertIn("Unsplash", res[0]["credit_html"])

    def test_pexels_parse_and_square_mapping(self):
        os.environ["PEXELS_API_KEY"] = "PK"
        with mock.patch.object(si, "_get", fake_get({"api.pexels.com": PEXELS}, self.calls)):
            res = si.search("spa", 1, "pexels", "squarish")
        self.assertEqual(self.calls[0][1]["Authorization"], "PK")
        self.assertIn("orientation=square", self.calls[0][0])
        self.assertFalse(res[0]["hotlink_only"])
        self.assertIn("Pexels", res[0]["credit_html"])

    def test_openverse_commercial_filter_skips_sizeless_and_builds_cc_credit(self):
        with mock.patch.object(si, "_get", fake_get({"api.openverse.org": OPENVERSE}, self.calls)):
            res = si.search("nail art", 5, "openverse")
        self.assertIn("license_type=commercial", self.calls[0][0])
        self.assertEqual([r["id"] for r in res], ["ov1"])
        self.assertIn("CC BY 2.0", res[0]["credit_html"])
        self.assertIn("creativecommons.org/licenses/by/2.0", res[0]["credit_html"])

    def test_falls_back_when_a_provider_fails(self):
        os.environ["UNSPLASH_ACCESS_KEY"] = "bad"
        responses = {"api.unsplash.com": si.StockError("HTTP 401 from api.unsplash.com"),
                     "api.openverse.org": OPENVERSE}
        with mock.patch.object(si, "_get", fake_get(responses, self.calls)):
            res = si.search("nail", 1)
        self.assertEqual(res[0]["provider"], "openverse")

    def test_all_providers_fail_reports_every_reason(self):
        with mock.patch.object(si, "_get", fake_get({"api.openverse.org": si.StockError("cannot reach")}, self.calls)):
            with self.assertRaises(si.StockError) as cm:
                si.search("nail")
        self.assertIn("openverse: cannot reach", str(cm.exception))

    def test_http_errors_are_explained(self):
        err = urllib.error.HTTPError("https://api.pexels.com/v1/search", 429, "x", {}, io.BytesIO(b""))
        with mock.patch("urllib.request.urlopen", side_effect=err):
            with self.assertRaises(si.StockError) as cm:
                si._get("https://api.pexels.com/v1/search")
        self.assertIn("rate limited", str(cm.exception))


class FetchTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.calls = []
        for k in ("UNSPLASH_ACCESS_KEY", "PEXELS_API_KEY"):
            os.environ.pop(k, None)

    def test_unsplash_fetch_hotlinks_and_triggers_download(self):
        responses = {"api.unsplash.com/search": UNSPLASH, "/download": b"{}"}
        with mock.patch.dict(os.environ, {"UNSPLASH_ACCESS_KEY": "KEY"}), \
             mock.patch.object(si, "_get", fake_get(responses, self.calls)):
            rec = si.fetch("manicure", "hero", self.tmp, orientation="landscape", alt="Làm móng", eager=True)
        self.assertTrue(any("/photos/u1/download" in u for u, _ in self.calls))
        self.assertEqual(rec["files"], [])
        self.assertIn("images.unsplash.com/photo-u1?ixid=abc&w=1600&q=62", rec["img"])
        self.assertIn(" 768w", rec["img"])
        self.assertNotRegex(rec["img"] + rec["credit_html"], r"&[a-zA-Z]+;|&#[0-9]+;")
        self.assertIn('fetchpriority="high"', rec["img"])
        self.assertIn('alt="Làm móng"', rec["img"])
        self.assertIn('width="1600" height="1067"', rec["img"])
        credits = json.load(open(os.path.join(self.tmp, "CREDITS.json")))
        self.assertEqual(credits[0]["provider"], "unsplash")

    def test_pexels_fetch_downloads_locally_lazy_and_credits(self):
        responses = {"api.pexels.com": PEXELS, "images.pexels.com/photos/42/o.jpeg": JPEG}
        seen = {}
        with mock.patch.dict(os.environ, {"PEXELS_API_KEY": "PK"}), \
             mock.patch.object(si, "_get", fake_get(responses, self.calls)), \
             mock.patch.object(si, "save_variants", lambda data, out, name, widths, quality=75:
                               seen.update(widths=widths, quality=quality) or
                               [(os.path.join(out, f"{name}-{w}.webp"), w, round(w * 2 / 3)) for w in widths]):
            rec = si.fetch("spa stones", "gallery-1", self.tmp)
        self.assertEqual(seen, {"widths": [480, 768, 1024, 1600], "quality": 75})
        self.assertIn('loading="lazy"', rec["img"])
        self.assertIn("gallery-1-minh-tran-768.webp 768w", rec["img"])
        self.assertIn('width="1600" height="1067"', rec["img"])
        html_credit = open(os.path.join(self.tmp, "CREDITS.html")).read()
        self.assertIn("Minh Tran", html_credit)
        self.assertIn("Pexels", html_credit)

    def test_save_variants_without_pillow_writes_original(self):
        with mock.patch.dict(sys.modules, {"PIL": None}):
            files = si.save_variants(JPEG, self.tmp, "x", [640])
        self.assertTrue(files[0][0].endswith("x.jpg"))
        self.assertEqual(open(files[0][0], "rb").read(), JPEG)

    def test_attr_keeps_real_characters_and_neutralises_quotes(self):
        self.assertEqual(si.attr('Nail & Spa "Lotus" <b>'), "Nail & Spa \u201dLotus\u201d \u2039b\u203a")

    def test_credits_are_deduplicated_per_slot(self):
        for _ in range(2):
            si.append_credit(self.tmp, {"file": "hero", "credit_html": "c1"})
        si.append_credit(self.tmp, {"file": "g1", "credit_html": "c2"})
        self.assertEqual(len(json.load(open(os.path.join(self.tmp, "CREDITS.json")))), 2)

    def test_cli_failure_exits_2_with_fallback_advice(self):
        with mock.patch.object(si, "_get", fake_get({"api.openverse.org": si.StockError("cannot reach x")}, [])), \
             mock.patch("sys.stderr", new_callable=io.StringIO) as err:
            code = si.main(["fetch", "nail", "--name", "hero", "--out", self.tmp])
        self.assertEqual(code, 2)
        self.assertIn("Keep the CSS/SVG illustration", err.getvalue())


if __name__ == "__main__":
    unittest.main()
