#!/usr/bin/env python3

import re
import sys
from pathlib import Path

if len(sys.argv) != 2:
    print("usage: python templating_string.py <template.svg.template>")
    sys.exit(1)

svg = Path(sys.argv[1]).read_text()

svg = re.sub(r"\s+", " ", svg).strip()

parts = re.split(r"(\[.*?\])", svg)

typst_parts = []

for part in parts:
    if part.startswith("[") and part.endswith("]"):
        expr = part[1:-1].strip()
        typst_parts.append(f"str({expr})")
    else:
        escaped = part.replace("\\", "\\\\").replace('"', '\\"')
        if escaped:
            typst_parts.append(f'"{escaped}"')

expression = " + ".join(typst_parts)

print(expression)
