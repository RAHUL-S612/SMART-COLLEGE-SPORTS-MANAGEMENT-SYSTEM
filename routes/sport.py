"""
models/sport.py — Sport ORM Model
"""
from datetime import datetime
from extensions import db


class Sport(db.Model):
    __tablename__ = 'sports'

    sport_id      = db.Column(db.Integer, primary_key=True, autoincrement=True)
    sport_name    = db.Column(db.String(80), unique=True, nullable=False)
    description   = db.Column(db.Text, default=None)
    max_team_size = db.Column(db.Integer, nullable=False, default=11)
    is_active     = db.Column(db.Boolean, nullable=False, default=True)
    created_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    # Relationships
    players     = db.relationship('Player', back_populates='sport')
    teams       = db.relationship('Team', back_populates='sport')
    tournaments = db.relationship('Tournament', back_populates='sport')

    def to_dict(self):
        return {
            'sport_id':      self.sport_id,
            'sport_name':    self.sport_name,
            'description':   self.description,
            'max_team_size': self.max_team_size,
            'is_active':     self.is_active,
        }

    def __repr__(self): # pragma: no cover
        return f'<Sport {self.sport_id} | {self.sport_name}>'
