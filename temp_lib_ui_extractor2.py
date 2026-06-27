import re, pathlib
path=pathlib.Path('lib')
pattern=re.compile(r'(?P<quote>["\'])(?P<text>.*?)(?P=quote)')
letters=re.compile(r'[A-Za-z]')
ui_strings=[]
exclude_patterns=[r'^dart:', r'^package:', r'^[A-Za-z0-9_./\\]+$', r'^[A-Za-z]{1,3}$', r'^[\d\W]+$']
for p in path.rglob('*.dart'):
    text=p.read_text(encoding='utf-8', errors='ignore')
    for i,line in enumerate(text.splitlines(),1):
        if re.search(r'(Text\(|label\s*:|hintText\s*:|errorText\s*:|title\s*:|message\s*:|toast|dialog|button|snackbar|tooltip|hint|subtitle|headline|bodyText|caption|content|placeholder|floatingLabel|prompt|password|email|name|address|country|city|login|signup|continue|next|skip|search|home|store|wishlist|profile|settings|checkout|order|cart|thank you|rate|review|payment|submit|cancel|save|confirm|invalid|required|enter|select|failed|success|error|change|update|logout)', line, re.IGNORECASE):
            for m in pattern.finditer(line):
                s=m.group('text').strip()
                if len(s) < 2 or not letters.search(s):
                    continue
                if any(re.match(exp, s) for exp in exclude_patterns):
                    continue
                if s.startswith('\\u'):
                    continue
                ui_strings.append((str(p), i, s))
seen=set(); uniq=[]
for p,l,s in ui_strings:
    if s not in seen:
        seen.add(s); uniq.append((p,l,s))
with open('temp_lib_ui_strings.txt','w', encoding='utf-8') as out:
    for p,l,s in uniq:
        out.write(f'{p}:{l}||{s}\n')
    out.write('---TOTAL---'+str(len(uniq))+'\n')
