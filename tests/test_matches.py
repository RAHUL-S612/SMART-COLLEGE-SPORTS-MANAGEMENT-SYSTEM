# tests/test_matches.py
# =============================================================
#  TC-05: Schedule match
#  TC-06: Conflict detection
#  TC-07: Score entry updates leaderboard
#  TC-08: Certificate auto-generated
# =============================================================

def test_TC05_schedule_match(client, admin_token):
    headers  = {'Authorization': f'Bearer {admin_token}'}
    resp     = client.post('/api/matches/', headers=headers, json={
        'tournament_id': 1, 'team1_id': 1, 'team2_id': 2,
        'venue': 'Ground A', 'scheduled_at': '2025-12-10T10:00:00'
    })
    assert resp.status_code == 201
    fixtures = client.get('/api/matches/?tournament_id=1',
                          headers=headers).get_json()
    assert any(m['match_id'] == resp.get_json()['match_id']
               for m in fixtures['matches'])

def test_TC06_conflict_detection(client, admin_token):
    headers = {'Authorization': f'Bearer {admin_token}'}
    payload = {
        'tournament_id': 1, 'team1_id': 3, 'team2_id': 4,
        'venue': 'Ground A', 'scheduled_at': '2025-12-10T10:00:00'
    }
    resp = client.post('/api/matches/', headers=headers, json=payload)
    assert resp.status_code == 409
    assert 'conflict' in resp.get_json()['error'].lower()

def test_TC07_score_entry_updates_leaderboard(client, coach_token):
    headers = {'Authorization': f'Bearer {coach_token}'}
    resp    = client.post('/api/scores/', headers=headers,
                          json={'match_id': 1, 'team1_score': 3,
                                'team2_score': 1, 'winner_team_id': 1})
    assert resp.status_code == 201
    lb     = client.get('/api/leaderboard/1').get_json()
    team1  = next(t for t in lb['standings'] if t['team_id'] == 1)
    assert team1['wins'] >= 1

def test_TC08_certificate_auto_generated(client, coach_token):
    headers = {'Authorization': f'Bearer {coach_token}'}
    client.post('/api/scores/', headers=headers,
                json={'match_id': 2, 'team1_score': 5,
                      'team2_score': 2, 'winner_team_id': 1})
    certs = client.get('/api/certificates/?tournament_id=1',
                       headers=headers).get_json()
    assert len(certs['certificates']) > 0
    assert certs['certificates'][0]['pdf_path'] is not None

# ── Extra coverage ────────────────────────────────────────────
def test_get_matches_no_filter(client, admin_token):
    headers = {'Authorization': f'Bearer {admin_token}'}
    resp    = client.get('/api/matches/', headers=headers)
    assert resp.status_code == 200
    assert 'matches' in resp.get_json()

def test_create_match_unauthorized(client):
    resp = client.post('/api/matches/', json={
        'tournament_id': 1, 'team1_id': 1, 'team2_id': 2,
        'venue': 'Ground Z', 'scheduled_at': '2025-12-30T10:00:00'
    })
    assert resp.status_code == 401

def test_schedule_match_returns_match_id(client, admin_token):
    headers = {'Authorization': f'Bearer {admin_token}'}
    resp    = client.post('/api/matches/', headers=headers, json={
        'tournament_id': 1, 'team1_id': 5, 'team2_id': 6,
        'venue': 'Ground D', 'scheduled_at': '2025-12-15T14:00:00'
    })
    assert resp.status_code == 201
    assert 'match_id' in resp.get_json()

def test_conflict_error_message(client, admin_token):
    headers = {'Authorization': f'Bearer {admin_token}'}
    payload = {
        'tournament_id': 1, 'team1_id': 7, 'team2_id': 8,
        'venue': 'Ground A', 'scheduled_at': '2025-12-10T10:00:00'
    }
    resp = client.post('/api/matches/', headers=headers, json=payload)
    assert resp.status_code == 409
    data = resp.get_json()
    assert 'error' in data

def test_match_list_returns_list(client, admin_token):
    headers  = {'Authorization': f'Bearer {admin_token}'}
    resp     = client.get('/api/matches/', headers=headers)
    matches  = resp.get_json()['matches']
    assert isinstance(matches, list)

def test_score_entry_has_score_id(client, coach_token):
    headers = {'Authorization': f'Bearer {coach_token}'}
    resp    = client.post('/api/scores/', headers=headers,
                          json={'match_id': 3, 'team1_score': 2,
                                'team2_score': 2, 'winner_team_id': 1})
    assert resp.status_code == 201
    assert 'score_id' in resp.get_json()