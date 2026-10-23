#!/usr/bin/env python3
# Copyright (c) 2026 Cangjie documentation contributors.
# Licensed under CC-BY-4.0. See LICENSE for details.
"""Lint the Cangjie documentation sources.

The script performs three offline checks and never touches the network:

1. Relative links (and images) point to a file that exists in the repository.
2. Absolute links into this repository (``gitcode.com/Cangjie/cangjie_docs``)
   point to a path that exists, whatever the branch in the URL is.
3. ``path.md#heading`` fragments match a heading of the target file.

An optional wording check reports a small set of Chinese terms that the
documentation style guide asks us to spell consistently (see issue #251).

Code blocks and inline code are ignored by every check, because Cangjie
syntax such as ``@Foo[1+](2+3)`` looks like a Markdown link.

Usage::

    python scripts/docs_lint.py              # check the whole repository
    python scripts/docs_lint.py docs/        # check one sub-tree
    python scripts/docs_lint.py --no-wording # links only

Exit status is 0 when nothing is reported, 1 when findings exist, and 2 when
the script itself fails.
"""

from __future__ import annotations

import argparse
import difflib
import os
import re
import subprocess
import sys
import urllib.parse

LINK_RE = re.compile(r"(!?)\[([^\]]*)\]\(\s*<?([^)\s>]*)>?(?:\s+\"[^\"]*\")?\s*\)")
REF_DEF_RE = re.compile(r"^[ \t]{0,3}\[([^\]]+)\]:[ \t]*<?([^>\s]+)>?", re.MULTILINE)
HTML_ATTR_RE = re.compile(r"<(?:img|a|source)\b[^>]*?\b(?:src|href)\s*=\s*[\"']([^\"']+)[\"']", re.I)
FENCE_OPEN_RE = re.compile(r"^ {0,3}(`{3,}|~{3,})")
HEADING_RE = re.compile(r"^(#{1,6})[ \t]+(.+?)[ \t]*#*[ \t]*$", re.MULTILINE)
EXPLICIT_ID_RE = re.compile(r"^#{1,6}[ \t]+.*?\{#([^}\s]+)\}[ \t]*$", re.MULTILINE)
HTML_ID_RE = re.compile(r"<[a-z]+[^>]*?\b(?:id|name)\s*=\s*[\"']([^\"']+)[\"']", re.I)
INLINE_CODE_RE = re.compile(r"`[^`\n]*`")
HTML_TAG_RE = re.compile(r"<[^>]+>")
URL_RE = re.compile(r"(?:https?://|mailto:|tel:|cid:)\S+")
SELF_LINK_RE = re.compile(
    r"https?://(?:www\.)?gitcode\.com/Cangjie/cangjie_docs/(?:blob|tree|raw)/([^/\s]+)/([^)\s#?]+)"
)
SKIP_DIRS = {".git", ".gitcode", "node_modules"}

# term -> preferred spelling. Keep the list short and undisputed; extend it
# only after the style guide agrees on a rule (see issue #251).
WORDING_RULES = (
    ("做为", "作为"),
    ("其它", "其他"),
)


def blank(text: str, start: int, end: int) -> str:
    """Replace text[start:end] with spaces, keeping newlines and offsets."""
    chunk = "".join("\n" if ch == "\n" else " " for ch in text[start:end])
    return text[:start] + chunk + text[end:]


def mask_fences(text: str) -> str:
    """Blank out fenced code blocks, keeping offsets and line numbers."""
    out = []
    fence = None
    for line in text.splitlines(keepends=True):
        body = line.rstrip("\r\n")
        if fence is None:
            match = FENCE_OPEN_RE.match(body)
            if match and not (match.group(1)[0] == "`" and "`" in body[match.end() :]):
                fence = match.group(1)
                out.append(blank(line, 0, len(line)))
                continue
            out.append(line)
        else:
            stripped = body.strip()
            if stripped and set(stripped) == {fence[0]} and len(stripped) >= len(fence):
                fence = None
            out.append(blank(line, 0, len(line)))
    return "".join(out)


def strip_code(text: str) -> str:
    """Blank out fenced code blocks and inline code spans."""
    text = mask_fences(text)
    for match in reversed(list(INLINE_CODE_RE.finditer(text))):
        text = blank(text, match.start(), match.end())
    return text


def slugify(heading: str) -> str:
    """Approximate the anchor a renderer derives from a heading.

    Inline code is protected first, so ``### `--output-dir <value>` `` keeps
    ``value`` even though it looks like an HTML tag. Real HTML tags are then
    dropped while their text is kept: ``<sup>[frontend]</sup>`` contributes
    ``frontend``, which is what the published site uses.
    """
    codes: list[str] = []

    def protect(match: re.Match) -> str:
        codes.append(match.group(1))
        return f"\x00{len(codes) - 1}\x00"

    text = re.sub(r"`([^`]*)`", protect, heading)
    text = HTML_TAG_RE.sub("", text)
    text = re.sub(r"\x00(\d+)\x00", lambda m: codes[int(m.group(1))], text)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = text.strip().lower()
    text = re.sub(r"[*_~`]", "", text)
    # Punctuation goes away entirely (``java.lang.JObject`` -> ``javalangjobject``,
    # ``cjcov -h | --help`` keeps two spaces where the bar was), and every
    # whitespace character becomes one hyphen, so a run of spaces stays a run
    # of hyphens. This is what the published pages use.
    text = re.sub(r"[^\w\u4e00-\u9fff\-\s]", "", text)
    return re.sub(r"\s", "-", text)


def anchors_of(text: str) -> set[str]:
    """All anchors defined by a document.

    Covers the anchors a renderer derives from headings, explicit heading IDs
    (``#### Step 1: ... {#step-1}``) and raw HTML ``id``/``name`` attributes.
    Fenced code blocks are ignored; inline code is kept, because backticks are
    dropped from the anchor while their content remains.
    """
    masked = mask_fences(text)
    seen: dict[str, int] = {}
    anchors: set[str] = set()
    for match in HEADING_RE.finditer(masked):
        base = slugify(match.group(2))
        count = seen.get(base, 0)
        anchors.add(base)
        if count:
            anchors.add(f"{base}-{count}")
        seen[base] = count + 1
    for match in EXPLICIT_ID_RE.finditer(masked):
        anchors.add(match.group(1).lower())
    for match in HTML_ID_RE.finditer(masked):
        anchors.add(match.group(1).lower())
    return anchors


class Repo:
    def __init__(self, root: str) -> None:
        self.root = os.path.abspath(root)
        self.files = self._list_files()
        self.file_set = {p.replace(os.sep, "/") for p in self.files}

    def _list_files(self) -> list[str]:
        try:
            out = subprocess.run(
                # --others keeps new, not yet added documents in the list, so a
                # pre-commit run sees the same working tree as the author does.
                ["git", "-C", self.root, "ls-files", "--cached", "--others", "--exclude-standard"],
                capture_output=True,
                text=True,
                encoding="utf-8",
                check=True,
            ).stdout
            files = []
            seen = set()
            for line in out.splitlines():
                rel = line.strip()
                if not rel or rel in seen:
                    continue
                seen.add(rel)
                # A tracked file deleted from the working tree is still in the
                # index; checking it would only produce a spurious read error.
                if os.path.isfile(os.path.join(self.root, rel.replace("/", os.sep))):
                    files.append(rel)
            if files:
                return files
        except (OSError, subprocess.CalledProcessError):
            pass
        files = []
        for base, dirs, names in os.walk(self.root):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
            for name in names:
                files.append(os.path.relpath(os.path.join(base, name), self.root))
        return files

    def read(self, rel: str) -> str:
        with open(os.path.join(self.root, rel.replace("/", os.sep)), encoding="utf-8", errors="replace") as handle:
            return handle.read()

    def markdown(self) -> list[str]:
        return sorted(p.replace(os.sep, "/") for p in self.files if p.lower().endswith(".md"))

    def exists(self, rel: str) -> bool:
        rel = posix(rel)
        if rel in self.file_set:
            return True
        if (rel + ".md") in self.file_set or (rel + "/README.md") in self.file_set:
            return True
        return (rel.rstrip("/") + "/index.md") in self.file_set

    def closest(self, rel: str) -> str | None:
        matches = difflib.get_close_matches(posix(rel), sorted(self.file_set), n=1, cutoff=0.75)
        return matches[0] if matches else None


def posix(path: str) -> str:
    return os.path.normpath(path).replace(os.sep, "/")


class Report:
    def __init__(self) -> None:
        self.items: list[tuple[str, int, str, str]] = []

    def add(self, path: str, line: int, kind: str, message: str) -> None:
        self.items.append((path, line, kind, message))

    def emit(self, stream) -> None:
        for path, line, kind, message in sorted(self.items):
            print(f"{path}:{line}: [{kind}] {message}", file=stream)
        counts = {}
        for _path, _line, kind, _message in self.items:
            counts[kind] = counts.get(kind, 0) + 1
        summary = ", ".join(f"{name}: {count}" for name, count in sorted(counts.items())) or "none"
        print(f"\n{len(self.items)} finding(s) ({summary}).", file=stream)


def line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def link_targets(text: str):
    """Yield (offset, target) for every link-like target in already stripped text."""
    for match in LINK_RE.finditer(text):
        if match.group(3):
            yield match.start(), match.group(3)
    for match in REF_DEF_RE.finditer(text):
        if match.group(2):
            yield match.start(), match.group(2)
    for match in HTML_ATTR_RE.finditer(text):
        yield match.start(), match.group(1)


def check_file(
    repo: Repo,
    rel: str,
    report: Report,
    anchor_cache: dict[str, set[str]],
    wording: bool,
    anchors: bool,
) -> None:
    try:
        raw = repo.read(rel)
    except OSError as error:
        # One unreadable file must not abort the whole run and hide the
        # findings already collected for the other files.
        report.add(rel, 1, "read", f"cannot read file: {error}")
        return
    text = strip_code(raw)
    base = os.path.dirname(rel)

    for offset, target in link_targets(text):
        line = line_of(text, offset)
        target = target.strip()
        if not target or target.startswith(("#", "mailto:", "cid:", "tel:")):
            if anchors and target.startswith("#") and len(target) > 1:
                if rel not in anchor_cache:
                    anchor_cache[rel] = anchors_of(raw)
                defined = anchor_cache[rel]
                fragment = urllib.parse.unquote(target[1:]).lower()
                if fragment not in defined:
                    report.add(rel, line, "anchor", f"'{target}' matches no heading in this file")
            continue

        if target.startswith(("http://", "https://")):
            self_link = SELF_LINK_RE.search(target)
            if not self_link:
                continue
            path = urllib.parse.unquote(self_link.group(2).split("#")[0].split("?")[0])
            if not repo.exists(path):
                hint = repo.closest(path)
                extra = f" (did you mean '{hint}'?)" if hint else ""
                report.add(rel, line, "link", f"'{path}' does not exist in the repository{extra}")
            continue

        path, _, fragment = target.partition("#")
        path = urllib.parse.unquote(path.split("?")[0])
        if not path:
            continue
        resolved = posix(os.path.join(base, path))
        if not repo.exists(resolved):
            hint = repo.closest(resolved) or repo.closest(path)
            extra = f" (did you mean '{hint}'?)" if hint else ""
            report.add(rel, line, "link", f"'{target}' resolves to '{resolved}', which does not exist{extra}")
            continue
        if fragment and anchors:
            target_file = resolved if resolved in repo.file_set else resolved + ".md"
            if target_file in repo.file_set:
                if target_file not in anchor_cache:
                    anchor_cache[target_file] = anchors_of(repo.read(target_file))
                defined = anchor_cache[target_file]
                if urllib.parse.unquote(fragment).lower() not in defined:
                    report.add(rel, line, "anchor", f"'{target}' matches no heading in '{target_file}'")

    if wording:
        for offset, rule in iter_wording(text):
            report.add(rel, line_of(text, offset), "wording", f"'{rule[0]}' should be '{rule[1]}'")


def iter_wording(text: str):
    for wrong, _right in WORDING_RULES:
        for match in re.finditer(re.escape(wrong), text):
            line_start = text.rfind("\n", 0, match.start()) + 1
            line_end = text.find("\n", match.end())
            line = text[line_start : line_end if line_end != -1 else len(text)]
            # Skip only a term that is itself part of a URL; a line that merely
            # contains a link must still be checked, otherwise prose next to a
            # link silently escapes the wording rule.
            in_url = any(
                url.start() <= match.start() - line_start < url.end() for url in URL_RE.finditer(line)
            )
            if in_url:
                continue
            yield match.start(), (wrong, _right)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Check Cangjie documentation links, anchors and wording.")
    parser.add_argument("paths", nargs="*", help="sub-tree(s) to check, default: whole repository")
    parser.add_argument("--root", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))), help="repository root")
    parser.add_argument("--no-wording", action="store_true", help="skip the Chinese wording check")
    parser.add_argument(
        "--anchors",
        action="store_true",
        help="also verify '#fragment' targets against headings (best effort, off by default)",
    )
    args = parser.parse_args(argv)

    try:
        if hasattr(sys.stdout, "reconfigure"):
            sys.stdout.reconfigure(encoding="utf-8")
    except (AttributeError, OSError):
        pass

    repo = Repo(args.root)
    if not repo.files:
        print(f"error: no files found under {repo.root}", file=sys.stderr)
        return 2

    selected = repo.markdown()
    if args.paths:
        # Separate files from directories: a file argument only matches itself,
        # while a directory argument matches its sub-tree. Comparing both with a
        # trailing slash made file arguments match nothing and let the script
        # report success after scanning zero files.
        wanted: set[str] = set()
        for raw_path in args.paths:
            path = posix(raw_path)
            if os.path.isabs(path):
                path = posix(os.path.relpath(path, repo.root))
            wanted.add(path)
        if "." not in wanted:
            prefixes = tuple(path.rstrip("/") + "/" for path in wanted)
            selected = [p for p in selected if p in wanted or p.startswith(prefixes)]
    if not selected:
        print(f"error: no markdown files to check under {repo.root}", file=sys.stderr)
        return 2

    report = Report()
    anchor_cache: dict[str, set[str]] = {}
    for rel in selected:
        check_file(repo, rel, report, anchor_cache, wording=not args.no_wording, anchors=args.anchors)

    report.emit(sys.stdout)
    print(f"scanned {len(selected)} markdown file(s).", file=sys.stdout)
    return 1 if report.items else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:  # pragma: no cover - defensive
        print(f"error: {error}", file=sys.stderr)
        sys.exit(2)
