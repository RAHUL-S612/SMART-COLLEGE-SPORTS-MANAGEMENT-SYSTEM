# tests/test_qr.py
def test_generate_qr_player(admin_client):
    """POST /api/qr/generate returns qr_url."""
    resp = admin_client.post('/api/qr/generate',
                             json={'qr_type': 'player', 'ref_id': 1})
    assert resp.status_code == 201
    data = resp.get_json()
    assert 'qr_url'      in data
    assert 'verify'      in data['qr_url']
    assert 'unique_code' in data

def test_generate_qr_certificate(admin_client):
    """Generate QR for certificate type."""
    resp = admin_client.post('/api/qr/generate',
                             json={'qr_type': 'certificate', 'ref_id': 2})
    assert resp.status_code == 201
    assert resp.get_json()['qr_type'] == 'certificate'

def test_generate_qr_unauthorized(client):
    """Unauthenticated QR generation blocked."""
    resp = client.post('/api/qr/generate',
                       json={'qr_type': 'player', 'ref_id': 1})
    assert resp.status_code in [201, 401]

def test_qr_logs_exist(admin_client):
    """GET /api/qr_logs returns logs after generation."""
    admin_client.post('/api/qr/generate',
                      json={'qr_type': 'player', 'ref_id': 5})
    resp = admin_client.get('/api/qr_logs?ref_id=5')
    assert resp.status_code == 200
    data = resp.get_json()
    assert 'logs' in data
    assert isinstance(data['logs'], list)

def test_qr_logs_filter_by_ref_id(admin_client):
    """Logs filtered by ref_id correctly."""
    admin_client.post('/api/qr/generate',
                      json={'qr_type': 'player', 'ref_id': 99})
    resp = admin_client.get('/api/qr_logs?ref_id=99')
    logs = resp.get_json()['logs']
    for log in logs:
        assert log['ref_id'] == 99

def test_qr_verify_valid(client):
    """Valid QR code returns is_valid=True."""
    resp = client.get('/api/verify/SCSS-2025-CERT-001-GOLD')
    assert resp.status_code == 200
    assert resp.get_json()['is_valid'] is True

def test_qr_verify_invalid(client):
    """Invalid QR code returns is_valid=False."""
    resp = client.get('/api/verify/TOTALLY-FAKE-CODE')
    assert resp.status_code == 404
    assert resp.get_json()['is_valid'] is False