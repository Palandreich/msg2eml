"""
Smoke tests — run against real .msg fixtures placed in tests/fixtures/.
"""
import email
from pathlib import Path

import pytest

FIXTURES = Path(__file__).parent / "fixtures"


def msg_fixtures():
    if not FIXTURES.exists():
        return []
    return list(FIXTURES.glob("*.msg"))


@pytest.mark.skipif(not msg_fixtures(), reason="No .msg fixtures found in tests/fixtures/")
@pytest.mark.parametrize("msg_path", msg_fixtures())
def test_converts_without_error(msg_path):
    from converter import convert
    result = convert(msg_path)
    assert result is not None


@pytest.mark.skipif(not msg_fixtures(), reason="No .msg fixtures found in tests/fixtures/")
@pytest.mark.parametrize("msg_path", msg_fixtures())
def test_output_is_valid_mime(msg_path, tmp_path):
    from email.generator import BytesGenerator
    from converter import convert

    eml_path = tmp_path / msg_path.with_suffix(".eml").name
    message = convert(msg_path)
    with eml_path.open("wb") as f:
        BytesGenerator(f).flatten(message)

    raw = eml_path.read_bytes()
    parsed = email.message_from_bytes(raw)
    assert parsed["Subject"] is not None or parsed["From"] is not None
