# routes/teams.py
from flask import Blueprint, jsonify

teams_bp = Blueprint('teams', __name__, url_prefix='/teams')

@teams_bp.route('/', methods=['GET'])
def list_teams():
    return jsonify({'status': 'success', 'data': []}), 200
    return jsonify({'status': 'success', 'data': {'id': team.id}}), 201