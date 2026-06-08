"""
models/user.py — User ORM Model
Maps to: users table (all roles: admin, coach, player, viewer)
"""
from datetime import datetime
from extensions import db


class User(db.Model):
    __tablename__ = 'users'

    user_id    = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name       = db.Column(db.String(100), nullable=False)
    email      = db.Column(db.String(100), unique=True, nullable=False)
    password   = db.Column(db.String(255), nullable=False, comment='bcrypt hashed')
    role       = db.Column(db.Enum('admin', 'coach', 'player', 'viewer'),
                           nullable=False, default='player')
    phone      = db.Column(db.String(15), default=None)
    is_active  = db.Column(db.Boolean, nullable=False, default=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False,
                           default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'user_id':    self.user_id,
            'name':       self.name,
            'email':      self.email,
            'role':       self.role,
            'phone':      self.phone,
            'is_active':  self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }

    def __repr__(self):
        return f'<User {self.user_id} | {self.email} | {self.role}>'