"""Run static analysis, basic behaviour tests and the command-line example."""

from pathlib import Path
import os
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def tool(name):
    suffix = ".exe" if os.name == "nt" else ""
    local = ROOT / ".tools" / "luau" / (name + suffix)
    if local.is_file():
        return str(local)
    installed = shutil.which(name)
    if installed:
        return installed
    raise SystemExit(f"Missing {name}. Run python3 scripts/bootstrap.py or put Luau tools on PATH.")


def main():
    source = sorted(str(p.relative_to(ROOT)) for folder in ("packages", "tests", "examples") for p in (ROOT / folder).rglob("*.luau"))
    commands = [
        [tool("luau-analyze"), *source],
        [tool("luau"), "tests/run.luau"],
        [tool("luau"), "examples/basic.luau"],
    ]
    for command in commands:
        print("Running", " ".join(command), flush=True)
        subprocess.run(command, cwd=ROOT, check=True)


if __name__ == "__main__":
    main()
