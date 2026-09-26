<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-40README-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

# ports-checker — Detect unexpected externally reachable TCP ports

<a id="ports-checker-asdf-system-details"></a>

## PORTS-CHECKER ASDF System Details

* Version: 0.1.0
* Description: A targeted port checker that finds what’s listening on your servers—and flags what shouldn’t be.
* Author: Alexander Artemenko
* Depends on: [defmain][3266], [usocket][636b]

`ports-checker` verifies that no unexpected `TCP` ports have become reachable
after a server configuration change or software installation. It does not scan
a range of ports. Instead, it:

1. connects to the specified server over `SSH`;
2. runs `ss -H -lnt` to obtain the `TCP` sockets listening on wildcard and
   non-loopback interfaces;
3. closes the `SSH` connection;
4. attempts to connect from the local machine only to the discovered ports;
5. exits with code `1` if a reachable port is not on the allowlist.

A service blocked by an external firewall is therefore not considered
reachable, even if its process listens on a non-loopback interface. Startup and
`SSH` errors cause the command to exit with code `2`.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40RATIONALE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Why Not Nmap?

`ports-checker` complements general-purpose port scanners such as `nmap` with
a narrower, policy-oriented check:

1. **It probes only ports that can actually be open.** Instead of scanning a
   range, it first obtains the listening `TCP` ports from the server over `SSH` and
   then tests only those ports from the outside.
2. **It avoids broad scan-like network activity.** In some environments,
   endpoint protection or network security tooling may classify an `nmap` run
   as a port-scanning or attack attempt. `ports-checker` performs ordinary `SSH`
   access followed by targeted connection attempts, which is less likely to
   trigger rules intended specifically for broad port scans. These checks are
   still normal network activity and may remain visible in security logs.
3. **It checks policy, not just reachability.** `nmap` reports scan results;
   `ports-checker` compares reachable ports with an explicit allowlist and
   returns a non-zero exit code when it finds an unauthorized port. This makes
   it straightforward to use in automated checks, deployment verification, and
   `CI` jobs.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40REQUIREMENTS-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Requirements

* Common Lisp (the project is tested with `SBCL`);
* [Roswell][2a9a];
* [Qlot][e3ea];
* a local `ssh` command;
* the `ss` command from `iproute2` on the Linux server being checked;
* configured non-interactive `SSH` authentication.

The `SSH` host key must already be present in `known_hosts`. The command
intentionally does not accept unknown host keys automatically.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40INSTALLATION-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Installation

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
<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40USAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Usage

The `--allow` (`-a`) option accepts a comma-separated list of ports. The `SSH`
user and `SSH` port can be specified separately:

```console
qlot exec ./roswell/ports-checker.ros --ssh-user deploy --ssh-port 2222 \
  --allow 2222,443 server.example.com
```
Set the external `TCP` probe timeout with `--timeout` and the `SSH` connection
timeout with `--ssh-timeout`. Both values are specified in seconds.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40EXIT-CODES-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Exit Codes

* `0` — no unapproved ports are reachable;
* `1` — at least one unapproved port is reachable;
* `2` — invalid arguments, an `SSH` error, or another runtime error.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40DEVELOPMENT-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Development

Project dependencies are pinned with Qlot. Tests use Rove:

```console
qlot install
qlot exec ros -Q -e '(asdf:load-asd (truename "ports-checker.asd"))' \
  -e '(asdf:test-system "ports-checker")' -q
```
The network-logic tests do not require a real `SSH` server and do not open actual
network connections.

Install the project-local documentation builder once, then regenerate
`README.md`, `ChangeLog.md`, and the `HTML` site after changing documentation or
public `API` docstrings:

```console
qlot exec ros install 40ants/docs-builder
CL_SOURCE_REGISTRY=$(pwd)/ .qlot/bin/build-docs ports-checker-docs
```
<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40LIMITATIONS-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Initial Release Limitations

* Only listening `TCP` ports are checked.
* The remote server must run Linux and provide the `ss` command.
* `UDP` is not checked yet.
* Reachability is tested from the machine running `ports-checker`; a firewall
  may behave differently for clients on another network.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40API-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## API

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40PORTS-CHECKER-2FCHECKER-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### PORTS-CHECKER/CHECKER

<a id="x-28-23A-28-2821-29-20BASE-CHAR-20-2E-20-22PORTS-CHECKER-2FCHECKER-22-29-20PACKAGE-29"></a>

#### [package](bce0) `ports-checker/checker`

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-7C-40PORTS-CHECKER-2FCHECKER-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-28PORTS-CHECKER-2FCHECKER-3ACHECK-PORTS-20FUNCTION-29"></a>

##### [function](4e69) `ports-checker/checker:check-ports` host discovered-ports allowed-ports &key (timeout 3) (probe-function #'probe-port)

Return unexpected reachable ports among `DISCOVERED-PORTS` on `HOST`.

`ALLOWED-PORTS` are never probed.  `PROBE-FUNCTION` accepts `HOST` and `PORT` plus a
`TIMEOUT` keyword, which makes the network boundary replaceable in tests.

<a id="x-28PORTS-CHECKER-2FCHECKER-3APROBE-PORT-20FUNCTION-29"></a>

##### [function](40e7) `ports-checker/checker:probe-port` host port &key (timeout 3)

Return true when a `TCP` connection to `HOST` and `PORT` succeeds within `TIMEOUT`.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40PORTS-CHECKER-2FMAIN-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### PORTS-CHECKER/MAIN

<a id="x-28-23A-28-2818-29-20BASE-CHAR-20-2E-20-22PORTS-CHECKER-2FMAIN-22-29-20PACKAGE-29"></a>

#### [package](0c40) `ports-checker/main`

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-7C-40PORTS-CHECKER-2FMAIN-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-28PORTS-CHECKER-2FMAIN-3AMAIN-20FUNCTION-29"></a>

##### [function](bfe5) `ports-checker/main:main` &optional (arguments (uiop/image:command-line-arguments))

Run ports-checker with `ARGUMENTS` and return a process exit code.

<a id="x-28PORTS-CHECKER-2FMAIN-3APARSE-ALLOWED-PORTS-20FUNCTION-29"></a>

##### [function](150b) `ports-checker/main:parse-allowed-ports` value

Parse comma-separated allowed ports from `VALUE` and return unique integers.

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40PORTS-CHECKER-2FREMOTE-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### PORTS-CHECKER/REMOTE

<a id="x-28-23A-28-2820-29-20BASE-CHAR-20-2E-20-22PORTS-CHECKER-2FREMOTE-22-29-20PACKAGE-29"></a>

#### [package](ee84) `ports-checker/remote`

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-7C-40PORTS-CHECKER-2FREMOTE-3FClasses-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Classes

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-40PORTS-CHECKER-2FREMOTE-24REMOTE-COMMAND-ERROR-3FCLASS-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

##### REMOTE-COMMAND-ERROR

<a id="x-28PORTS-CHECKER-2FREMOTE-3AREMOTE-COMMAND-ERROR-20CONDITION-29"></a>

###### [condition](fa94) `ports-checker/remote:remote-command-error` (error)

An error reported when remote listener discovery over `SSH` fails.

**Readers**

<a id="x-28PORTS-CHECKER-2FREMOTE-3AREMOTE-COMMAND-ERROR-DESTINATION-20-2840ANTS-DOC-2FLOCATIVES-3AREADER-20PORTS-CHECKER-2FREMOTE-3AREMOTE-COMMAND-ERROR-29-29"></a>

###### [reader](fa94) `ports-checker/remote:remote-command-error-destination` (remote-command-error) (:destination)

<a id="x-28PORTS-CHECKER-2FREMOTE-3AREMOTE-COMMAND-ERROR-STATUS-20-2840ANTS-DOC-2FLOCATIVES-3AREADER-20PORTS-CHECKER-2FREMOTE-3AREMOTE-COMMAND-ERROR-29-29"></a>

###### [reader](fa94) `ports-checker/remote:remote-command-error-status` (remote-command-error) (:status)

<a id="x-28PORTS-CHECKER-2FREMOTE-3AREMOTE-COMMAND-ERROR-STDERR-20-2840ANTS-DOC-2FLOCATIVES-3AREADER-20PORTS-CHECKER-2FREMOTE-3AREMOTE-COMMAND-ERROR-29-29"></a>

###### [reader](fa94) `ports-checker/remote:remote-command-error-stderr` (remote-command-error) (:stderr)

<a id="x-28PORTS-CHECKER-DOCS-2FINDEX-3A-3A-7C-40PORTS-CHECKER-2FREMOTE-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-28PORTS-CHECKER-2FREMOTE-3ADISCOVER-PORTS-20FUNCTION-29"></a>

##### [function](783a) `ports-checker/remote:discover-ports` destination &key ssh-user ssh-port (connect-timeout 10)

Return externally bound `TCP` ports reported by `DESTINATION` over `SSH`.

`SSH-USER` and `SSH-PORT` select the `SSH` account and port.  `CONNECT-TIMEOUT` is
passed to Open`SSH`.  Authentication is deliberately non-interactive.

<a id="x-28PORTS-CHECKER-2FREMOTE-3APARSE-SS-OUTPUT-20FUNCTION-29"></a>

##### [function](e780) `ports-checker/remote:parse-ss-output` output

Return sorted unique `TCP` ports bound to wildcard or non-loopback addresses.

`OUTPUT` must be produced by `ss -H -lnt`.  Loopback-only listeners are omitted.


[40e7]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/checker.lisp#L12
[4e69]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/checker.lisp#L24
[bce0]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/checker.lisp#L3
[0c40]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/main.lisp#L3
[150b]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/main.lisp#L44
[bfe5]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/main.lisp#L99
[fa94]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/remote.lisp#L13
[ee84]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/remote.lisp#L3
[e780]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/remote.lisp#L62
[783a]: https://github.com/40ants/ports-checker/blob/2981dfee7027a2d400f1e04ffeef105e180f7c0f/src/remote.lisp#L78
[e3ea]: https://github.com/fukamachi/qlot
[3266]: https://quickdocs.org/defmain
[636b]: https://quickdocs.org/usocket
[2a9a]: https://roswell.github.io/

* * *
###### [generated by [40ANTS-DOC](https://40ants.com/doc/)]
