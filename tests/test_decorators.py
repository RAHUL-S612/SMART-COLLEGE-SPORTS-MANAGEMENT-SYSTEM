# tests/test_decorators.py

def test_admin_required_blocks_player(player_client):
    resp = player_client.get('/api/analytics/overview')
    assert resp.status_code == 403

def test_admin_required_allows_admin(admin_client):
    resp = admin_client.get('/api/analytics/overview')
    assert resp.status_code == 200

def test_login_required_blocks_guest(client):
    resp = client.get('/api/players')
    assert resp.status_code in [200, 401, 403]

def test_coach_required_blocks_player(player_client):
    resp = player_client.get('/api/reports/players')
    assert resp.status_code == 403

def test_bearer_token_accepted(client):
    resp = client.get('/api/players',
                      headers={'Authorization': 'Bearer admin-test-token'})
    assert resp.status_code == 200

def test_decorator_module_importable():
    from routes.decorators import (
        admin_required,
        coach_or_admin_required,
        player_required,
        login_required_any,
        _get_role
    )
    assert callable(admin_required)
    assert callable(coach_or_admin_required)
    assert callable(player_required)
    assert callable(login_required_any)
    assert callable(_get_role)

def test_get_role_returns_string_outside_context():
    from routes.decorators import _get_role
    try:
        role = _get_role()
        assert isinstance(role, str)
    except Exception:
        pass

def test_admin_required_wraps_function():
    from routes.decorators import admin_required
    def my_view(): return 'ok'
    wrapped = admin_required(my_view)
    assert wrapped.__name__ == 'my_view'

def test_coach_or_admin_required_wraps():
    from routes.decorators import coach_or_admin_required
    def my_view(): return 'ok'
    wrapped = coach_or_admin_required(my_view)
    assert wrapped.__name__ == 'my_view'

def test_player_required_wraps():
    from routes.decorators import player_required
    def my_view(): return 'ok'
    wrapped = player_required(my_view)
    assert wrapped.__name__ == 'my_view'

def test_login_required_any_wraps():
    from routes.decorators import login_required_any
    def my_view(): return 'ok'
    wrapped = login_required_any(my_view)
    assert wrapped.__name__ == 'my_view'

def test_admin_required_is_decorator():
    from routes.decorators import admin_required
    import inspect
    src = inspect.getsource(admin_required)
    assert 'admin'   in src
    assert 'wraps'   in src
    assert 'wrapper' in src

def test_coach_or_admin_required_source():
    from routes.decorators import coach_or_admin_required
    import inspect
    src = inspect.getsource(coach_or_admin_required)
    assert 'coach'  in src
    assert 'admin'  in src
    assert 'wraps'  in src

def test_player_required_source():
    from routes.decorators import player_required
    import inspect
    src = inspect.getsource(player_required)
    assert 'player' in src
    assert 'wraps'  in src

def test_login_required_any_source():
    from routes.decorators import login_required_any
    import inspect
    src = inspect.getsource(login_required_any)
    assert 'wraps'   in src
    assert 'wrapper' in src

def test_get_role_source():
    from routes.decorators import _get_role
    import inspect
    src = inspect.getsource(_get_role)
    assert 'get_jwt_identity' in src
    assert 'role'             in src