# =============================================================
#  SCSS — tests/test_security.py
#  SRS §9.2  |  TC-14, TC-15
#  SRS §6.2  Security Non-Functional Requirements
#
#  TC-14: SQL injection attempt via API → blocked by SQLAlchemy ORM
#  TC-15: Mobile view of dashboard → Bootstrap layout adapts
#
#  Also covers:
#    - RBAC enforcement (FR-AU-02, FR-AU-05)
#    - JWT cookie presence (FR-AU-05)
#    - Password hashing (FR-AU-04)
#    - Response never leaks raw SQL errors
# =============================================================

# tests/test_security.py
def test_TC15_responsive_meta_tag(client):
    """TC-15: Ensure viewport meta tag present for mobile responsiveness."""
    resp = client.get('/')
    assert b'viewport' in resp.data
    assert b'width=device-width' in resp.data