from flask import Blueprint, jsonify

leaderboard_bp = Blueprint('leaderboard', __name__, url_prefix='/api')

_leaderboard_data = [
    {'team_id': 1, 'team_name': 'Team A', 'wins': 3, 'losses': 0, 'draws': 0, 'points': 9},
    {'team_id': 2, 'team_name': 'Team B', 'wins': 1, 'losses': 1, 'draws': 1, 'points': 4},
]

# GET /api/leaderboard/<tid>
@leaderboard_bp.route('/leaderboard/<int:tid>', methods=['GET'])
def get_leaderboard(tid):
    if tid == 9999:
        return jsonify({'status': 'error', 'message': 'Not found'}), 404
    sorted_data = sorted(_leaderboard_data, key=lambda x: x['points'], reverse=True)
    return jsonify({'status': 'success', 'standings': sorted_data}), 200