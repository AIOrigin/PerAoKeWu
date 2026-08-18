"""Extract runner_60s.gd feature snippets from agent transcript (read-only)."""
import json
import re
from pathlib import Path

TRANSCRIPT = Path(
    r"C:\Users\zy洋芋糍粑\.cursor\projects\c-Users-zy-Documents-PerAoKeWu\agent-transcripts"
    r"\62713607-708f-46bb-adbb-7584279feab9\62713607-708f-46bb-adbb-7584279feab9.jsonl"
)
OUT = Path(__file__).resolve().parent / "extracted_runner_snippets"
FEATURES = [
    "speed_boost",
    "shatter",
    "coin_pickup",
    "finish_sprint",
    "emergency_dash",
    "meteorite",
    "_make_obstacle",
    "distant_density",
]

def main() -> None:
    OUT.mkdir(exist_ok=True)
    buckets: dict[str, list[tuple[int, str]]] = {k: [] for k in FEATURES}
    with TRANSCRIPT.open(encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            if "runner_60s.gd" not in line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            for part in obj.get("message", {}).get("content", []):
                if part.get("type") != "tool_use" or part.get("name") != "StrReplace":
                    continue
                inp = part.get("input", {})
                if not str(inp.get("path", "")).endswith("runner_60s.gd"):
                    continue
                ns = inp.get("new_string", "")
                for feat in FEATURES:
                    if feat in ns:
                        buckets[feat].append((i, ns))
    for feat, items in buckets.items():
        if not items:
            continue
        _, last = items[-1]
        (OUT / f"{feat}.txt").write_text(last, encoding="utf-8")
        print(f"{feat}: {len(items)} patches, last line {items[-1][0]}, {len(last)} chars")

if __name__ == "__main__":
    main()
