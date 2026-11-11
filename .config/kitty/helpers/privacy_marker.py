"""Kitty visual masking: private regex list plus IP, host and API-key patterns."""

import re
from pathlib import Path


# Kitty executes this file again when the marker is enabled, reloading the list.
_list_path = Path(__file__).parent.parent / "redact.txt"
_rules = []
for _number, _line in enumerate(
    _list_path.read_text(encoding="utf-8").splitlines(), start=1
):
    _pattern = _line.strip()
    if _pattern and not _pattern.startswith("#"):
        try:
            _rules.append(re.compile(_pattern, re.IGNORECASE))
        except re.error as error:
            raise ValueError(f"{_list_path}:{_number}: {error}") from error

# Do not treat arbitrary dotted filenames as hosts.
_patterns = (
    r"(?<![\w.])(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?![\w.])",
    r"(?<![\w:])(?:[0-9a-f]{0,4}:){2,6}(?:[0-9]{1,3}\.){3}"
    r"[0-9]{1,3}(?:%[\w.-]+)?(?![\w.:])",
    r"(?<![\w:])(?:[0-9a-f]{1,4}:){7}[0-9a-f]{1,4}"
    r"(?:%[\w.-]+)?(?![\w:])",
    r"(?<![\w:])(?:[0-9a-f]{1,4}(?::[0-9a-f]{1,4})*)?::"
    r"(?:[0-9a-f]{1,4}(?::[0-9a-f]{1,4})*)?(?:%[\w.-]+)?(?![\w:])",
    r"(?<![\w.-])(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
    r"(?:cern\.ch|lan|local|internal)(?![\w.-])",
    r"(?:(?<=@)|(?<=ssh\s))[a-z0-9][a-z0-9.-]*",
    r"[\x22\x27]?(?:[a-z0-9]+[_-])*api[_-]?key[\x22\x27]?\s*[:=]\s*"
    r"(?:\x22[^\x22\r\n]+\x22|\x27[^\x27\r\n]+\x27|[^\s,;]+)",
    r"(?:gh[pousr]_[a-z0-9_]{20,}|github_pat_[a-z0-9_]{20,}|"
    r"sk-[a-z0-9_-]{20,}|AIza[a-z0-9_-]{35}|(?:AKIA|ASIA)[A-Z0-9]{16})",
)
_automatic = re.compile("|".join(_patterns), re.IGNORECASE)


def marker(text):
    """Yield ordered, merged ranges with kitty's inclusive end positions."""
    spans = [match.span() for match in _automatic.finditer(text)]
    for pattern in _rules:
        spans.extend(
            match.span() for match in pattern.finditer(text) if match.end() > match.start()
        )

    start, end = 0, 0
    for left, right in sorted(spans):
        if left > end:
            if end > start:
                yield start, end - 1, 1
            start, end = left, right
        else:
            end = max(end, right)
    if end > start:
        yield start, end - 1, 1
