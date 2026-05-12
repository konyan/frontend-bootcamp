import shutil
import subprocess
import sys


CHECKS = [
    ("Git", ["git", "--version"]),
    ("Node.js", ["node", "--version"]),
    ("npm", ["npm", "--version"]),
    ("pnpm", ["pnpm", "--version"]),
]


def run_check(name, command):
    try:
        completed = subprocess.run(command, capture_output=True, text=True, check=True)
        version = completed.stdout.strip() or "installed"
        print(f"  [PASS] {name} ({version})")
        return True
    except Exception:
        print(f"  [FAIL] {name}")
        return False


def main():
    print("\n=== Frontend Setup & Tooling Check ===\n")

    print("Core:")
    passed = sum(run_check(name, command) for name, command in CHECKS)
    total = len(CHECKS)

    print(f"\nResult: {passed}/{total} core checks passed")

    if shutil.which("code"):
        print("[INFO] VS Code CLI found")
    else:
        print("[INFO] VS Code CLI not found on PATH")

    if passed == total:
        print("\nYou're ready. Start with Phase 1.\n")
    else:
        print("\nFix the failed checks above, then run this script again.\n")

    return 0 if passed == total else 1


if __name__ == "__main__":
    sys.exit(main())
