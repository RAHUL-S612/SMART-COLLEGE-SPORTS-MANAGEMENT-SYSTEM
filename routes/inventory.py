"""
models/inventory.py — Inventory ORM Model
"""
from datetime import datetime
from extensions import db


class Inventory(db.Model):
    __tablename__ = 'inventory'

    item_id     = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name        = db.Column(db.String(100), nullable=False)
    sport_id    = db.Column(db.Integer, db.ForeignKey('sports.sport_id',
                            ondelete='SET NULL'), nullable=True)
    quantity    = db.Column(db.Integer, nullable=False, default=0)
    available   = db.Column(db.Integer, nullable=False, default=0)
    condition   = db.Column(db.Enum('good', 'fair', 'damaged', 'maintenance'),
                            nullable=False, default='good')
    description = db.Column(db.Text, default=None)
    created_at  = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at  = db.Column(db.DateTime, nullable=False,
                            default=datetime.utcnow, onupdate=datetime.utcnow)

    sport = db.relationship('Sport')

    def to_dict(self):
        return {
            'item_id':     self.item_id,
            'name':        self.name,
            'sport':       self.sport.sport_name if self.sport else None,
            'sport_id':    self.sport_id,
            'quantity':    self.quantity,
            'available':   self.available,
            'condition':   self.condition,
            'description': self.description,
            'updated_at':  self.updated_at.isoformat() if self.updated_at else None,
        }


class QRLog(db.Model):
    __tablename__ = 'qr_logs'

    log_id     = db.Column(db.Integer, primary_key=True, autoincrement=True)
    qr_type    = db.Column(db.Enum('player', 'team', 'tournament', 'certificate',
                           'match', 'score'), nullable=False)
    ref_id     = db.Column(db.Integer, nullable=False)
    scanned_by = db.Column(db.Integer, db.ForeignKey('users.user_id',
                           ondelete='SET NULL'), nullable=True)
    ip_address = db.Column(db.String(45), default=None)
    scanned_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    scanned_by_user = db.relationship('User', foreign_keys=[scanned_by])

    def to_dict(self):
        return {
            'log_id':     self.log_id,
            'qr_type':    self.qr_type,
            'ref_id':     self.ref_id,
            'scanned_by': self.scanned_by,
            'ip_address': self.ip_address,
            'scanned_at': self.scanned_at.isoformat() if self.scanned_at else None,
        }
