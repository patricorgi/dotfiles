import re


def mark(text, args, Mark, extra_cli_args, *a):
    pattern = r'KEY: \S+\s+([^\s;]+);'
    for idx, m in enumerate(re.finditer(pattern, text)):
        start, end = m.start(1), m.end(1)
        mark_text = text[start:end].replace('\n', '').replace('\0',
                                                              '')  # + "->cd()"
        yield Mark(idx, start, end, mark_text, {})
