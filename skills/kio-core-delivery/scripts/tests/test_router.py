#!/usr/bin/env python3
"""
Unit tests for Kio Multi-Engine AI CLI Router (kio_router.py)
"""

import unittest
import sys
import os
import subprocess
import json

# Add scripts directory to path
SCRIPTS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, SCRIPTS_DIR)

import kio_router

class TestKioRouter(unittest.TestCase):
    """Runs against stub claude/codex/agy executables on PATH, so the suite does not
    depend on which AI CLIs the machine (or a CI runner) happens to have."""

    @classmethod
    def setUpClass(cls):
        import tempfile
        cls._bin = tempfile.TemporaryDirectory()
        for name in ("claude", "codex", "agy"):
            path = os.path.join(cls._bin.name, name)
            with open(path, "w") as f:
                f.write("#!/bin/sh\nexit 0\n")
            os.chmod(path, 0o755)
            if os.name == "nt":
                with open(path + ".cmd", "w") as f:
                    f.write("@exit /b 0\r\n")
        cls._old_path = os.environ.get("PATH", "")
        os.environ["PATH"] = cls._bin.name + os.pathsep + cls._old_path

    @classmethod
    def tearDownClass(cls):
        os.environ["PATH"] = cls._old_path
        cls._bin.cleanup()


    def test_detect_installed_engines(self):
        engines = kio_router.detect_installed_engines()
        self.assertIn("claude", engines)
        self.assertIn("codex", engines)
        self.assertIn("agy", engines)
        # the stub binaries on PATH make every engine detectable
        installed_count = sum(1 for e in engines.values() if e["installed"])
        self.assertGreaterEqual(installed_count, 1)

    def test_classify_ui_prompt(self):
        prompt = "Thiết kế component Button với CSS Tailwind, chống AI slop và mượt mà với Lenis scroll"
        engine, conf, scores = kio_router.classify_prompt(prompt)
        self.assertEqual(engine, "claude")
        self.assertGreater(scores["claude"], scores["codex"])
        self.assertGreater(scores["claude"], scores["agy"])

    def test_classify_backend_prompt(self):
        prompt = "Tối ưu hóa câu truy vấn SQL PostgreSQL, index database và viết bộ unit test pytest"
        engine, conf, scores = kio_router.classify_prompt(prompt)
        self.assertEqual(engine, "codex")
        self.assertGreater(scores["codex"], scores["claude"])
        self.assertGreater(scores["codex"], scores["agy"])

    def test_classify_large_context_prompt(self):
        prompt = "Quét toàn bộ repo monorepo đọc tất cả các file tài liệu và Firebase spec"
        engine, conf, scores = kio_router.classify_prompt(prompt)
        self.assertEqual(engine, "agy")
        self.assertGreater(scores["agy"], scores["claude"])
        self.assertGreater(scores["agy"], scores["codex"])

    def test_dispatch_dry_run_claude(self):
        prompt = "Refactor header CSS"
        code = kio_router.dispatch_task(prompt, engine_override="claude", dry_run=True)
        self.assertEqual(code, 0)

    def test_dispatch_dry_run_codex(self):
        prompt = "Viết giải thuật sắp xếp và unit tests"
        code = kio_router.dispatch_task(prompt, engine_override="codex", dry_run=True)
        self.assertEqual(code, 0)

    def test_dispatch_dry_run_agy(self):
        prompt = "Quét monorepo tài liệu"
        code = kio_router.dispatch_task(prompt, engine_override="agy", dry_run=True)
        self.assertEqual(code, 0)

    def test_cli_subprocess_classify(self):
        script_path = os.path.join(SCRIPTS_DIR, "kio_router.py")
        res = subprocess.run([
            sys.executable, script_path, "classify", "Tạo trang landing page mới bằng React và Tailwind"
        ], capture_output=True, text=True)
        self.assertEqual(res.returncode, 0)
        data = json.loads(res.stdout)
        self.assertEqual(data["recommended_engine"], "claude")

    def test_cli_subprocess_matrix(self):
        script_path = os.path.join(SCRIPTS_DIR, "kio_router.py")
        res = subprocess.run([
            sys.executable, script_path, "matrix"
        ], capture_output=True, text=True)
        self.assertEqual(res.returncode, 0)
        self.assertIn("KIO MULTI-ENGINE AI CLI ROUTING MATRIX", res.stdout)
        self.assertIn("[CLAUDE]", res.stdout)
        self.assertIn("[CODEX]", res.stdout)
        self.assertIn("[AGY]", res.stdout)

if __name__ == "__main__":
    unittest.main()
