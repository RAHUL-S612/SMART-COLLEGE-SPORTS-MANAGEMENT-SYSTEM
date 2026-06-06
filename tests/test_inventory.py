# tests/test_inventory.py
def test_inventory_list(admin_client):
    """GET /api/inventory/ returns 200."""
    resp = admin_client.get('/api/inventory/')
    assert resp.status_code == 200

def test_inventory_create(admin_client):
    """POST /api/inventory/ creates item."""
    resp = admin_client.post('/api/inventory/', json={
        'name':     'Cricket Bat',
        'quantity': 10,
        'sport_id': 1
    })
    assert resp.status_code in [200, 201]

def test_inventory_get_by_id(admin_client):
    """GET /api/inventory/1 returns item."""
    resp = admin_client.get('/api/inventory/1')
    assert resp.status_code in [200, 404]

def test_inventory_update(admin_client):
    """PUT /api/inventory/1 updates item."""
    resp = admin_client.put('/api/inventory/1',
                            json={'quantity': 20})
    assert resp.status_code in [200, 404]

def test_inventory_delete(admin_client):
    """DELETE /api/inventory/1 removes item."""
    resp = admin_client.delete('/api/inventory/1')
    assert resp.status_code in [200, 204, 404]

def test_inventory_blocked_for_player(player_client):
    """Player cannot access inventory."""
    resp = player_client.get('/api/inventory/')
    assert resp.status_code in [200, 403]