# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

Convert Microsoft Outlook `.msg` files to RFC-compliant `.eml` files (MIME format). Supports batch conversion of entire directories.

## Commands

```bash
# Create virtual environment and install dependencies
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# Convert a single file
.venv/bin/python msg2eml.py input.msg

# Convert with explicit output path
.venv/bin/python msg2eml.py input.msg output.eml

# Batch convert a directory
.venv/bin/python msg2eml.py /path/to/msgs/ --output-dir /path/to/emls/

# Run tests
.venv/bin/pytest

# Run a single test
.venv/bin/pytest tests/test_converter.py::test_name -v
```

## Finder integration

Finder Quick Actions run in a sandboxed shell that blocks `source` — activating venv via `activate` script fails with "operation not permitted". Always call the venv Python binary directly by absolute path.

`install_cmd.sh` installs `/usr/local/bin/msg2eml` — a two-line wrapper that calls `.venv/bin/python` directly. Run once after cloning or moving the project:

```bash
./install_cmd.sh    # install
./uninstall_cmd.sh  # remove
```

In the Quick Action, point to `/usr/local/bin/msg2eml "$@"`.

`register_uti.sh` optionally restricts the Quick Action to `.msg` files only. It creates a minimal app bundle at `~/.msg2eml-helper/` and registers a custom UTI (`com.local.msg-file`) with Launch Services, then patches the Quick Action's `Info.plist`. `unregister_uti.sh` reverses all of this.

```bash
./register_uti.sh "Convert to EML"    # restrict to .msg files
./unregister_uti.sh "Convert to EML"  # revert to all files
```

`convert.sh` is a terminal-only convenience wrapper (uses `source activate`, won't work in Finder).

## Key dependencies

- `extract-msg` — parses `.msg` (Compound File Binary / OLE2 format) files
- `email` (stdlib) — constructs MIME messages for `.eml` output

## Architecture

The converter pipeline has two stages:

1. **Parse** (`extract-msg`): opens the `.msg` file and exposes headers (sender, recipients, subject, date), body (plain text and/or HTML), and attachments as Python objects.
2. **Build** (stdlib `email`): constructs a `MIMEMultipart` message, sets headers, encodes attachments as `MIMEBase` with base64, then serializes to `.eml` with `email.generator`.

Entry point is `msg2eml.py`. Core conversion logic lives in `converter.py` (the `convert` function takes a path and returns an `email.message.Message`). CLI argument parsing is handled in `msg2eml.py` via `argparse`.
