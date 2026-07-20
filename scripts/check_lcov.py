#!/usr/bin/env python3
"""Échoue lorsque la couverture globale LCOV est sous le seuil demandé."""

from __future__ import annotations

import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: check_lcov.py <lcov.info> <minimum_percent>", file=sys.stderr)
        return 2

    report = Path(sys.argv[1])
    minimum = float(sys.argv[2])

    if not report.is_file():
        print(f"Rapport LCOV introuvable : {report}", file=sys.stderr)
        return 2

    found = 0
    hit = 0
    for line in report.read_text(encoding="utf-8").splitlines():
        if line.startswith("LF:"):
            found += int(line[3:])
        elif line.startswith("LH:"):
            hit += int(line[3:])

    if found == 0:
        print("Aucune ligne mesurable dans le rapport LCOV.", file=sys.stderr)
        return 2

    percent = hit * 100.0 / found
    print(f"Couverture frontend : {percent:.2f}% ({hit}/{found} lignes)")

    if percent + 1e-9 < minimum:
        print(
            f"Couverture insuffisante : minimum requis {minimum:.2f}%.",
            file=sys.stderr,
        )
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
