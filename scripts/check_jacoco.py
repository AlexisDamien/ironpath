#!/usr/bin/env python3
"""Échoue lorsque la couverture de lignes JaCoCo est sous le seuil demandé."""

from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: check_jacoco.py <jacoco.xml> <minimum_percent>", file=sys.stderr)
        return 2

    report = Path(sys.argv[1])
    minimum = float(sys.argv[2])

    if not report.is_file():
        print(f"Rapport JaCoCo introuvable : {report}", file=sys.stderr)
        return 2

    root = ET.parse(report).getroot()
    line_counter = next(
        (counter for counter in root.findall("counter") if counter.get("type") == "LINE"),
        None,
    )

    if line_counter is None:
        print("Compteur LINE absent du rapport JaCoCo.", file=sys.stderr)
        return 2

    missed = int(line_counter.get("missed", "0"))
    covered = int(line_counter.get("covered", "0"))
    total = missed + covered

    if total == 0:
        print("Aucune ligne mesurable dans le rapport JaCoCo.", file=sys.stderr)
        return 2

    percent = covered * 100.0 / total
    print(f"Couverture backend : {percent:.2f}% ({covered}/{total} lignes)")

    if percent + 1e-9 < minimum:
        print(
            f"Couverture insuffisante : minimum requis {minimum:.2f}%.",
            file=sys.stderr,
        )
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
