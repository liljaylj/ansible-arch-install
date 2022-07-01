#!/bin/env python3
# vim: ft=python

from subprocess import run
from yaml import dump
from os.path import exists

try:
    from yaml import CDumper as Dumper
except ImportError:
    from yaml import Dumper


def parse_result(s: str):
    result = {}
    for line in s.splitlines():
        name, desc, optstr = map(str.strip, line.split("###", maxsplit=2))
        pkg = {}
        pkg["desc"] = desc
        if len(optstr) > 0:
            pkg["opts"] = dict(
                tuple(map(str.strip, opt.partition(":")))[::2]
                for opt in optstr.split("|||")
            )
        result[name] = pkg
    return result


def parse_optsignore(s: str):
    result = {"": set()}
    for line in sorted(s.splitlines()):
        comment_index = line.find("#")
        if comment_index >= 0:
            line = line[:comment_index]
        if len(line.strip()) == 0:
            continue
        names, colon, opts = map(str.strip, line.partition(":"))
        if colon == ":":
            if len(names) > 0:
                for name in filter(
                    lambda i: len(i) > 0, set(map(str.strip, names.split(",")))
                ):
                    if len(opts) > 0:
                        result.setdefault(name, set())
                        result[name] |= set(
                            filter(
                                lambda i: len(i) > 0, map(str.strip, opts.split(","))
                            )
                        )
                    else:
                        result[name] = set()
            else:
                result[""] |= set(
                    filter(lambda i: len(i) > 0, map(str.strip, opts.split(",")))
                )
        else:
            for name in filter(
                lambda i: len(i) > 0, set(map(str.strip, names.split(",")))
            ):
                result[name] = set()
                result[""].add(name)
    return result


def load_optsignore():
    if exists(".optsignore"):
        with open(".optsignore") as file:
            return parse_optsignore(file.read())
    return {}


def pkgs_with_opts():
    ignore_dict = load_optsignore()
    result = run(["expac", "-l", "|||", "%n###%d###%O"], capture_output=True, text=True)

    pkgs = parse_result(result.stdout)
    pkgs_set = set(pkgs.keys())
    pkgs_to_remove = set()
    for name, pkg in pkgs.items():
        if "opts" in pkg:
            opts = pkg["opts"]
            opts_keys = set(opts.keys())
            opts_to_remove = pkgs_set & opts_keys
            ignored_opts = ignore_dict.get(name)
            if ignored_opts is not None:
                if len(ignored_opts) == 0:
                    pkgs_to_remove.add(name)
                    continue
                opts_to_remove |= ignored_opts & opts_keys
            opts_to_remove |= ignore_dict.get("", set()) & opts_keys
            for opt in opts_to_remove:
                del opts[opt]
            if len(opts) == 0:
                pkgs_to_remove.add(name)
        else:
            pkgs_to_remove.add(name)

    for pkg in pkgs_to_remove:
        del pkgs[pkg]

    return pkgs


if __name__ == "__main__":
    print(dump(pkgs_with_opts(), Dumper=Dumper))
