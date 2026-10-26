#!/usr/bin/env python3
# Copyright (c) 2026 Cangjie documentation contributors.
# Licensed under CC-BY-4.0. See LICENSE for details.
"""Unit tests for docs_lint.py. Run with ``python -m unittest discover scripts``."""

import io
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from contextlib import redirect_stdout

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import docs_lint  # noqa: E402


class DocsLintTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = self._tmp.name
        self.addCleanup(self._tmp.cleanup)

    def write(self, rel, content):
        path = os.path.join(self.root, rel.replace("/", os.sep))
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(content)

    def run_lint(self, *args):
        out = io.StringIO()
        with redirect_stdout(out):
            code = docs_lint.main(["--root", self.root, *args])
        return code, out.getvalue()

    def git(self, *args):
        subprocess.run(["git", "-C", self.root, *args], check=True, capture_output=True, text=True)

    def test_existing_relative_link_passes(self):
        self.write("a.md", "[b](b.md)\n")
        self.write("b.md", "# B\n")
        code, out = self.run_lint()
        self.assertEqual(code, 0, out)

    def test_missing_relative_link_is_reported(self):
        self.write("a.md", "[b](b.md)\n")
        code, out = self.run_lint()
        self.assertEqual(code, 1)
        self.assertIn("a.md:1: [link]", out)

    def test_missing_link_suggests_close_match(self):
        self.write("a.md", "[b](b.mdl)\n")
        self.write("b.md", "# B\n")
        _code, out = self.run_lint()
        self.assertIn("did you mean 'b.md'?", out)

    def test_link_inside_fenced_code_is_ignored(self):
        self.write("a.md", "```cangjie\n@Foo[1+](2+3)\n```\n")
        code, _out = self.run_lint()
        self.assertEqual(code, 0)

    def test_link_inside_blockquote_fence_is_ignored(self):
        self.write("a.md", "> ```cangjie\n> @Foo[1+](2+3)\n> ```\n")
        code, _out = self.run_lint()
        self.assertEqual(code, 0)

    def test_link_inside_inline_code_is_ignored(self):
        self.write("a.md", "Use `@Foo[1+](2+3)` syntax.\n")
        code, _out = self.run_lint()
        self.assertEqual(code, 0)

    def test_absolute_self_link_is_checked(self):
        self.write("a.md", "[b](https://gitcode.com/Cangjie/cangjie_docs/blob/main/b.mdl)\n")
        self.write("b.md", "# B\n")
        code, out = self.run_lint()
        self.assertEqual(code, 1)
        self.assertIn("[link]", out)

    def test_external_link_is_not_checked(self):
        self.write("a.md", "[x](https://example.com/does-not-exist)\n")
        code, _out = self.run_lint()
        self.assertEqual(code, 0)

    def test_anchor_is_checked_only_on_request(self):
        self.write("a.md", "[b](b.md#no-such-heading)\n")
        self.write("b.md", "# B\n")
        code, _out = self.run_lint()
        self.assertEqual(code, 0)
        code, out = self.run_lint("--anchors")
        self.assertEqual(code, 1)
        self.assertIn("[anchor]", out)

    def test_explicit_heading_id_is_a_valid_anchor(self):
        self.write("a.md", "[b](b.md#step-1)\n")
        self.write("b.md", "#### Step 1: Design {#step-1}\n")
        code, out = self.run_lint("--anchors")
        self.assertEqual(code, 0, out)

    def test_heading_with_inline_code_and_html(self):
        self.write("a.md", "[b](b.md#--output-dir-value-frontend)\n")
        self.write("b.md", "### `--output-dir <value>` <sup>[frontend]</sup>\n")
        code, out = self.run_lint("--anchors")
        self.assertEqual(code, 0, out)

    def test_punctuation_is_dropped_and_each_space_keeps_a_hyphen(self):
        # ``cjcov -h | --help`` -> ``cjcov--h----help``: the bar disappears and
        # leaves two spaces behind, so the run of hyphens is preserved.
        self.write("a.md", "[b](b.md#cjcov--h----help)\n")
        self.write("b.md", "### cjcov -h | --help\n")
        code, out = self.run_lint("--anchors")
        self.assertEqual(code, 0, out)

    def test_dots_are_not_part_of_the_anchor(self):
        self.write("a.md", "[b](b.md#javalangjobject)\n")
        self.write("b.md", "### `java.lang.JObject`\n")
        code, out = self.run_lint("--anchors")
        self.assertEqual(code, 0, out)

    def test_html_id_and_name_are_valid_anchors(self):
        self.write("a.md", "[b](b.md#custom-target)\n[c](b.md#legacy-anchor)\n")
        self.write(
            "b.md",
            '<a id="custom-target"></a>\n<a name="legacy-anchor"></a>\n',
        )
        code, out = self.run_lint("--anchors")
        self.assertEqual(code, 0, out)

    def test_duplicate_headings_get_numbered_anchors(self):
        self.write("a.md", "[b](b.md#note-1)\n")
        self.write("b.md", "## Note\n## Note\n")
        code, out = self.run_lint("--anchors")
        self.assertEqual(code, 0, out)

    def test_wording_rule(self):
        self.write("a.md", "这一项和其它项。\n")
        code, out = self.run_lint()
        self.assertEqual(code, 1)
        self.assertIn("'其它' should be '其他'", out)

    def test_second_wording_rule(self):
        self.write("a.md", "这一项做为示例。\n")
        code, out = self.run_lint()
        self.assertEqual(code, 1)
        self.assertIn("'做为' should be '作为'", out)

    def test_wording_inside_code_is_ignored(self):
        self.write("a.md", "```\n其它\n```\n")
        code, _out = self.run_lint()
        self.assertEqual(code, 0)

    def test_wording_inside_blockquote_fence_is_ignored(self):
        self.write("a.md", "> ```\n> 其它\n> ```\n")
        code, _out = self.run_lint()
        self.assertEqual(code, 0)

    def test_no_wording_flag(self):
        self.write("a.md", "其它\n")
        code, _out = self.run_lint("--no-wording")
        self.assertEqual(code, 0)

    def test_wording_next_to_a_link_is_reported(self):
        self.write("a.md", "其它细节见 https://example.com/spec\n")
        code, out = self.run_lint()
        self.assertEqual(code, 1)
        self.assertIn("'其它' should be '其他'", out)

    def test_wording_inside_a_url_is_ignored(self):
        self.write("a.md", "https://example.com/其它\n")
        code, out = self.run_lint()
        self.assertEqual(code, 0, out)

    def test_file_argument_is_checked(self):
        self.write("docs/a.md", "[b](missing.md)\n")
        code, out = self.run_lint("docs/a.md")
        self.assertEqual(code, 1, out)
        self.assertIn("docs/a.md:1: [link]", out)

    def test_directory_argument_checks_subtree(self):
        self.write("docs/a.md", "[b](missing.md)\n")
        code, out = self.run_lint("docs")
        self.assertEqual(code, 1, out)

    def test_unknown_path_is_an_error(self):
        self.write("a.md", "# A\n")
        code, _out = self.run_lint("docs")
        self.assertEqual(code, 2)

    def test_anchor_target_is_read_once(self):
        self.write("a.md", "[b](b.md#one) [b](b.md#two)\n")
        self.write("b.md", "# One\n# Two\n")
        reads = []
        original = docs_lint.Repo.read

        def counting(repo, rel):
            reads.append(rel)
            return original(repo, rel)

        docs_lint.Repo.read = counting
        self.addCleanup(setattr, docs_lint.Repo, "read", original)
        code, out = self.run_lint("a.md", "--anchors")
        self.assertEqual(code, 0, out)
        self.assertEqual(reads.count("b.md"), 1)

    @unittest.skipUnless(shutil.which("git"), "git is required")
    def test_untracked_file_is_checked(self):
        self.write("a.md", "[b](b.md)\n")
        self.write("b.md", "# B\n")
        self.git("init")
        self.git("add", "a.md")
        code, out = self.run_lint()
        self.assertEqual(code, 0, out)

    @unittest.skipUnless(shutil.which("git"), "git is required")
    def test_deleted_tracked_file_is_a_link_finding(self):
        self.write("a.md", "[b](b.md)\n")
        self.write("b.md", "# B\n")
        self.git("init")
        self.git("add", "a.md", "b.md")
        os.remove(os.path.join(self.root, "b.md"))
        code, out = self.run_lint()
        self.assertEqual(code, 1, out)
        self.assertIn("[link]", out)


if __name__ == "__main__":
    unittest.main()
