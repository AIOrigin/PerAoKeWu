import re
from pathlib import Path

t = Path(r"c:\Users\zy洋芋糍粑\Documents\PerAoKeWu - 副本\assets\maps\route_levels\runner_60s\runner_60s.gd").read_text(encoding="utf-8")
declared = set(re.findall(r"^const (\w+)", t, re.M))
vars_decl = set(re.findall(r"^var (\w+)", t, re.M))
funcs = set(re.findall(r"^func (\w+)\(", t, re.M))

# SCREAMING_SNAKE used as value (not in strings)
for m in re.finditer(r"(?<![\"'])\b([A-Z][A-Z0-9_]{3,})\b", t):
    name = m.group(1)
    if name in declared or name in {"TYPE_DICTIONARY", "NODE", "PI", "TAU"}:
        continue
    if name.startswith("KEY_"):
        continue
    if name not in declared:
        declared.add(name)  # dedupe print
        pass

missing = []
for m in re.finditer(r"(?<![\"'])\b([A-Z][A-Z0-9_]{3,})\b", t):
    name = m.group(1)
    if name in {"TYPE_DICTIONARY", "PI", "TAU", "INF"}:
        continue
    if name.startswith("KEY_"):
        continue
    if name not in declared and re.search(rf"^const {name}\s*:=", t, re.M) is None:
        missing.append(name)

from collections import Counter
for name, cnt in Counter(missing).most_common(40):
    if name not in declared:
        print("CONST?", name, cnt)

called = set(re.findall(r"\b(_[a-z][a-z0-9_]*)\b", t))
for v in sorted(called):
    if v not in vars_decl and v not in funcs:
        if t.count(f"var {v}") == 0:
            print("VAR?", v)

print("func calls missing:", sorted(n for n in re.findall(r"\b(_\w+)\(", t) if n not in funcs)[:20])
