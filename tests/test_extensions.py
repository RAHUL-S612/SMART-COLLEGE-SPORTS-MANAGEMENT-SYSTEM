# tests/test_extensions.py

def test_db_initialized(app):
    from models import db
    assert db is not None

def test_db_has_engine(app):
    from models import db
    with app.app_context():
        assert db.engine is not None

def test_app_extensions(app):
    assert 'sqlalchemy' in app.extensions

def test_extensions_importable():
    from extensions import db, bcrypt, mail
    assert db     is not None
    assert bcrypt is not None
    assert mail   is not None

def test_db_is_sqlalchemy():
    from extensions import db
    from flask_sqlalchemy import SQLAlchemy
    assert isinstance(db, SQLAlchemy)

def test_bcrypt_is_bcrypt():
    from extensions import bcrypt
    from flask_bcrypt import Bcrypt
    assert isinstance(bcrypt, Bcrypt)

def test_mail_is_mail():
    from extensions import mail
    from flask_mail import Mail
    assert isinstance(mail, Mail)

def test_extensions_module_docstring():
    import extensions
    assert extensions.__doc__ is not None
    assert 'extensions' in extensions.__doc__.lower() or \
           'Flask'      in extensions.__doc__