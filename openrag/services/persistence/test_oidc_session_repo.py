"""Tests for the upcoming Postgres OIDCSessionRepository.

Reserved placeholder — real tests land once Person A's 7A.2
``oidc_session_repo.py`` implementation merges. Colocated with the
implementation (project convention) and will exercise the
``OIDCSessionRepository`` ABC (see
``openrag/core/ports/oidc_session_repo.py``). Note: this repo handles
Fernet-encrypted ID/access/refresh tokens — tests must cover round-trip
decryption and expiry handling.
"""

import pytest

pytestmark = pytest.mark.skip(reason="awaiting 7A.2 oidc_session_repo from Person A")


def test_placeholder() -> None:
    pass
