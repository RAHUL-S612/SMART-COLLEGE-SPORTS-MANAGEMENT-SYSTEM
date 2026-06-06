# tests/test_config.py
# =============================================================
#  Config and app settings tests
# =============================================================

def test_app_config(app):
    assert app.config['TESTING']                    is True
    assert app.config['SECRET_KEY']                 is not None
    assert app.config['SQLALCHEMY_DATABASE_URI']    is not None

def test_app_config_sqlalchemy_track(app):
    assert 'SQLALCHEMY_TRACK_MODIFICATIONS' in app.config

def test_app_has_secret_key(app):
    assert app.config['SECRET_KEY'] != ''

def test_config_class_exists():
    from config import Config, DevelopmentConfig, ProductionConfig, config_map
    assert Config.SECRET_KEY                    is not None
    assert Config.SQLALCHEMY_TRACK_MODIFICATIONS is False
    assert Config.JWT_COOKIE_SECURE             is False
    assert Config.MAIL_PORT                     == 587
    assert Config.MAX_CONTENT_LENGTH            == 5 * 1024 * 1024
    assert 'development' in config_map
    assert 'production'  in config_map
    assert 'default'     in config_map

def test_development_config():
    from config import DevelopmentConfig
    assert DevelopmentConfig.DEBUG is True

def test_production_config():
    from config import ProductionConfig
    assert ProductionConfig.DEBUG             is False
    assert ProductionConfig.JWT_COOKIE_SECURE is True

def test_config_paths():
    from config import Config
    assert Config.QR_CODES_DIR      is not None
    assert Config.CERTIFICATES_DIR  is not None
    assert Config.PLAYER_PHOTOS_DIR is not None
    assert Config.BASE_DIR          is not None

def test_config_map_returns_correct_classes():
    from config import config_map, DevelopmentConfig, ProductionConfig
    assert config_map['development'] is DevelopmentConfig
    assert config_map['production']  is ProductionConfig

def test_config_jwt_settings():
    from config import Config
    assert Config.JWT_ACCESS_TOKEN_EXPIRES is not None
    assert Config.JWT_COOKIE_SAMESITE      == 'Lax'
    assert Config.JWT_TOKEN_LOCATION       == ['cookies']

def test_config_mail_settings():
    from config import Config
    assert Config.MAIL_SERVER  == 'smtp.gmail.com'
    assert Config.MAIL_USE_TLS is True
    assert Config.MAIL_PORT    == 587

def test_config_database_uri():
    from config import Config
    assert 'mysql' in Config.SQLALCHEMY_DATABASE_URI or \
           'sqlite' in Config.SQLALCHEMY_DATABASE_URI

def test_config_engine_options():
    from config import Config
    assert 'pool_recycle'  in Config.SQLALCHEMY_ENGINE_OPTIONS
    assert 'pool_pre_ping' in Config.SQLALCHEMY_ENGINE_OPTIONS

def test_config_app_base_url():
    from config import Config
    assert 'localhost' in Config.APP_BASE_URL or \
           'http'      in Config.APP_BASE_URL

def test_app_runs_directly(app):
    assert app is not None
    rules = [r.rule for r in app.url_map.iter_rules()]
    assert '/' in rules
    assert any('/api/' in r for r in rules)

def test_testing_config_overrides(app):
    assert app.config['TESTING']                    is True
    assert app.config['SQLALCHEMY_DATABASE_URI']    == 'sqlite:///:memory:'