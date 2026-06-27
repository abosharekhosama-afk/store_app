import re
from pathlib import Path
root = Path('lib')
regex = re.compile(r'("([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\')')
exclude = ['package:', 'http', 'https', 'http:', 'https:']
for path in sorted(root.rglob('*.dart')):
    text = path.read_text(encoding='utf-8', errors='ignore')
    for i, line in enumerate(text.splitlines(), 1):
        for m in regex.finditer(line):
            s = m.group(2) if m.group(2) is not None else m.group(3)
            if not s:
                continue
            if re.search(r'[A-Za-z]', s):
                if any(s.startswith(prefix) for prefix in exclude):
                    continue
                if re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', s):
                    continue
                if len(s) <= 1:
                    continue
                print(f"{path}:{i}:{s}")
