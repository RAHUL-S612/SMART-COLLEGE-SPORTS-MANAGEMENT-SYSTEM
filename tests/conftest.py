import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import pytest
from app import create_app
from models import db as _db


@pytest.fixture(scope='session')
def app():
    application = create_app()
    application.config.update({
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': 'sqlite:///:memory:',
        'WTF_CSRF_ENABLED': False,
        'SECRET_KEY': 'test-secret-key',
        'PROPAGATE_EXCEPTIONS': False,
    })

    # Register test-only 500 route BEFORE any request
    @application.route('/test_force_500_xyz')
    def force_500():
        raise Exception("forced 500 error")

    return application


@pytest.fixture(scope='session')
def db(app):
    with app.app_context():
        _db.create_all()
        yield _db
        _db.drop_all()


@pytest.fixture
def client(app):
    app.config['TESTING'] = False
    c = app.test_client()
    yield c
    app.config['TESTING'] = True


@pytest.fixture
def login_as(client):
    def _login(username, password):
        return client.post('/api/auth/login', json={
            'username': username, 'password': password
        }, follow_redirects=True)
    return _login


@pytest.fixture
def admin_client(app):
    c = app.test_client()
    with c.session_transaction() as sess:
        sess['user'] = 'admin'
        sess['role'] = 'admin'
    return c


@pytest.fixture
def player_client(app):
    c = app.test_client()
    with c.session_transaction() as sess:
        sess['user'] = 'player1'
        sess['role'] = 'player'
    return c


@pytest.fixture
def coach_client(app):
    c = app.test_client()
    with c.session_transaction() as sess:
        sess['user'] = 'coach1'
        sess['role'] = 'coach'
    return c


@pytest.fixture
def admin_token(admin_client):
    return 'admin-test-token'


@pytest.fixture
def coach_token(coach_client):
    return 'coach-test-token'