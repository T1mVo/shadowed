#!/usr/bin/env python3

import re
import subprocess
from pathlib import Path

script_dir = Path(__file__).parent
project_dir = script_dir.parent
shadowed_file = project_dir / "src" / "shadowed.typ"
templates_dir = project_dir / "src" / "templates"

content = shadowed_file.read_text()

for template_file in sorted(templates_dir.glob("*.template")):
    svg = re.sub(r"\s+", " ", template_file.read_text()).strip()
    parts = re.split(r"(\[.*?\])", svg)
    typst_parts = []
    
    for part in parts:
        if part.startswith("[") and part.endswith("]"):
            typst_parts.append(f"to-str({part[1:-1].strip()})")
        else:
            escaped = part.replace("\\", "\\\\").replace('"', '\\"')
            if escaped:
                typst_parts.append(f'"{escaped}"')
    
    typst_code = f"({', '.join(typst_parts)}).join()"
    rel_path = template_file.relative_to(project_dir / "src")
    begin_marker = f"// begin {rel_path}"
    end_marker = f"// end {rel_path}"
    
    pattern = re.compile(
        rf"(  {re.escape(begin_marker)})\n.*?(  {re.escape(end_marker)})",
        re.DOTALL
    )
    
    content = pattern.sub(rf"\1\n  {typst_code}\n  \2", content)

shadowed_file.write_text(content)
subprocess.run(["typstyle", "--inplace", str(shadowed_file)])
