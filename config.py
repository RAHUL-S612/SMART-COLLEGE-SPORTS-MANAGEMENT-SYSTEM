"""
config.py — Environment-based configuration
Smart College Sports Management System | SCSS v1.0
"""
import os
from datetime import timedelta


class Config:
    # -- Security ---------------------------------------------
    SECRET_KEY = os.environ.get('SECRET_KEY', 'SmartSportal@2026')

    # -- Database ---------------------------------------------
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'mysql+pymysql://root:@localhost/sports_management')
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_recycle': 280,
        'pool_pre_ping': True,
    }

    # -- JWT --------------------------------------------------
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'JWT@SmartSportal2026')
    JWT_TOKEN_LOCATION       = ['cookies']
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=30)
    JWT_COOKIE_SECURE        = False
    JWT_COOKIE_CSRF_PROTECT  = False
    JWT_COOKIE_SAMESITE      = 'Lax'

    # -- Mail (SMTP) ------------------------------------------
    MAIL_SERVER         = os.environ.get('MAIL_SERVER',   'smtp.gmail.com')
    MAIL_PORT           = int(os.environ.get('MAIL_PORT', 587))
    MAIL_USE_TLS        = True
    MAIL_USERNAME       = os.environ.get('MAIL_USERNAME', 'your-email@gmail.com')   # ← change
    MAIL_PASSWORD       = "olag ayhm vbop htgw"    # ← change
    MAIL_DEFAULT_SENDER = os.environ.get('MAIL_USERNAME', 'your-email@gmail.com')   # ← change

    # -- File Paths -------------------------------------------
    BASE_DIR           = os.path.abspath(os.path.dirname(__file__))
    QR_CODES_DIR       = os.path.join(BASE_DIR, 'static', 'qr_codes')
    CERTIFICATES_DIR   = os.path.join(BASE_DIR, 'static', 'certificates')
    PLAYER_PHOTOS_DIR  = os.path.join(BASE_DIR, 'static', 'images', 'players')
    MAX_CONTENT_LENGTH = 5 * 1024 * 1024

    # -- App Settings -----------------------------------------
    APP_BASE_URL = os.environ.get('APP_BASE_URL', 'http://localhost:5000')


class DevelopmentConfig(Config):
    DEBUG           = True
    SQLALCHEMY_ECHO = False


class ProductionConfig(Config):
    DEBUG                   = False
    JWT_COOKIE_SECURE       = True
    JWT_COOKIE_CSRF_PROTECT = True


config_map = {
    'development': DevelopmentConfig,
    'production':  ProductionConfig,
    'default':     DevelopmentConfig,
}