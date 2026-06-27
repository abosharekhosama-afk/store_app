import re, pathlib
path = pathlib.Path('lib')
strings = []
pattern = re.compile(r'(?P<quote>["\'])(?P<text>.*?)(?P=quote)')
eng = re.compile(r'[A-Za-z]')
for p in path.rglob('*.dart'):
    text = p.read_text(encoding='utf-8', errors='ignore')
    for m in pattern.finditer(text):
        s = m.group('text')
        if len(s.strip())>=2 and eng.search(s) and not s.strip().startswith('package:') and not s.strip().endswith('.dart'):
            strings.append((str(p), s))
filtered=[]
for f,s in strings:
    if any(x in s for x in ['import ', 'package:', '://', '.dart', 'main.dart', 'assets/', 'lib/']):
        continue
    if re.fullmatch(r'[A-Za-z_]+', s):
        continue
    filtered.append((f,s))
uniq=[]
seen=set()
for f,s in filtered:
    if s not in seen:
        seen.add(s); uniq.append((f,s))
with open('temp_lib_strings.txt', 'w', encoding='utf-8') as out:
    for f,s in uniq:
        out.write(f + '||' + s + '\n')
    out.write('---TOTAL---' + str(len(uniq)) + '\n')
