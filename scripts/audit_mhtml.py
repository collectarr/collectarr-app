"""Inventory saved UI styles without treating a snapshot as a behavior test.

Usage: python scripts/audit_mhtml.py <snapshot.mhtml> ... --output <report.json>
The output contains CSS evidence, not application cookies or HTML form values.
"""

import argparse
import hashlib
import json
import re
from email import policy
from email.parser import BytesParser
from pathlib import Path


def inspect(path):
    raw = path.read_bytes()
    message = BytesParser(policy=policy.default).parsebytes(raw)
    resources = []
    rules = []
    for part in message.walk():
        if part.is_multipart():
            continue
        content = part.get_payload(decode=True) or b""
        location = part.get("Content-Location", "")
        content_type = part.get_content_type()
        resources.append({"type": content_type, "location": location,
                          "bytes": len(content)})
        if content_type != "text/css":
            continue
        css = content.decode(part.get_content_charset() or "utf-8",
                             errors="replace")
        css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
        # Leaf declarations only; this is an inventory, not a CSS cascade engine.
        for match in re.finditer(r"([^{}]+)\{([^{}]*)\}", css):
            declarations = {}
            for entry in match.group(2).split(";"):
                name, separator, value = entry.partition(":")
                if separator:
                    declarations[name.strip()] = value.strip()
            relevant = {
                name: value for name, value in declarations.items()
                if name.startswith(("font", "transition", "animation"))
                or name in {"line-height", "letter-spacing", "transform",
                            "box-shadow", "content", "border-radius"}
            }
            if relevant:
                rules.append({"resource": location,
                              "selector": match.group(1).strip(),
                              "declarations": relevant})
    return {"snapshot": str(path.resolve()),
            "sha256": hashlib.sha256(raw).hexdigest(),
            "resources": resources, "style_rules": rules}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("snapshots", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    report = {
        "limitations": [
            "CSS presence does not establish that a component is used.",
            "Timing, hover, drag, and persistence require live interaction.",
            "Flutter canvas fonts must be checked in Dart and screenshots.",
        ],
        "snapshots": [inspect(path) for path in args.snapshots],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2),
                           encoding="utf-8")
    print(f"Inspected {len(report['snapshots'])} snapshots: {args.output}")


if __name__ == "__main__":
    main()
