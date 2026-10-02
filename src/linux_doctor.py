#!/usr/bin/env python3
"""Linux Doctor: a small, read-only Linux diagnostic CLI."""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

VERSION = "0.1.0"
ROOT = Path(__file__).resolve().parent.parent
CHECKS = [
    "system.sh",
    "hardware.sh",
    "storage.sh",
    "network.sh",
    "services.sh",
    "kernel.sh",
    "processes.sh",
]

@dataclass
class Finding:
    section: str
    status: str
    label: str
    value: str
    detail: str = ""


def parse_line(line: str) -> Finding | None:
    parts = line.rstrip("\n").split("\t", 4)
    if len(parts) != 5:
        return None
    section, status, label, value, detail = parts
    if status not in {"ok", "info", "warn", "error"}:
        status = "info"
    return Finding(section, status, label, value, detail)


def run_checks() -> list[Finding]:
    findings: list[Finding] = []
    for name in CHECKS:
        script = ROOT / "checks" / name
        try:
            result = subprocess.run(
                ["bash", str(script)], capture_output=True, text=True, timeout=20, check=False
            )
            for line in result.stdout.splitlines():
                finding = parse_line(line)
                if finding:
                    findings.append(finding)
            if result.returncode != 0:
                findings.append(Finding(name.removesuffix(".sh").title(), "info", "Check", "Incomplete", "The check exited early."))
        except (OSError, subprocess.TimeoutExpired) as exc:
            findings.append(Finding(name.removesuffix(".sh").title(), "info", "Check", "Skipped", str(exc)))
    return findings


def icon(status: str) -> str:
    return {"ok": "✓", "warn": "⚠", "error": "✗", "info": "·"}.get(status, "·")


def color(text: str, status: str, enabled: bool) -> str:
    if not enabled:
        return text
    codes = {"ok": "32", "warn": "33", "error": "31", "info": "36"}
    return f"\033[{codes.get(status, '0')}m{text}\033[0m"


def grouped(findings: Iterable[Finding]) -> dict[str, list[Finding]]:
    result: dict[str, list[Finding]] = {}
    for finding in findings:
        result.setdefault(finding.section, []).append(finding)
    return result


def render_terminal(findings: list[Finding], details: bool = False) -> str:
    use_color = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None
    groups = grouped(findings)
    lines = ["linux-doctor", ""]
    for section, items in groups.items():
        lines.extend([section, "─" * 28])
        for item in items:
            marker = color(icon(item.status), item.status, use_color)
            row = f"{marker} {item.label}: {item.value}"
            lines.append(row)
            if details and item.detail:
                lines.append(f"  {item.detail}")
        lines.append("")
    warnings = sum(item.status in {"warn", "error"} for item in findings)
    if warnings:
        ending = f"{warnings} thing{'s' if warnings != 1 else ''} worth looking at."
    else:
        ending = "Nothing urgent found."
    lines.extend(["─" * 28, ending])
    return "\n".join(lines)


def report_markdown(findings: list[Finding]) -> str:
    groups = grouped(findings)
    warnings = sum(item.status in {"warn", "error"} for item in findings)
    lines = ["# Linux Doctor report", "", f"Issues worth looking at: **{warnings}**", ""]
    for section, items in groups.items():
        lines.extend([f"## {section}", "", "| Status | Check | Result | Detail |", "|---|---|---|---|"])
        for item in items:
            status = {"ok": "OK", "warn": "Warning", "error": "Error", "info": "Info"}.get(item.status, "Info")
            detail = item.detail.replace("|", "\\|")
            lines.append(f"| {status} | {item.label} | {item.value.replace('|', '\\|')} | {detail} |")
        lines.append("")
    lines.append("This report contains local system observations collected by Linux Doctor. No changes were made.")
    return "\n".join(lines) + "\n"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="A small, read-only Linux diagnostic tool.")
    parser.add_argument("--details", action="store_true", help="include how each result was checked")
    parser.add_argument("--json", action="store_true", dest="as_json", help="write findings as JSON")
    parser.add_argument("--report", metavar="FILE", help="write a Markdown report to FILE")
    parser.add_argument("--version", action="version", version=f"linux-doctor {VERSION}")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    findings = run_checks()
    if args.as_json:
        payload = {
            "tool": "linux-doctor",
            "version": VERSION,
            "findings": [asdict(item) for item in findings],
            "issues": sum(item.status in {"warn", "error"} for item in findings),
        }
        print(json.dumps(payload, indent=2))
    else:
        print(render_terminal(findings, args.details))
    if args.report:
        try:
            Path(args.report).write_text(report_markdown(findings), encoding="utf-8")
        except OSError as exc:
            print(f"linux-doctor: could not write report: {exc}", file=sys.stderr)
            return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
