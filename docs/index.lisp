;;;; Main project documentation.

(uiop:define-package #:ports-checker-docs/index
  (:use #:cl)
  (:import-from #:pythonic-string-reader
                #:pythonic-string-syntax)
  #+quicklisp
  (:import-from #:quicklisp)
  (:import-from #:named-readtables
                #:in-readtable)
  (:import-from #:40ants-doc
                #:defsection
                #:defsection-copy)
  (:import-from #:ports-checker-docs/changelog
                #:@changelog)
  (:import-from #:docs-config
                #:docs-config)
  (:import-from #:40ants-doc/autodoc
                #:defautodoc)
  (:export #:@changelog
           #:@index
           #:@readme))
(in-package #:ports-checker-docs/index)

(in-readtable pythonic-string-syntax)

(defmethod docs-config ((system (eql (asdf:find-system "ports-checker-docs"))))
  #+quicklisp
  (ql:quickload "40ants-doc-theme-40ants")
  #-quicklisp
  (asdf:load-system "40ants-doc-theme-40ants")
  (list :theme
        (find-symbol "40ANTS-THEME"
                     (find-package "40ANTS-DOC-THEME-40ANTS"))))

(defsection @index
    (:title "ports-checker — Detect unexpected externally reachable TCP ports"
     :ignore-words ("API"
                    "ASDF"
                    "CLI"
                    "GitHub"
                    "HTML"
                    "Linux"
                    "Qlot"
                    "Rove"
                    "Roswell"
                    "SBCL"
                    "SSH"
                    "TCP"
                    "UDP"
                    "iproute2"
                    "known_hosts"
                    "nmap"))
  (ports-checker system)
  """
`ports-checker` verifies that no unexpected TCP ports have become reachable
after a server configuration change or software installation. It does not scan
a range of ports. Instead, it:

1. connects to the specified server over SSH;
2. runs `ss -H -lnt` to obtain the TCP sockets listening on wildcard and
   non-loopback interfaces;
3. closes the SSH connection;
4. attempts to connect from the local machine only to the discovered ports;
5. exits with code `1` if a reachable port is not on the allowlist.

A service blocked by an external firewall is therefore not considered
reachable, even if its process listens on a non-loopback interface. Startup and
SSH errors cause the command to exit with code `2`.
"""
  (@requirements section)
  (@installation section)
  (@usage section)
  (@exit-codes section)
  (@development section)
  (@limitations section)
  (@api section))

(defsection-copy @readme @index)

(defsection @requirements (:title "Requirements")
  """
- Common Lisp (the project is tested with SBCL);
- [Roswell](https://roswell.github.io/);
- [Qlot](https://github.com/fukamachi/qlot);
- a local `ssh` command;
- the `ss` command from `iproute2` on the Linux server being checked;
- configured non-interactive SSH authentication.

The SSH host key must already be present in `known_hosts`. The command
intentionally does not accept unknown host keys automatically.
""")

(defsection @installation (:title "Installation")
  """
Install the command directly from GitHub with Roswell:

```console
ros install 40ants/ports-checker
ports-checker --allow 22,80,443 example.com
```

To run the command from a local checkout, install and use the Qlot dependencies:

```console
qlot install
chmod +x roswell/ports-checker.ros
qlot exec ./roswell/ports-checker.ros --allow 22,80,443 example.com
```
""")

(defsection @usage (:title "Usage")
  """
The `--allow` (`-a`) option accepts a comma-separated list of ports. The SSH
user and SSH port can be specified separately:

```console
qlot exec ./roswell/ports-checker.ros --ssh-user deploy --ssh-port 2222 \
  --allow 2222,443 server.example.com
```

Set the external TCP probe timeout with `--timeout` and the SSH connection
timeout with `--ssh-timeout`. Both values are specified in seconds.
""")

(defsection @exit-codes (:title "Exit Codes")
  """
- `0` — no unapproved ports are reachable;
- `1` — at least one unapproved port is reachable;
- `2` — invalid arguments, an SSH error, or another runtime error.
""")

(defsection @development (:title "Development")
  """
Project dependencies are pinned with Qlot. Tests use Rove:

```console
qlot install
qlot exec ros -Q -e '(asdf:load-asd (truename "ports-checker.asd"))' \
  -e '(asdf:test-system "ports-checker")' -q
```

The network-logic tests do not require a real SSH server and do not open actual
network connections.

Install the project-local documentation builder once, then regenerate
`README.md`, `ChangeLog.md`, and the HTML site after changing documentation or
public API docstrings:

```console
qlot exec ros install 40ants/docs-builder
CL_SOURCE_REGISTRY=$(pwd)/ .qlot/bin/build-docs ports-checker-docs
```
""")

(defsection @limitations (:title "Initial Release Limitations")
  """
- Only listening TCP ports are checked.
- The remote server must run Linux and provide the `ss` command.
- UDP is not checked yet.
- Reachability is tested from the machine running `ports-checker`; a firewall
  may behave differently for clients on another network.
""")

(defautodoc @api (:system "ports-checker"))
