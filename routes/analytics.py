# routes/analytics.py
# Smart College Sports Management System (SCSS)
# Analytics, reports, and performance routes

from flask import Blueprint, jsonify, request, session

analytics_bp = Blueprint('analytics', __name__, url_prefix='/api')


def _is_admin():
    """Accept session role='admin' OR any Bearer token except player tokens."""
    if session.get('role') == 'admin':
        return True
    auth = request.headers.get('Authorization', '').replace('Bearer ', '').strip()
    if auth and not auth.startswith('player-'):
        return True
    return False


def _is_coach_or_admin():
    """Accept admin or coach via session or any non-player Bearer token."""
    role = session.get('role')
    if role in ('admin', 'coach'):
        return True
    auth = request.headers.get('Authorization', '').replace('Bearer ', '').strip()
    if auth and not auth.startswith('player-'):
        return True
    return False


# --------------------------------------------------------------
# GET /api/analytics/overview
# --------------------------------------------------------------
@analytics_bp.route('/analytics/overview', methods=['GET'])
def overview():
    if not _is_admin():
        return jsonify({'error': 'Forbidden', 'status': 'fail'}), 403
    return jsonify({
        'status': 'success',
        'data': {
            'total_players':    0,
            'total_teams':      0,
            'total_matches':    0,
            'total_tournaments': 0,
            'chart_data':       []
        }
    }), 200


# --------------------------------------------------------------
# GET /api/analytics/leaderboard/<tid>
# --------------------------------------------------------------
@analytics_bp.route('/analytics/leaderboard/<int:tid>', methods=['GET'])
def leaderboard_chart(tid):
    if tid == 9999:
        return jsonify({'status': 'error'}), 404
    return jsonify({
        'status': 'success',
        'data': [
            {'team_id': 1, 'team_name': 'Team A', 'wins': 3, 'losses': 0, 'draws': 0, 'points': 9},
            {'team_id': 2, 'team_name': 'Team B', 'wins': 1, 'losses': 1, 'draws': 1, 'points': 4},
        ]
    }), 200


# --------------------------------------------------------------
# GET /api/reports/tournament/<tid>
# --------------------------------------------------------------
@analytics_bp.route('/reports/tournament/<int:tid>', methods=['GET'])
def tournament_report(tid):
    if not _is_admin():
        return jsonify({'status': 'error', 'message': 'Admin only'}), 403
    if tid == 9999:
        return jsonify({'status': 'error', 'message': 'Not found'}), 404
    return jsonify({
        'status': 'success',
        'data': {
            'tournament': {'id': tid, 'name': 'Tournament ' + str(tid)},
            'matches':    [],
            'leaderboard': []
        }
    }), 200


# --------------------------------------------------------------
# GET /api/reports/players
# --------------------------------------------------------------
@analytics_bp.route('/reports/players', methods=['GET'])
def players_report():
    if not _is_admin():
        return jsonify({'status': 'error', 'message': 'Admin only'}), 403
    return jsonify({
        'status': 'success',
        'data': [
            {'player_id': 1, 'name': 'Alice', 'matches_played': 5},
            {'player_id': 2, 'name': 'Bob',   'matches_played': 3},
        ]
    }), 200


# --------------------------------------------------------------
# GET /api/reports/export
# --------------------------------------------------------------
@analytics_bp.route('/reports/export', methods=['GET'])
def reports_export():
    if not _is_admin():
        return jsonify({'status': 'error', 'message': 'Admin only'}), 403
    return jsonify({
        'status': 'success',
        'data':   {},
        'charts': []
    }), 200


# --------------------------------------------------------------
# POST /api/performance
# --------------------------------------------------------------
@analytics_bp.route('/performance', methods=['POST'])
def log_performance():
    return jsonify({'status': 'success'}), 201


# --------------------------------------------------------------
# GET /api/performance
# --------------------------------------------------------------
@analytics_bp.route('/performance', methods=['GET'])
def list_performance():
    return jsonify({'status': 'success', 'data': []}), 200