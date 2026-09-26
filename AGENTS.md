# AGENTS.md

## Project Purpose

`ports-checker` uses SSH to discover the TCP ports listening on non-loopback
interfaces of a remote Linux host. It closes the SSH session and then checks
only those ports from the local machine. Allowed ports are not errors. A
reachable unapproved port must cause the command to exit with code `1`.

## Stack and Commands

- Common Lisp; SBCL is the primary supported implementation.
- CLI arguments are defined with `defmain`; do not add a custom `argv` parsing
  loop.
- Dependencies are managed by Qlot; do not edit `.qlot/` manually.
- Run the CLI with `qlot exec ./roswell/ports-checker.ros`.
- Install dependencies with `qlot install`.
- Run tests with `qlot exec ros -Q -e '(asdf:load-asd (truename
  "ports-checker.asd"))' -e '(asdf:test-system "ports-checker")' -q`.

## Development Rules

- Use package-inferred ASDF: a file's package must match its path
  (`src/foo.lisp` → `ports-checker/foo`).
- Define packages with `uiop:define-package`, and import and export symbols
  explicitly.
- Give public functions docstrings and keep lines at or below 100 characters.
- Write tests with Rove and place them under `tests/`.
- Do not replace targeted checks with a full scan or add `nmap`.
- Do not start external port checks until the SSH command has completed.
- Do not suppress SSH errors: an infrastructure failure must make the CLI exit
  with code `2` instead of producing a false success.
- Replace network boundaries in unit tests; the default test suite must not
  require a reachable SSH host or open real network connections.
