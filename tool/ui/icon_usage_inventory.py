"""Inventory direct icon references outside the semantic AppIcons catalog."""

import collections
import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "docs" / "audits"
OUTPUT.mkdir(parents=True, exist_ok=True)
references = []
for path in sorted((ROOT / "lib").rglob("*.dart")):
    if path.name.endswith(".g.dart") or "generated" in path.parts:
        continue
    if path.name == "app_icons.dart":
        continue
    for number, line in enumerate(path.read_text(encoding="utf8").splitlines(), 1):
        for match in re.finditer(r"\b(?:Icons|FontAwesomeIcons)\.\w+|\bIconData\(", line):
            references.append((path.relative_to(ROOT).as_posix(), number, match[0]))

csv_path = OUTPUT / "2026-10-12-direct-icon-references.csv"
with csv_path.open("w", encoding="utf8", newline="") as handle:
    writer = csv.writer(handle)
    writer.writerow(("file", "line", "reference"))
    writer.writerows(references)

counts = collections.Counter(reference for _, _, reference in references)
examples = {}
for path, line, reference in references:
    examples.setdefault(reference, (path, line))
report = [
    "# Direct icon reference inventory — 2026-10-12",
    "",
    f"{len(references)} occurrences, {len(counts)} distinct references, "
    f"{len({path for path, _, _ in references})} files.",
    "",
    "Scope: handwritten Dart under `lib/`, excluding the AppIcons catalog and "
    "generated files. `IconData(` identifies direct glyph construction; its "
    "count includes kind-owned icon definitions. SVG asset references are not "
    "included. This is a source inventory, not a claim that every icon needs "
    "the same glyph or should be moved out of kind ownership.",
    "",
    "All occurrences, with file and line: "
    "[CSV inventory](2026-10-12-direct-icon-references.csv). "
    "Regenerate with `python tool/ui/icon_usage_inventory.py`.",
    "",
    "The inspector toolbar and its More menu, Add Albums, column editing and "
    "sort arrows, Collection Status arrows and cover selectors now use "
    "AppIcons. Semantic aliases remain distinct even when glyphs coincide. "
    "The eBay logo remains an SVG brand asset.",
    "",
    "For remaining consumers, use an existing AppIcons semantic token when "
    "it represents the action. Add a token for a new shared action; keep "
    "kind-specific meanings owned by that kind. Avoid replacing unrelated "
    "icons solely because their names or glyphs resemble each other.",
    "",
    "| Direct reference | Occurrences | First consumer |",
    "|---|---:|---|",
]
for reference, count in counts.most_common():
    path, line = examples[reference]
    report.append(f"| `{reference}` | {count} | `{path}:{line}` |")
(OUTPUT / "2026-10-12-direct-icon-references.md").write_text(
    "\n".join(report) + "\n", encoding="utf8"
)
print(report[2])
