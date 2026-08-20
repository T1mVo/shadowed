#!/usr/bin/env python3

import argparse
import json
import math
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

script_dir = Path(__file__).parent
project_dir = script_dir.parent


def run_git(args, check=True):
    result = subprocess.run(
        ["git", "-C", str(project_dir), *args],
        capture_output=True,
        text=True,
    )
    if check and result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    return result


def resolve_ref(name):
    result = run_git(["rev-parse", "--verify", name + "^{commit}"], check=False)
    if result.returncode != 0:
        print(f"error: {name!r} is not a git commit", file=sys.stderr)
        print("hint: the commit must be visible to git (run `jj git export` first)", file=sys.stderr)
        sys.exit(2)
    return result.stdout.strip()


def checkout(revision):
    parent = Path(tempfile.mkdtemp(prefix="compare-commits-"))
    worktree = parent / "worktree"
    run_git(["worktree", "add", "--detach", str(worktree), revision])
    return worktree


def remove_worktree(worktree):
    run_git(["worktree", "remove", "--force", str(worktree)], check=False)
    try:
        worktree.parent.rmdir()
    except OSError:
        pass


def discover(worktree):
    tests_dir = worktree / "tests"
    if not tests_dir.is_dir():
        return []
    return sorted(str(test.relative_to(tests_dir)) for test in tests_dir.glob("*/*/test.typ"))


def compile_test(worktree, test, output_file):
    start = time.perf_counter()
    result = subprocess.run(
        [
            "typst",
            "compile",
            "--root",
            str(worktree),
            "--format",
            "png",
            "--ppi",
            "144",
            str(worktree / "tests" / test),
            str(output_file),
        ],
        capture_output=True,
    )
    return time.perf_counter() - start, result.returncode


def benchmark(worktree, tests, iters, stat):
    output_dir = Path(tempfile.mkdtemp(prefix="compare-output-"))
    compile_test(worktree, tests[0], output_dir / "warmup.png")

    results = {}
    total = len(tests)
    for index, test in enumerate(tests, 1):
        samples = []
        failed = False
        for run in range(iters):
            output_file = output_dir / f"{index}-{run}-{{p}}.png"
            elapsed, return_code = compile_test(worktree, test, output_file)
            if return_code != 0:
                failed = True
            else:
                samples.append(elapsed)
        ms = None if failed or not samples else stat(samples)
        results[test] = (ms, failed)
        if failed:
            print(f"  [{index}/{total}] {test}  FAILED", file=sys.stderr)
        elif ms is not None:
            print(f"  [{index}/{total}] {test}  {ms * 1000:.1f} ms")

    shutil.rmtree(output_dir, ignore_errors=True)
    return results


def format_ms(ms):
    return "     n/a" if ms is None else f"{ms * 1000:7.1f}"


def print_report(old_rev, new_rev, old_results, new_results, threshold, json_path):
    names = sorted(set(old_results) | set(new_results))
    name_width = max(5, max(len(name) for name in names))

    stats = []
    failures = 0
    regressions = 0

    print()
    print(f"{'test':<{name_width}}  {'old(ms)':>8}  {'new(ms)':>8}  {'delta':>8}  verdict")
    print("-" * (name_width + 40))

    for name in names:
        old_entry = old_results.get(name)
        new_entry = new_results.get(name)
        old_ms = old_entry[0] if old_entry else None
        new_ms = new_entry[0] if new_entry else None

        if old_entry is None and new_entry is None:
            continue
        if old_entry is None:
            print(f"{name:<{name_width}}  {format_ms(old_ms)}  {format_ms(new_ms)}  {'—':>7}  only in new")
            continue
        if new_entry is None:
            print(f"{name:<{name_width}}  {format_ms(old_ms)}  {format_ms(new_ms)}  {'—':>7}  only in old")
            continue

        old_failed, new_failed = old_entry[1], new_entry[1]

        if old_failed or new_failed:
            failures += 1
            verdict = "FAILED"
            delta = "—"
        else:
            ratio = new_ms / old_ms
            delta = f"{(ratio - 1) * 100:+.1f}%"
            if ratio >= threshold:
                verdict = "SLOWER"
                regressions += 1
            elif ratio <= 1 / threshold:
                verdict = "FASTER"
            else:
                verdict = "SAME"
            stats.append((old_ms, new_ms, ratio))

        print(f"{name:<{name_width}}  {format_ms(old_ms)}  {format_ms(new_ms)}  {delta:>7}  {verdict}")

    print("-" * (name_width + 40))

    if stats:
        old_sum = sum(entry[0] for entry in stats)
        new_sum = sum(entry[1] for entry in stats)
        ratios = [entry[2] for entry in stats]
        mean_ratio = sum(ratios) / len(ratios)
        geo_ratio = math.exp(sum(math.log(ratio) for ratio in ratios) / len(ratios))
        print(f"sum old:      {old_sum * 1000:7.1f} ms")
        print(f"sum new:      {new_sum * 1000:7.1f} ms")
        print(f"total delta:  {(new_sum / old_sum - 1) * 100:+.1f}%")
        print(f"mean ratio:   {mean_ratio:.3f}   geo mean: {geo_ratio:.3f}")

    if regressions or failures:
        reason = []
        if failures:
            reason.append(f"{failures} failed test(s)")
        if regressions:
            reason.append(f"{regressions} regression(s) >= {threshold * 100:.0f}%")
        print(f"\nresult: FAIL ({', '.join(reason)})")
    else:
        print("\nresult: PASS")

    if json_path:
        output = {
            "old": {"rev": old_rev, "tests": {name: {"ms": ms, "failed": f} for name, (ms, f) in old_results.items()}},
            "new": {"rev": new_rev, "tests": {name: {"ms": ms, "failed": f} for name, (ms, f) in new_results.items()}},
            "threshold": threshold,
            "failures": failures,
            "regressions": regressions,
        }
        Path(json_path).write_text(json.dumps(output, indent=2) + "\n")

    return 1 if failures or regressions else 0


def main():
    parser = argparse.ArgumentParser(description="Benchmark the test suite of two commits against each other.")
    parser.add_argument("old", metavar="<commit>", help="the baseline commit")
    parser.add_argument("new", metavar="<commit>", help="the commit to compare")
    parser.add_argument("--iters", type=int, default=3, help="compiles per test (default: 3)")
    parser.add_argument("--stat", choices=("average", "min"), default="average", help="how to combine repeat compiles (default: average)")
    parser.add_argument("--threshold", type=float, default=1.10, help="exit-failing slowdown ratio (default: 1.10)")
    parser.add_argument("--json", metavar="PATH", help="write raw results as JSON")
    args = parser.parse_args()

    stat = {"average": lambda samples: sum(samples) / len(samples), "min": min}[args.stat]

    old_rev = resolve_ref(args.old)
    new_rev = resolve_ref(args.new)

    old_worktree = checkout(old_rev)
    new_worktree = checkout(new_rev)
    try:
        old_tests = discover(old_worktree)
        new_tests = discover(new_worktree)

        if not old_tests:
            print(f"error: no tests found in {old_rev[:8]}", file=sys.stderr)
            sys.exit(2)
        if not new_tests:
            print(f"error: no tests found in {new_rev[:8]}", file=sys.stderr)
            sys.exit(2)

        print(f"{old_rev[:8]}  {len(old_tests)} tests")
        print(f"{new_rev[:8]}  {len(new_tests)} tests")

        old_results = benchmark(old_worktree, old_tests, args.iters, stat)
        new_results = benchmark(new_worktree, new_tests, args.iters, stat)

        sys.exit(print_report(old_rev, new_rev, old_results, new_results, args.threshold, args.json))
    finally:
        remove_worktree(new_worktree)
        remove_worktree(old_worktree)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)