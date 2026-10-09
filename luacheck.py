#!/usr/bin/env python3
"""Syntax checker and safe fixer for the Dominant Lua files (Luau subset).

Check:  python3 tools/luacheck.py [path ...]        (default: the repository, tools/ and reference/ skipped)
Fix:    python3 tools/luacheck.py --fix [path ...]  (writes changes, keeps a .bak next to each changed file)

Problems found (codes):
  unclosed_string   string without its closing quote on the same line
  unclosed_long     [[ ]] or --[[ ]] without its closing bracket
  stray_char        characters Lua does not use (` $ @ \\ !) outside strings and comments
  bad_char          other characters that are not valid Lua
  unclosed_block    function / if / do / repeat that never closes (end or until missing)
  extra_end         end or until without an open block
  mismatch          end or until that closes the wrong kind of block
  missing_then      if / elseif without then
  missing_do        for / while without do
  lone_value        a single name or literal on its own line (a statement that does nothing)
  bad_operator      !=  &&  ||  (other languages' operators; Lua uses ~=  and  or)

Fixes (only kept when the number of problems in the file goes down):
  stray_char, unclosed_string, bad_operator, missing_then, missing_do, lone_value,
  extra_end (removes a line that is only 'end'), unclosed_block (adds 'end' or 'until' at the
  end of the file; check the indentation afterwards).
The checker does not run code and cannot know whether a Roblox API exists.
"""
import os
import re
import shutil
import sys

KEYWORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in",
    "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
}
OPERATORS = ["...", "..", "==", "~=", "<=", ">=", "//", "::", "+=", "-=", "*=", "/=", "%=", "^=",
             "+", "-", "*", "/", "%", "^", "#", "<", ">", "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", ".", "&", "|", "?", "~"]
STRAY = set("`$@\\!")
CONTINUATION = ("(", ",", "=", "..", "{", "[", "+", "-", "*", "/", "%", "^", "and", "or", "not", "==", "~=", "<", ">", "<=", ">=", ":", ".")


def problem(code, line, message):
    return {"code": code, "line": line, "message": message}


def tokenize(text, problems):
    """Yields (kind, value, line). Comments and whitespace are skipped."""
    i, line, n = 0, 1, len(text)
    while i < n:
        c = text[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        if c in " \t\r":
            i += 1
            continue
        if text.startswith("--", i):
            m = re.match(r"--\[(=*)\[", text[i:])
            if m:
                close = "]" + m.group(1) + "]"
                end = text.find(close, i)
                if end < 0:
                    problems.append(problem("unclosed_long", line, "block comment is never closed"))
                    return
                line += text.count("\n", i, end)
                i = end + len(close)
            else:
                end = text.find("\n", i)
                i = n if end < 0 else end
            continue
        m = re.match(r"\[(=*)\[", text[i:])
        if m:
            close = "]" + m.group(1) + "]"
            end = text.find(close, i + len(m.group(0)))
            if end < 0:
                problems.append(problem("unclosed_long", line, "long string is never closed"))
                return
            yield ("string", text[i:end], line)
            line += text.count("\n", i, end)
            i = end + len(close)
            continue
        if c in "\"'":
            j = i + 1
            while j < n and text[j] not in (c, "\n"):
                if text[j] == "\\":
                    j += 1
                j += 1
            if j >= n or text[j] != c:
                problems.append(problem("unclosed_string", line, "string is not closed on this line"))
                i = j
                continue
            yield ("string", text[i:j + 1], line)
            i = j + 1
            continue
        m = re.match(r"(0[xX][0-9a-fA-F_]+|\d[\d_]*\.?[\d_]*([eE][+-]?\d+)?|\.\d+)", text[i:])
        if m:
            yield ("number", m.group(0), line)
            i += len(m.group(0))
            continue
        m = re.match(r"[A-Za-z_][A-Za-z0-9_]*", text[i:])
        if m:
            word = m.group(0)
            yield ("keyword" if word in KEYWORDS else "name", word, line)
            i += len(word)
            continue
        for op in OPERATORS:
            if text.startswith(op, i):
                yield ("op", op, line)
                i += len(op)
                break
        else:
            if c in STRAY:
                problems.append(problem("stray_char", line, "character %r is not Lua" % c))
            else:
                problems.append(problem("bad_char", line, "character %r is not valid Lua" % c))
            i += 1


def check_blocks(tokens, problems):
    """for and while open their own block; the 'do' after them does not open a second one."""
    stack = []
    loop_waiting_do = False
    for kind, value, line in tokens:
        if kind != "keyword":
            continue
        if value in ("function", "repeat"):
            stack.append((value, line))
        elif value in ("for", "while"):
            stack.append(("loop", line))
            loop_waiting_do = True
        elif value == "do":
            if loop_waiting_do:
                loop_waiting_do = False
            else:
                stack.append(("do", line))
        elif value == "if":
            stack.append(("if", line))
        elif value in ("end", "until"):
            if not stack:
                problems.append(problem("extra_end", line, "'%s' without an open block" % value))
                continue
            opener, oline = stack.pop()
            expected = "until" if opener == "repeat" else "end"
            if value != expected:
                problems.append(problem("mismatch", line, "'%s' closes '%s' from line %d (expected '%s')"
                                        % (value, opener, oline, expected)))
    for opener, oline in stack:
        expected = "until" if opener == "repeat" else "end"
        problems.append(problem("unclosed_block", oline, "'%s' is never closed (missing '%s')" % (opener, expected)))


def check_headers(tokens, problems):
    """'then' after if/elseif and 'do' after for/while may sit on a later line (multi-line headers).
    Every header keeps its own entry, so a header is never lost when another one starts."""
    pending = []
    for kind, value, line in tokens:
        still = []
        for entry in pending:
            if line > entry["line"] + 12:
                problems.append(problem(entry["code"], entry["line"], "'%s' without '%s'" % (entry["word"], entry["need"])))
            else:
                still.append(entry)
        pending = still
        if kind == "keyword" and value in ("then", "do"):
            pending = [e for e in pending if e["need"] != value]
            continue
        if kind == "keyword" and value in ("if", "elseif"):
            pending.append({"word": value, "line": line, "need": "then", "code": "missing_then"})
        elif kind == "keyword" and value in ("for", "while"):
            pending.append({"word": value, "line": line, "need": "do", "code": "missing_do"})
    for entry in pending:
        problems.append(problem(entry["code"], entry["line"], "'%s' without '%s'" % (entry["word"], entry["need"])))


def strip_strings(code):
    return re.sub(r"\"(?:\\.|[^\"\\])*\"|'(?:\\.|[^'\\])*'", '""', code)


def check_lines(lines, problems):
    previous = ""
    for number, raw in enumerate(lines, 1):
        code = re.sub(r"--.*$", "", raw).rstrip()
        bare = strip_strings(code).strip()
        if bare:
            if re.search(r"!=|&&|\|\|", bare):
                problems.append(problem("bad_operator", number, "use '~=', 'and' or 'or' (Lua operators)"))
            single = bare.rstrip(";").strip()
            if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*|\d+(\.\d+)?|\"\"|''", single) and single not in KEYWORDS:
                continuing = previous.endswith(CONTINUATION)
                if not continuing:
                    problems.append(problem("lone_value", number, "a single value on its own line does nothing: %r" % single))
            previous = bare
    return problems


def check_text(text):
    problems = []
    tokens = list(tokenize(text, problems))
    check_blocks(tokens, problems)
    check_headers(tokens, problems)
    check_lines(text.split("\n"), problems)
    return sorted(problems, key=lambda p: (p["line"], p["code"]))


def fix_text(text):
    """Applies one round of fixes. Returns (new_text, list of descriptions)."""
    lines = text.split("\n")
    problems = check_text(text)
    changes = []
    delete = set()
    for p in problems:
        index = p["line"] - 1
        if index < 0 or index >= len(lines):
            continue
        code = p["code"]
        line = lines[index]
        if code == "stray_char":
            lines[index] = re.sub(r"[`$@\\!]", "", line, count=1)
            changes.append((p["line"], "removed a stray character"))
        elif code == "unclosed_string":
            quote = "'" if line.count("'") % 2 == 1 else '"'
            lines[index] = line.rstrip() + quote
            changes.append((p["line"], "closed the string"))
        elif code == "bad_operator":
            new = line.replace("!=", "~=").replace("&&", " and ").replace("||", " or ")
            if new != line:
                lines[index] = new
                changes.append((p["line"], "replaced the operator with the Lua one"))
        elif code in ("missing_then", "missing_do"):
            word = "then" if code == "missing_then" else "do"
            header = re.sub(r"--.*$", "", line).strip()
            ends_here = header.startswith(("if", "elseif", "for", "while")) and not header.endswith(("then", "do", "and", "or", ",", "("))
            has_more = re.search(r"\b(end|until|then|do)\b", header) is not None and word not in re.findall(r"\b(then|do)\b", header)
            indent = lambda text: len(text) - len(text.lstrip(" \t"))
            body_below = index + 1 < len(lines) and indent(lines[index + 1]) > indent(line) and lines[index + 1].strip() != ""
            if ends_here and not has_more and body_below:
                lines[index] = line.rstrip() + " " + word
                changes.append((p["line"], "added '%s'" % word))
        elif code == "lone_value":
            delete.add(index)
            changes.append((p["line"], "removed a line that does nothing"))
        elif code == "extra_end" and lines[index].strip() in ("end", "until"):
            delete.add(index)
            changes.append((p["line"], "removed an extra '%s'" % lines[index].strip()))
    lines = [l for i, l in enumerate(lines) if i not in delete]
    if any(p["code"] == "unclosed_block" for p in problems):
        openers = [p for p in problems if p["code"] == "unclosed_block"]
        while lines and lines[-1].strip() == "":
            lines.pop()
        for opener in sorted(openers, key=lambda p: -p["line"]):
            closer = "until" if "repeat" in opener["message"] else "end"
            lines.append(closer)
            changes.append((opener["line"], "added '%s' at the end of the file (check the indentation)" % closer))
        lines.append("")
    return "\n".join(lines), changes


def process(path, fix):
    with open(path, encoding="utf-8") as handle:
        original = handle.read()
    problems = check_text(original)
    if not fix or not problems:
        return [(path, p["line"], p["code"], p["message"]) for p in problems], []
    current, applied = original, []
    for _ in range(5):
        new_text, changes = fix_text(current)
        if new_text == current:
            break
        if len(check_text(new_text)) >= len(check_text(current)):
            break
        applied.extend(changes)
        current = new_text
    if current != original:
        shutil.copyfile(path, path + ".bak")
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(current)
    remaining = check_text(current)
    return [(path, p["line"], p["code"], p["message"]) for p in remaining], applied


def collect(roots):
    files = []
    for root in roots:
        if os.path.isfile(root):
            files.append(root)
            continue
        for folder, _, names in os.walk(root):
            parts = folder.split(os.sep)
            if "tools" in parts or "reference" in parts:
                continue
            files.extend(os.path.join(folder, name) for name in names if name.endswith(".lua"))
    return sorted(files)


def main(argv):
    fix = "--fix" in argv
    args = [a for a in argv[1:] if a != "--fix"]
    roots = args or [os.path.dirname(os.path.dirname(os.path.abspath(__file__)))]
    total_left = 0
    for path in collect(roots):
        left, applied = process(path, fix)
        for _, line, code, message in left:
            total_left += 1
            print("%s:%d: [%s] %s" % (os.path.relpath(path), line, code, message))
        for line, description in applied:
            print("%s:%d: fixed: %s" % (os.path.relpath(path), line, description))
    print("%d problem(s) left" % total_left)
    return 1 if total_left else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
