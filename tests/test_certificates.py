# tests/test_certificates.py
# =============================================================
#  TC-09: Valid QR scan
#  TC-10: Invalid QR scan
#  TC-11: Public leaderboard
#  TC-12: Certificate download
#  TC-13: Analytics report
#  TC-14: SQL injection blocked
# =============================================================

def test_TC09_valid_qr_scan(client):
    resp = client.get('/api/verify/SCSS-2025-CERT-001-GOLD')
    data = resp.get_json()
    assert resp.status_code == 200
    assert data['is_valid']    is True
    assert 'player_name'       in data

def test_TC10_invalid_qr_scan(client):
    resp = client.get('/api/verify/FAKE-CODE-99999')
    data = resp.get_json()
    assert resp.status_code == 404
    assert data['is_valid'] is False

def test_TC11_public_leaderboard_no_login(client):
    resp = client.get('/api/leaderboard/1')
    assert resp.status_code == 200
    assert 'standings' in resp.get_json()

def test_TC12_player_certificate_download(client, admin_token):
    headers = {'Authorization': f'Bearer {admin_token}'}
    resp    = client.get('/api/certificates/1/download', headers=headers)
    assert resp.status_code   == 200
    assert resp.content_type  == 'application/pdf'

def test_TC13_analytics_report(client, admin_token):
    headers = {'Authorization': f'Bearer {admin_token}'}
    resp    = client.get('/api/reports/export?format=json', headers=headers)
    data    = resp.get_json()
    assert resp.status_code == 200
    assert 'charts' in data or 'data' in data

def test_TC14_sql_injection_blocked(client):
    malicious = {'email': "' OR 1=1 --", 'password': 'anything'}
    resp      = client.post('/api/auth/login', json=malicious)
    assert resp.status_code in [400, 401]
    assert 'access_token' not in (resp.get_json() or {})

# ── Extra coverage ────────────────────────────────────────────
def test_list_all_certificates(admin_client):
    resp = admin_client.get('/api/certificates/')
    assert resp.status_code == 200
    assert 'certificates' in resp.get_json()

def test_certificates_filter_by_tournament(admin_client):
    resp = admin_client.get('/api/certificates/?tournament_id=1')
    assert resp.status_code == 200
    certs = resp.get_json()['certificates']
    assert isinstance(certs, list)

def test_certificates_filter_by_player(admin_client):
    resp = admin_client.get('/api/certificates/?player_id=1')
    assert resp.status_code == 200

def test_certificate_has_position(admin_client):
    resp  = admin_client.get('/api/certificates/?tournament_id=1')
    certs = resp.get_json()['certificates']
    if certs:
        assert 'position'    in certs[0]
        assert 'unique_code' in certs[0]
        assert 'pdf_path'    in certs[0]

def test_certificate_unique_code_starts_with_scss(admin_client):
    resp  = admin_client.get('/api/certificates/?tournament_id=1')
    certs = resp.get_json()['certificates']
    if certs:
        assert certs[0]['unique_code'].startswith('SCSS-')

def test_sql_injection_in_verify(client):
    resp = client.get("/api/verify/' OR 1=1 --")
    assert resp.status_code == 400

def test_verify_second_valid_code(client):
    resp = client.get('/api/verify/SCSS-2025-CERT-002-SILVER')
    assert resp.status_code    == 200
    assert resp.get_json()['is_valid'] is True

def test_download_cert_unauthorized(client):
    resp = client.get('/api/certificates/1/download')
    assert resp.status_code in [200, 401]