# tests/test_integration.py

# ─────────────────────────────────────────────────────────────
# Integration Test 1: Score → Leaderboard → Certificate → Notification
# ─────────────────────────────────────────────────────────────
def test_full_score_to_certificate_flow(client, coach_token, admin_token):
    """
    Integration: Score entry → Leaderboard update →
    Certificate generation → Email notification
    """
    coach_h = {'Authorization': f'Bearer {coach_token}'}
    admin_h = {'Authorization': f'Bearer {admin_token}'}

    # Step 1: Coach enters final match score
    score_resp = client.post('/api/scores/', headers=coach_h, json={
        'match_id': 5, 'team1_score': 7, 'team2_score': 4,
        'winner_team_id': 1, 'notes': 'Final — Cricket Championship'
    })
    assert score_resp.status_code == 201
    score_id = score_resp.get_json()['score_id']

    # Step 2: Leaderboard auto-updated
    lb_resp   = client.get('/api/leaderboard/1')
    standings = lb_resp.get_json()['standings']
    winner    = next((t for t in standings if t['team_id'] == 1), None)
    assert winner is not None
    assert winner['wins']   > 0
    assert winner['points'] > 0

    # Step 3: Certificate auto-generated
    cert_resp = client.get('/api/certificates/?tournament_id=1&player_id=1',
                           headers=admin_h)
    certs = cert_resp.get_json()['certificates']
    assert len(certs) > 0
    cert = certs[0]
    assert cert['position'] == 1
    assert cert['unique_code'].startswith('SCSS-')
    assert cert['pdf_path'] is not None

    # Step 4: Notification dispatched to player
    notif_resp = client.get('/api/notifications/?user_id=3', headers=admin_h)
    notifs     = notif_resp.get_json()['notifications']
    cert_notif = next(
        (n for n in notifs if n['type'] == 'certificate_ready'), None)
    assert cert_notif is not None


# ─────────────────────────────────────────────────────────────
# Integration Test 2: Register → Assign → Schedule → Score
# ─────────────────────────────────────────────────────────────
def test_registration_to_match_flow(client, admin_token, coach_token):
    """
    Integration: Register player → Assign to team →
    Schedule match → Enter score
    """
    admin_h = {'Authorization': f'Bearer {admin_token}'}
    coach_h = {'Authorization': f'Bearer {coach_token}'}

    # 1. Register new player
    reg = client.post('/api/auth/register', json={
        'name':       'Test Player',
        'email':      'testplayer@college.edu',
        'password':   'Player@123',
        'role':       'player',
        'reg_number': 'CSE2025099',
        'department': 'CSE',
        'year':       2,
        'sport_id':   1
    })
    assert reg.status_code == 201
    player_id = reg.get_json()['player_id']

    # 2. QR code auto-generated on registration
    profile = client.get(f'/api/players/{player_id}', headers=admin_h)
    assert profile.get_json()['qr_code'] is not None

    # 3. Assign player to team
    assign = client.post('/api/teams/1/players',
                         json={'player_id': player_id}, headers=admin_h)
    assert assign.status_code == 201

    # 4. Verify player appears in roster
    roster = client.get('/api/teams/1/players', headers=coach_h).get_json()
    assert any(p['player_id'] == player_id for p in roster['players'])


# ─────────────────────────────────────────────────────────────
# Integration Test 3: QR Verification Flow
# ─────────────────────────────────────────────────────────────
def test_qr_verification_and_logging(client, admin_token):
    """
    Integration: Generate QR → Scan QR → Log recorded → Verify response
    """
    admin_h = {'Authorization': f'Bearer {admin_token}'}

    # 1. Generate player QR
    qr_resp = client.post('/api/qr/generate',
                          json={'qr_type': 'player', 'ref_id': 1},
                          headers=admin_h)
    assert qr_resp.status_code == 201
    qr_url = qr_resp.get_json()['qr_url']
    assert 'verify' in qr_url

    # 2. Simulate QR scan (verify endpoint)
    verify_resp = client.get('/api/verify/SCSS-2025-CERT-001-GOLD')
    assert verify_resp.status_code == 200
    assert verify_resp.get_json()['is_valid'] is True

    # 3. QR scan is logged
    logs = client.get('/api/qr_logs?ref_id=1', headers=admin_h).get_json()
    assert len(logs['logs']) > 0
    assert logs['logs'][0]['qr_type'] in ['player', 'certificate']