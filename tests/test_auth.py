# tests/test_auth.py
# =============================================================
#  TC-01: Admin login valid
#  TC-02: Invalid credentials
#  TC-03: Logout
# =============================================================

def test_TC01_admin_login_valid(client):
    resp = client.post('/api/auth/login', json={
        'username': 'admin', 'password': 'admin123'
    })
    assert resp.status_code == 200
    data = resp.get_json()
    assert data['status'] == 'success'
    assert data['role']   == 'admin'

def test_TC01_player_login_valid(client):
    resp = client.post('/api/auth/login', json={
        'username': 'player1', 'password': 'player123'
    })
    assert resp.status_code == 200
    assert resp.get_json()['role'] == 'player'

def test_TC01_coach_login_valid(client):
    resp = client.post('/api/auth/login', json={
        'username': 'coach1', 'password': 'coach123'
    })
    assert resp.status_code == 200
    assert resp.get_json()['role'] == 'coach'

def test_TC02_wrong_password(client):
    resp = client.post('/api/auth/login', json={
        'username': 'admin', 'password': 'wrongpassword'
    })
    assert resp.status_code == 401
    assert resp.get_json()['status'] == 'error'

def test_TC02_wrong_username(client):
    resp = client.post('/api/auth/login', json={
        'username': 'nobody', 'password': 'anything'
    })
    assert resp.status_code == 401

def test_TC02_empty_credentials(client):
    resp = client.post('/api/auth/login', json={
        'username': '', 'password': ''
    })
    assert resp.status_code == 401

def test_TC02_missing_password(client):
    resp = client.post('/api/auth/login', json={'username': 'admin'})
    assert resp.status_code == 401

def test_TC02_no_access_token_on_failure(client):
    resp = client.post('/api/auth/login', json={
        'username': 'admin', 'password': 'badpass'
    })
    data = resp.get_json() or {}
    assert 'access_token' not in data
    assert 'token'         not in data

def test_TC03_logout_after_login(client):
    client.post('/api/auth/login', json={
        'username': 'admin', 'password': 'admin123'
    })
    resp = client.post('/api/auth/logout')
    assert resp.status_code == 200
    assert resp.get_json()['status'] == 'success'

def test_TC03_protected_route_after_logout(client):
    client.post('/api/auth/login', json={
        'username': 'admin', 'password': 'admin123'
    })
    client.post('/api/auth/logout')
    resp = client.get('/api/analytics/overview')
    assert resp.status_code == 403

def test_TC03_logout_without_login(client):
    resp = client.post('/api/auth/logout')
    assert resp.status_code == 200

# ── Register ──────────────────────────────────────────────────
def test_register_new_player(client):
    resp = client.post('/api/auth/register', json={
        'name':       'New Player',
        'email':      'newplayer@college.edu',
        'password':   'Player@123',
        'role':       'player',
        'reg_number': 'CSE2025010',
        'department': 'CSE',
        'year':       2,
        'sport_id':   1
    })
    assert resp.status_code == 201
    assert 'player_id' in resp.get_json()

def test_register_duplicate_email(client):
    client.post('/api/auth/register', json={
        'name': 'First', 'email': 'dup@test.com', 'password': 'Pass@123'
    })
    resp = client.post('/api/auth/register', json={
        'name': 'Second', 'email': 'dup@test.com', 'password': 'Pass@123'
    })
    assert resp.status_code == 409

def test_register_missing_name(client):
    resp = client.post('/api/auth/register', json={
        'email': 'noname@test.com', 'password': 'Pass@123'
    })
    assert resp.status_code == 400

def test_register_missing_email(client):
    resp = client.post('/api/auth/register', json={
        'name': 'No Email', 'password': 'Pass@123'
    })
    assert resp.status_code == 400

def test_register_returns_player_id(client):
    resp = client.post('/api/auth/register', json={
        'name': 'ID Test', 'email': 'idtest@test.com', 'password': 'Pass@123'
    })
    assert resp.status_code == 201
    data = resp.get_json()
    assert isinstance(data['player_id'], int)

# ── Me endpoint ───────────────────────────────────────────────
def test_get_me_when_logged_in(client):
    client.post('/api/auth/login', json={
        'username': 'admin', 'password': 'admin123'
    })
    resp = client.get('/api/auth/me')
    assert resp.status_code == 200
    data = resp.get_json()
    assert data['username'] == 'admin'
    assert data['role']     == 'admin'

def test_get_me_when_not_logged_in(client):
    resp = client.get('/api/auth/me')
    assert resp.status_code == 401

def test_login_sets_role_in_response(client):
    resp = client.post('/api/auth/login', json={
        'username': 'coach1', 'password': 'coach123'
    })
    assert resp.get_json()['role'] == 'coach'

def test_login_returns_user_id(client):
    resp = client.post('/api/auth/login', json={
        'username': 'admin', 'password': 'admin123'
    })
    assert 'user_id' in resp.get_json()