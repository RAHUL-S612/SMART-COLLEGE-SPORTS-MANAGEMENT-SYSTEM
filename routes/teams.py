# routes/teams.py
from flask import Blueprint, jsonify, request

teams_bp = Blueprint('teams', __name__, url_prefix='/api/teams')

_teams = []   # in-memory store (see note below on moving this to the DB)

@teams_bp.route('/', methods=['GET'])
def list_teams():
    return jsonify({'status': 'success', 'data': _teams}), 200

@teams_bp.route('/', methods=['POST'])
def create_team():
    data = request.get_json() or {}
    name = data.get('name')
    if not name:
        return jsonify({'status': 'error', 'message': 'Team name required'}), 400

    team = {
        'team_id':      len(_teams) + 1,
        'name':         name,
        'department':   data.get('department'),
        'sport_id':     data.get('sport_id'),
        'coach_id':     data.get('coach_id'),
    }
    _teams.append(team)
    return jsonify({'status': 'success', 'data': team}), 201