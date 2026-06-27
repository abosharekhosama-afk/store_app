import pathlib, re
path = pathlib.Path('lib')
patterns = [r'Text\s*\(', r'labelText\s*:', r'hintText\s*:', r'errorText\s*:', r'title\s*:', r'message\s*:', r'subTitle\s*:', r'child\s*:\s*Text\s*\(', r'button\s*:', r'label\s*:']
quote = re.compile(r'(["\'])(.*?)(\1)')
eng = re.compile(r'[A-Za-z]')
results = []
for p in path.rglob('*.dart'):
    text = p.read_text(encoding='utf-8', errors='ignore').splitlines()
    in_block = False
    for i, line in enumerate(text, 1):
        stripped = line.strip()
        if in_block:
            if '*/' in stripped:
                in_block = False
                stripped = stripped.split('*/',1)[1]
            else:
                continue
        if stripped.startswith('//'):
            continue
        if '/*' in stripped:
            if '*/' in stripped:
                stripped = re.sub(r'/\*.*?\*/', '', stripped)
            else:
                in_block = True
                stripped = stripped.split('/*',1)[0]
        if any(re.search(pat, stripped) for pat in patterns):
            for m in quote.finditer(stripped):
                s = m.group(2).strip()
                if len(s) < 2: continue
                if not eng.search(s): continue
                if re.match(r'^(dart:|package:|https?://|assets/|\$[A-Za-z_].*|[A-Za-z_]+)$', s):
                    continue
                results.append(f'{p}:{i}||{s}')
with open('temp_lib_ui_active_strings.txt', 'w', encoding='utf-8') as f:
    for r in results:
        f.write(r + '\n')
    f.write('---TOTAL---' + str(len(results)) + '\n')
