#!/usr/bin/env python3
"""Raise the app version by 0.0.1 and the Android build number by 1."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = ROOT / "pubspec.yaml"
VERSION_LINE = re.compile(r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$", re.M)


def bump(pubspec: str) -> tuple[str, str]:
    match = VERSION_LINE.search(pubspec)
    if match is None:
        raise ValueError("pubspec.yaml の version が major.minor.patch+build ではありません。")
    major, minor, patch, build = (int(part) for part in match.groups())
    patch += 1
    build += 1
    name = f"{major}.{minor}.{patch}"
    full = f"{name}+{build}"
    pubspec = VERSION_LINE.sub(f"version: {full}", pubspec, count=1)
    return pubspec, name


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "--check":
        pubspec, name = bump("version: 1.0.0+1\n")
        if name != "1.0.1" or "version: 1.0.1+2" not in pubspec:
            raise SystemExit("版の繰り上げが違います。")
        return 0
    pubspec, name = bump(PUBSPEC.read_text())
    PUBSPEC.write_text(pubspec)
    print(name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
