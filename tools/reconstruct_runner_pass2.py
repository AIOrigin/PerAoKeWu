"""Second pass: replay failed patches onto first-pass reconstructed runner."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/maps/route_levels/runner_60s/runner_60s.gd.reconstructed"
OUT = ROOT / "assets/maps/route_levels/runner_60s/runner_60s.gd.reconstructed2"
TRANSCRIPT = Path(
    r"C:\Users\zy洋芋糍粑\.cursor\projects\c-Users-zy-Documents-PerAoKeWu\agent-transcripts"
    r"\62713607-708f-46bb-adbb-7584279feab9\62713607-708f-46bb-adbb-7584279feab9.jsonl"
)


def main() -> None:
    content = SRC.read_text(encoding="utf-8")
    applied = 0
    failed = 0
    with TRANSCRIPT.open(encoding="utf-8") as f:
        for line in f:
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
                old = inp.get("old_string", "")
                new = inp.get("new_string", "")
                if not old or old == new:
                    continue
                if old in content:
                    content = content.replace(old, new, 1)
                    applied += 1
                else:
                    failed += 1
    OUT.write_text(content, encoding="utf-8")
    print(f"Lines: {content.count(chr(10))+1}, applied: {applied}, failed: {failed}")
    for needle in (
        "const SPEED_BOOST_MULT",
        "var _speed_boost_timer",
        "func _shatter_obstacle",
        "func _register_speed_boost",
        "func _spawn_coin_pickup_burst",
        "func _uses_smash_collision",
        "func _make_speed_boost",
        "\"train\":",
    ):
        print(f"  {needle}: {'yes' if needle in content else 'no'}")


if __name__ == "__main__":
    main()
