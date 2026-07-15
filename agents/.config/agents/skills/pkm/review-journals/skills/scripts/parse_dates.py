#!/usr/bin/env python3
"""Parse a date range argument and output matching journal file paths.

Supports natural language ("this week", "last month", "last 7 days") and
explicit ranges ("2025-01-01 - 2025-01-10", "01/01/2025 - 01/10/2025").

Outputs one absolute file path per line, sorted chronologically.
"""

import argparse
import re
import sys
from datetime import date, datetime, timedelta
from pathlib import Path


def parse_explicit_date(s: str) -> date | None:
    """Try common date formats and return a date, or None."""
    s = s.strip()
    for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%m/%d/%Y", "%Y/%m/%d"):
        try:
            return datetime.strptime(s, fmt).date()
        except ValueError:
            continue
    return None


def month_name_to_number(name: str) -> int | None:
    """Convert month name/abbreviation to number."""
    months = {
        "jan": 1, "january": 1,
        "feb": 2, "february": 2,
        "mar": 3, "march": 3,
        "apr": 4, "april": 4,
        "may": 5,
        "jun": 6, "june": 6,
        "jul": 7, "july": 7,
        "aug": 8, "august": 8,
        "sep": 9, "september": 9,
        "oct": 10, "october": 10,
        "nov": 11, "november": 11,
        "dec": 12, "december": 12,
    }
    return months.get(name.lower())


def last_day_of_month(year: int, month: int) -> int:
    """Return the last day of the given month."""
    if month == 12:
        return 31
    return (date(year, month + 1, 1) - timedelta(days=1)).day


def parse_date_range(expr: str) -> tuple[date, date]:
    """Parse a date range expression into (start, end) inclusive dates.

    Raises ValueError if the expression cannot be parsed.
    """
    today = date.today()
    expr_lower = expr.strip().lower()

    # --- Explicit range: "DATE - DATE" or "DATE to DATE" ---
    for sep in (" - ", " to ", "–", "—"):
        if sep in expr_lower:
            parts = expr.split(sep, 1)
            start = parse_explicit_date(parts[0])
            end = parse_explicit_date(parts[1])
            if start and end:
                return (start, end) if start <= end else (end, start)

    # --- Single explicit date ---
    single = parse_explicit_date(expr)
    if single:
        return (single, single)

    # --- Natural language ---

    if expr_lower == "today":
        return (today, today)

    if expr_lower == "yesterday":
        y = today - timedelta(days=1)
        return (y, y)

    # "this week" = Monday..today
    if expr_lower == "this week":
        monday = today - timedelta(days=today.weekday())
        return (monday, today)

    # "last week" = previous Monday..Sunday
    if expr_lower == "last week":
        last_monday = today - timedelta(days=today.weekday() + 7)
        last_sunday = last_monday + timedelta(days=6)
        return (last_monday, last_sunday)

    # "this month" = 1st of month..today
    if expr_lower == "this month":
        return (today.replace(day=1), today)

    # "last month"
    if expr_lower == "last month":
        first_this = today.replace(day=1)
        last_day_prev = first_this - timedelta(days=1)
        first_prev = last_day_prev.replace(day=1)
        return (first_prev, last_day_prev)

    # "this year"
    if expr_lower == "this year":
        return (date(today.year, 1, 1), today)

    # "last year"
    if expr_lower == "last year":
        return (date(today.year - 1, 1, 1), date(today.year - 1, 12, 31))

    # "last N days/weeks/months"
    m = re.match(r"last\s+(\d+)\s+(day|days|week|weeks|month|months)", expr_lower)
    if m:
        n = int(m.group(1))
        unit = m.group(2).rstrip("s")
        if unit == "day":
            start = today - timedelta(days=n)
        elif unit == "week":
            start = today - timedelta(weeks=n)
        elif unit == "month":
            # Approximate: 30 days per month
            start = today - timedelta(days=n * 30)
        return (start, today)

    # "past N days/weeks/months" (alias for "last N ...")
    m = re.match(r"past\s+(\d+)\s+(day|days|week|weeks|month|months)", expr_lower)
    if m:
        n = int(m.group(1))
        unit = m.group(2).rstrip("s")
        if unit == "day":
            start = today - timedelta(days=n)
        elif unit == "week":
            start = today - timedelta(weeks=n)
        elif unit == "month":
            start = today - timedelta(days=n * 30)
        return (start, today)

    # "month year" e.g. "january 2026", "jan 2025"
    m = re.match(r"(\w+)\s+(\d{4})", expr_lower)
    if m:
        month_num = month_name_to_number(m.group(1))
        year = int(m.group(2))
        if month_num:
            start = date(year, month_num, 1)
            end = date(year, month_num, last_day_of_month(year, month_num))
            return (start, end)

    # "year" e.g. "2025"
    m = re.match(r"^(\d{4})$", expr_lower)
    if m:
        year = int(m.group(1))
        return (date(year, 1, 1), date(year, 12, 31))

    raise ValueError(
        f"Could not parse date range: {expr!r}\n"
        "Supported formats:\n"
        "  Natural language: today, yesterday, this week, last week, this month,\n"
        "                    last month, last N days/weeks/months, january 2026\n"
        "  Explicit range:   2025-01-01 - 2025-01-10\n"
        "  Single date:      2025-01-15"
    )


def find_journals(vault_path: Path, start: date, end: date) -> list[Path]:
    """Find journal files in the date range, sorted chronologically."""
    journals_dir = vault_path / "journals"
    if not journals_dir.is_dir():
        print(f"Error: journals directory not found at {journals_dir}", file=sys.stderr)
        sys.exit(1)

    matches = []
    for f in journals_dir.iterdir():
        if not f.suffix == ".md":
            continue
        d = parse_explicit_date(f.stem)
        if d and start <= d <= end:
            matches.append((d, f))

    matches.sort(key=lambda x: x[0])
    return [f for _, f in matches]


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Resolve a date range and list matching journal files."
    )
    parser.add_argument("range", help="Date range expression")
    parser.add_argument(
        "--vault-path",
        type=Path,
        default=Path.cwd(),
        help="Path to the Obsidian vault (default: cwd)",
    )
    args = parser.parse_args()

    try:
        start, end = parse_date_range(args.range)
    except ValueError as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)

    print(f"# Date range: {start} to {end}", file=sys.stderr)

    files = find_journals(args.vault_path, start, end)
    if not files:
        print("No journal files found in this date range.", file=sys.stderr)
        sys.exit(0)

    print(f"# Found {len(files)} journal(s)", file=sys.stderr)
    for f in files:
        print(f)


if __name__ == "__main__":
    main()
