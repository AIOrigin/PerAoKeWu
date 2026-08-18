"""Replay runner_60s.gd StrReplace patches from agent transcript onto git HEAD base."""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RUNNER = ROOT / "assets/maps/route_levels/runner_60s/runner_60s.gd"
TRANSCRIPT = Path(
    r"C:\Users\zy洋芋糍粑\.cursor\projects\c-Users-zy-Documents-PerAoKeWu\agent-transcripts"
    r"\62713607-708f-46bb-adbb-7584279feab9\62713607-708f-46bb-adbb-7584279feab9.jsonl"
)
OUT = RUNNER.with_suffix(".gd.reconstructed")


def git_base() -> str:
    proc = subprocess.run(
        ["git", "show", "HEAD:assets/maps/route_levels/runner_60s/runner_60s.gd"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        check=True,
    )
    return proc.stdout


def main() -> None:
    content = git_base()
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
    lines = content.count("\n") + 1
    print(f"Wrote {OUT}")
    print(f"Lines: {lines}, applied: {applied}, failed: {failed}")
    for needle in (
        "speed_boost",
        "_shatter_obstacle",
        "_spawn_coin_pickup_burst",
        "_register_speed_boost",
        "emergency_dash",
        "finish_sprint",
        "coarse_desert",
        "BodyButterflyAura",
    ):
        print(f"  {needle}: {'yes' if needle in content else 'no'}")


if __name__ == "__main__":
    main()
