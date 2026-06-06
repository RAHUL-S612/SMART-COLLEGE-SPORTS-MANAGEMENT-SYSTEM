"""
extensions.py — Shared Flask extensions (prevents circular imports)
Smart College Sports Management System | SCSS v1.0
"""
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_mail import Mail

db = SQLAlchemy()
bcrypt = Bcrypt()
mail = Mail()