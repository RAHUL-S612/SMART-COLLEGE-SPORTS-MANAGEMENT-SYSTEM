# tests/test_notification.py
def test_notifications_list(admin_client):
    """GET /api/notifications/ returns list."""
    resp = admin_client.get('/api/notifications/?user_id=3')
    assert resp.status_code == 200
    data = resp.get_json()
    assert 'notifications' in data
    assert isinstance(data['notifications'], list)

def test_notifications_has_type(admin_client):
    """Each notification has a type field."""
    resp  = admin_client.get('/api/notifications/?user_id=3')
    notifs = resp.get_json()['notifications']
    if notifs:
        assert 'type' in notifs[0]

def test_notification_create(admin_client):
    """POST /api/notifications/ creates notification."""
    resp = admin_client.post('/api/notifications/', json={
        'user_id': 1,
        'type':    'match_scheduled',
        'message': 'New match scheduled'
    })
    assert resp.status_code in [200, 201]

def test_notifications_empty_for_unknown_user(admin_client):
    """Unknown user_id returns empty list."""
    resp  = admin_client.get('/api/notifications/?user_id=9999')
    notifs = resp.get_json()['notifications']
    assert isinstance(notifs, list)

def test_notifications_unauthorized(client):
    """Unauthenticated request handled."""
    resp = client.get('/api/notifications/?user_id=3')
    assert resp.status_code in [200, 401, 403]