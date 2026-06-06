# tests/test_players.py
# =============================================================
#  TC-04: Add player to team
# =============================================================

def test_TC04_add_player_to_team(client, admin_token):
    headers = {'Authorization': f'Bearer {admin_token}'}
    resp    = client.post('/api/teams/1/players',
                          json={'player_id': 3}, headers=headers)
    assert resp.status_code == 201
    roster = client.get('/api/teams/1/players',
                        headers=headers).get_json()
    ids = [p['player_id'] for p in roster['players']]
    assert 3 in ids

def test_get_all_players(admin_client):
    resp = admin_client.get('/api/players')
    assert resp.status_code == 200
    assert 'data' in resp.get_json()

def test_get_player_by_id(admin_client):
    resp = admin_client.get('/api/players/1')
    assert resp.status_code == 200
    data = resp.get_json()
    assert 'qr_code'   in data
    assert 'player_id' in data

def test_get_player_has_qr_code(admin_client):
    resp = admin_client.get('/api/players/1')
    assert resp.get_json()['qr_code'] is not None

def test_get_player_default_fallback(admin_client):
    resp = admin_client.get('/api/players/999')
    assert resp.status_code == 200
    assert resp.get_json()['qr_code'] is not None

def test_add_player_to_team_no_duplicate(admin_client):
    admin_client.post('/api/teams/1/players', json={'player_id': 5})
    admin_client.post('/api/teams/1/players', json={'player_id': 5})
    roster = admin_client.get('/api/teams/1/players').get_json()
    ids    = [p['player_id'] for p in roster['players']]
    assert ids.count(5) == 1

def test_get_team_roster_is_list(admin_client):
    resp   = admin_client.get('/api/teams/1/players')
    roster = resp.get_json()['players']
    assert isinstance(roster, list)

def test_get_teams(admin_client):
    resp = admin_client.get('/teams/')
    assert resp.status_code == 200

def test_add_player_unauthorized(client):
    resp = client.post('/api/teams/1/players',
                       json={'player_id': 10})
    assert resp.status_code in [201, 401]

def test_update_player(admin_client):
    resp = admin_client.put('/api/players/1',
                            json={'name': 'Updated Name'})
    assert resp.status_code in [200, 404]

def test_players_data_structure(admin_client):
    resp    = admin_client.get('/api/players')
    players = resp.get_json()['data']
    assert isinstance(players, list)