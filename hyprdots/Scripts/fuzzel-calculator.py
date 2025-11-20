#!/usr/bin/env python3
from os import system
from pathlib import Path
from time import time
import sympy
from sympy import symbols, Eq, solve, sympify

BASE = Path.home() / ".local/share/fuzzel_calc/"
HIST = BASE / "history.txt"
CONF = BASE / "config.txt"

BASE.mkdir(parents=True, exist_ok=True)
HIST.touch(exist_ok=True)
CONF.touch(exist_ok=True)


def fuzzel(prompt, items):
    temp = BASE / "menu_input.txt"
    tmp_out = BASE / "menu_out.txt"

    with open(temp, "w") as f:
        f.write("\n".join(items))

    system(f"cat '{temp}' | fuzzel --dmenu -p '{prompt}' > '{tmp_out}'")

    with open(tmp_out) as f:
        return f.read().strip()


def load_config():
    cfg = {"sort": "newest"}
    with open(CONF) as f:
        for line in f:
            if "=" in line:
                k, v = line.strip().split("=", 1)
                cfg[k] = v
    return cfg


def save_config(cfg):
    with open(CONF, "w") as f:
        for k, v in cfg.items():
            f.write(f"{k}={v}\n")


def load_history():
    out = []
    with open(HIST) as f:
        for line in f:
            line = line.strip()
            if " = " not in line: 
                continue

            parts = line.split(" | ")
            expr, result = parts[0].split(" = ", 1)

            meta = {"favorite": "False", "timestamp": "0"}
            for p in parts[1:]:
                if "=" in p:
                    k, v = p.split("=", 1)
                    meta[k] = v

            out.append({
                "expr": expr,
                "result": result,
                "favorite": meta["favorite"] == "True",
                "timestamp": int(meta["timestamp"]),
            })
    return out


def write_history(entries):
    with open(HIST, "w") as f:
        for e in entries:
            f.write(
                f"{e['expr']} = {e['result']} | "
                f"favorite={str(e['favorite'])} | "
                f"timestamp={e['timestamp']}\n"
            )


def save_problem(expr, result):
    ts = int(time())
    with open(HIST, "a") as f:
        f.write(f"{expr} = {result} | favorite=False | timestamp={ts}\n")


def eval_expr(expr):
    """Evaluate an expression using SymPy, including multi-variable equations."""
    try:
        if "=" in expr:
            left_str, right_str = expr.split("=")
            left = sympify(left_str)
            right = sympify(right_str)
            eq = Eq(left, right)
            vars = list(eq.free_symbols)
            sol = solve(eq, vars, dict=True)

            if not sol:
                return "Equation not solvable"

            # Single-variable special formatting
            if len(vars) == 1:
                var = vars[0]
                val = sol[0][var]
                return f"{var} = {val}, l = {{{val}}}"

            # Multi-variable formatting
            solutions = []
            for s in sol:
                solutions.append(", ".join(f"{k} = {v}" for k, v in s.items()))
            return "; ".join(solutions)
        else:
            return str(sympify(expr))
    except Exception:
        return "Equation not solvable"


def confirm(prompt):
    c1 = fuzzel(prompt, ["no", "yes"])
    if c1 != "yes":
        return False
    c2 = fuzzel("are you VERY sure?", ["no", "yes"])
    return c2 == "yes"


def sort_entries(entries, cfg):
    entries.sort(key=lambda x: x["timestamp"], reverse=(cfg["sort"] == "newest"))
    entries.sort(key=lambda x: not x["favorite"])
    return entries


def result_menu(entry, entries):
    expr = entry["expr"]
    result = entry["result"]

    choice = fuzzel("calculator >", [
        result,
        "copy",
        ("favorite" if not entry["favorite"] else "unfavorite"),
        "delete",
        "back"
    ])

    if choice == "back":
        return entries

    if choice == "copy":
        system(f"printf '%s' '{result}' | xclip -selection clipboard")
        return entries

    if choice == "favorite":
        entry["favorite"] = True
        write_history(entries)
        return entries

    if choice == "unfavorite":
        entry["favorite"] = False
        write_history(entries)
        return entries

    if choice == "delete":
        if confirm("are you sure?"):
            entries = [e for e in entries if e["expr"] != expr]
            write_history(entries)
        return entries

    return entries


def delete_submenu(entries):
    items = [e["expr"] for e in entries] + ["back"]
    choice = fuzzel("delete >", items)

    if choice == "" or choice == "back":
        return entries

    for e in entries:
        if e["expr"] == choice:
            if confirm("are you sure?"):
                entries.remove(e)
                write_history(entries)
            break

    return entries


def main():
    cfg = load_config()

    while True:
        entries = load_history()
        entries = sort_entries(entries, cfg)

        favs = [e["expr"] for e in entries if e["favorite"]]
        normals = [e["expr"] for e in entries if not e["favorite"]]

        items = favs + normals + [
            f"sort: {cfg['sort']}",
            "clear all",
            "delete",
            "exit"
        ]

        choice = fuzzel("calculator >", items)

        if choice == "" or choice == "exit":
            break

        if choice.startswith("sort:"):
            cfg["sort"] = "oldest" if cfg["sort"] == "newest" else "newest"
            save_config(cfg)
            continue

        if choice == "clear all":
            if confirm("are you sure?"):
                write_history([])
            continue

        if choice == "delete":
            entries = delete_submenu(entries)
            continue

        # existing equation
        for e in entries:
            if e["expr"] == choice:
                entries = result_menu(e, entries)
                break
        else:
            # new equation
            expr = choice
            result = eval_expr(expr)

            # answer menu for new equation: clicking answer saves and returns
            answer_choice = fuzzel("calculator >", [result, "back"])
            if answer_choice in [result, "back"]:
                save_problem(expr, result)


if __name__ == "__main__":
    main()

