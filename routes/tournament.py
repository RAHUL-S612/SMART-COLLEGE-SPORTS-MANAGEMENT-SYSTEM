"""
models/tournament.py — Tournament ORM Model
"""
from datetime import datetime
from extensions import db


class Tournament(db.Model):
    __tablename__ = 'tournaments'

    tournament_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name          = db.Column(db.String(150), nullable=False)
    sport_id      = db.Column(db.Integer, db.ForeignKey('sports.sport_id',
                              ondelete='RESTRICT'), nullable=False)
    format        = db.Column(db.Enum('round_robin', 'knockout', 'group_knockout'),
                              nullable=False, default='knockout')
    venue         = db.Column(db.String(150), default=None)
    start_date    = db.Column(db.Date, nullable=False)
    end_date      = db.Column(db.Date, nullable=False)
    qr_code       = db.Column(db.String(255), default=None)
    qr_url        = db.Column(db.String(500), default=None)
    status        = db.Column(db.Enum('upcoming', 'ongoing', 'completed', 'cancelled'),
                              nullable=False, default='upcoming')
    created_by    = db.Column(db.Integer, db.ForeignKey('users.user_id',
                              ondelete='RESTRICT'), nullable=False)
    created_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at    = db.Column(db.DateTime, nullable=False,
                              default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    sport        = db.relationship('Sport', back_populates='tournaments')
    matches      = db.relationship('Match', back_populates='tournament',
                                   cascade='all, delete-orphan')
    leaderboard  = db.relationship('Leaderboard', back_populates='tournament',
                                   cascade='all, delete-orphan')
    certificates = db.relationship('Certificate', back_populates='tournament')

    def to_dict(self):
        return {
            'tournament_id': self.tournament_id,
            'name':          self.name,
            'sport':         self.sport.sport_name if self.sport else None,
            'sport_id':      self.sport_id,
            'format':        self.format,
            'venue':         self.venue,
            'start_date':    self.start_date.isoformat() if self.start_date else None,
            'end_date':      self.end_date.isoformat() if self.end_date else None,
            'qr_code':       self.qr_code,
            'qr_url':        self.qr_url,
            'status':        self.status,
            'created_at':    self.created_at.isoformat() if self.created_at else None,
        }

    def __repr__(self): # pragma: no cover
        return f'<Tournament {self.tournament_id} | {self.name}>'
