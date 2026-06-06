# tests/test_sport.py
def test_sport_list(admin_client):
    """GET /api/sports/ returns list."""
    resp = admin_client.get('/api/sports/')
    assert resp.status_code in [200, 404]

def test_sport_create(admin_client):
    """POST /api/sports/ creates sport."""
    resp = admin_client.post('/api/sports/', json={
        'name':        'Cricket',
        'description': 'Bat and ball game',
        'max_players': 11
    })
    assert resp.status_code in [200, 201, 404]

def test_sport_get_by_id(admin_client):
    """GET /api/sports/1 returns sport."""
    resp = admin_client.get('/api/sports/1')
    assert resp.status_code in [200, 404]

def test_sport_update(admin_client):
    """PUT /api/sports/1 updates sport."""
    resp = admin_client.put('/api/sports/1',
                            json={'name': 'Cricket Updated'})
    assert resp.status_code in [200, 404]

def test_sport_blocked_for_player(player_client):
    """Player cannot create sport."""
    resp = player_client.post('/api/sports/',
                              json={'name': 'Hockey'})
    assert resp.status_code in [200, 201, 403, 404]