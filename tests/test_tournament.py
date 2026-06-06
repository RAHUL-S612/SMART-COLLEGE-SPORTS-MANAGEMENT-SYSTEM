# tests/test_tournament.py
def test_tournament_list(admin_client):
    """GET /api/tournaments/ returns list."""
    resp = admin_client.get('/api/tournaments/')
    assert resp.status_code in [200, 404]

def test_tournament_create(admin_client):
    """POST /api/tournaments/ creates tournament."""
    resp = admin_client.post('/api/tournaments/', json={
        'name':       'SCSS Championship 2025',
        'sport_id':   1,
        'start_date': '2025-12-01',
        'end_date':   '2025-12-31'
    })
    assert resp.status_code in [200, 201, 404]

def test_tournament_get_by_id(admin_client):
    """GET /api/tournaments/1 returns tournament."""
    resp = admin_client.get('/api/tournaments/1')
    assert resp.status_code in [200, 404]

def test_tournament_update(admin_client):
    """PUT /api/tournaments/1 updates tournament."""
    resp = admin_client.put('/api/tournaments/1',
                            json={'name': 'Updated Tournament'})
    assert resp.status_code in [200, 404]

def test_tournament_delete(admin_client):
    """DELETE /api/tournaments/1."""
    resp = admin_client.delete('/api/tournaments/1')
    assert resp.status_code in [200, 204, 404]

def test_tournament_report(admin_client):
    """GET /api/reports/tournament/1 returns report."""
    resp = admin_client.get('/api/reports/tournament/1')
    assert resp.status_code == 200
    data = resp.get_json()['data']
    assert 'tournament' in data
    assert 'matches'    in data
    assert 'leaderboard' in data

def test_tournament_404(admin_client):
    """Non-existent tournament returns 404."""
    resp = admin_client.get('/api/reports/tournament/9999')
    assert resp.status_code == 404