#!/usr/bin/env python3
import sys, re, textwrap, pathlib

WIDTH = 80

def wrap_paragraph(text, prefix=""):
    if not text.strip():
        return [""]
    body = re.sub(r"\s+", " ", text.strip())
    return [prefix + line for line in textwrap.wrap(body, width=WIDTH - len(prefix))] or [prefix.rstrip()]

def process(lines):
    out = []
    in_code = False
    para = []
    para_prefix = ""
    def flush():
        nonlocal para, para_prefix
        if not para:
            return
        joined = " ".join(para)
        out.extend(wrap_paragraph(joined, para_prefix))
        para = []
        para_prefix = ""
    bullet_re = re.compile(r"^(- |\* |[0-9]+\. )")
    for line in lines:
        stripped = line.rstrip("\n")
        fence = stripped.startswith("```")
        if fence:
            flush()
            in_code = not in_code
            out.append(stripped)
            continue
        if in_code:
            out.append(stripped)
            continue
        if not stripped.strip():
            flush()
            out.append("")
            continue
        if stripped.startswith("|") or stripped.startswith("> ") or stripped.startswith(">"):
            flush()
            out.append(stripped)
            continue
        m = bullet_re.match(stripped)
        if m:
            flush()
            prefix = m.group(0)
            content = stripped[len(prefix):]
            para = [content]
            para_prefix = prefix
            flush()
            continue
        if stripped.startswith("#"):
            flush()
            out.append(stripped)
            continue
        # regular paragraph line
        para.append(stripped)
    flush()
    return out

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: wrap-md.py <file> [<file> ...]", file=sys.stderr)
        sys.exit(2)
    for path in sys.argv[1:]:
        p = pathlib.Path(path)
        original = p.read_text().splitlines()
        wrapped = process(original)
        p.write_text("\n".join(wrapped) + "\n")
