#!/usr/bin/env python3
import argparse
import sys
from email.generator import BytesGenerator
from pathlib import Path

from converter import convert


def save(msg_path: Path, eml_path: Path) -> None:
    message = convert(msg_path)
    eml_path.parent.mkdir(parents=True, exist_ok=True)
    with eml_path.open("wb") as f:
        BytesGenerator(f).flatten(message)


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert .msg files to .eml format")
    parser.add_argument("input", help=".msg file or directory of .msg files")
    parser.add_argument("output", nargs="?", help=".eml output file (single-file mode only)")
    parser.add_argument("--output-dir", "-o", help="output directory (batch mode)")
    args = parser.parse_args()

    input_path = Path(args.input)

    if input_path.is_dir():
        out_dir = Path(args.output_dir) if args.output_dir else input_path
        msg_files = list(input_path.rglob("*.msg"))
        if not msg_files:
            print(f"No .msg files found in {input_path}", file=sys.stderr)
            sys.exit(1)
        for msg_file in msg_files:
            relative = msg_file.relative_to(input_path)
            eml_file = out_dir / relative.with_suffix(".eml")
            try:
                save(msg_file, eml_file)
                print(f"  {msg_file} -> {eml_file}")
            except Exception as exc:
                print(f"  ERROR {msg_file}: {exc}", file=sys.stderr)
    else:
        if args.output:
            eml_path = Path(args.output)
        else:
            eml_path = input_path.with_suffix(".eml")
        save(input_path, eml_path)
        print(f"{input_path} -> {eml_path}")


if __name__ == "__main__":
    main()
