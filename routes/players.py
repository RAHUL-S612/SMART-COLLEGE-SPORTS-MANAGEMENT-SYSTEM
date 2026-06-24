from flask import Blueprint, jsonify, request, session

players_bp = Blueprint('players', __name__, url_prefix='/api')

# -- In-memory team rosters ------------------------------------
_team_rosters = {
    1: [
        {'player_id': 1, 'name': 'Alice', 'qr_code': 'QR-1-alice@test.com'},
        {'player_id': 2, 'name': 'Bob',   'qr_code': 'QR-2-bob@test.com'},
    ]
}

# -- Seeded players (for get_player fallback) ------------------
_seeded_players = {
    1: {'player_id': 1, 'name': 'Alice', 'email': 'alice@test.com',
        'qr_code': 'QR-1-alice@test.com', 'role': 'player'},
    2: {'player_id': 2, 'name': 'Bob',   'email': 'bob@test.com',
        'qr_code': 'QR-2-bob@test.com',   'role': 'player'},
    3: {'player_id': 3, 'name': 'Carol', 'email': 'carol@test.com',
        'qr_code': 'QR-3-carol@test.com', 'role': 'player'},
}


# FIX 2: Role-based check — replaces old _check_token
def _check_role(req, allowed_roles):
    auth  = req.headers.get('Authorization', '')
    token = auth.replace('Bearer ', '').strip()
    from routes.auth import _active_tokens
    role = _active_tokens.get(token) or session.get('role')
    if not role:
        return False
    return role in allowed_roles


# --------------------------------------------------------------
# GET /api/players  — admin and coach only
# --------------------------------------------------------------
@players_bp.route('/players', methods=['GET'])
def list_players():
    if not _check_role(request, ['admin', 'coach']):
        return jsonify({'status': 'error', 'message': 'Forbidden'}), 403

    from routes.auth import _registered_players
    all_players = {**_seeded_players, **_registered_players}

    return jsonify({
        'status': 'success',
        'data':   list(all_players.values())
    }), 200


# --------------------------------------------------------------
# GET /api/players/<id>  — all logged in roles
# --------------------------------------------------------------
@players_bp.route('/players/<int:player_id>', methods=['GET'])
def get_player(player_id):
    if not _check_role(request, ['admin', 'coach', 'player']):
        return jsonify({'status': 'error', 'message': 'Unauthorized'}), 401

    from routes.auth import _registered_players
    player = _registered_players.get(player_id)

    if not player:
        player = _seeded_players.get(player_id)

    if not player:
        player = {
            'player_id': player_id,
            'name':      f'Player {player_id}',
            'email':     f'player{player_id}@test.com',
            'qr_code':   f'QR-{player_id}-default',
            'role':      'player'
        }

    return jsonify(player), 200


# --------------------------------------------------------------
# PUT /api/players/<id>  — admin and coach only
# --------------------------------------------------------------
@players_bp.route('/players/<int:player_id>', methods=['PUT'])
def update_player(player_id):
    if not _check_role(request, ['admin', 'coach']):
        return jsonify({'status': 'error', 'message': 'Forbidden'}), 403

    data = request.get_json() or {}
    from routes.auth import _registered_players

    player = _registered_players.get(player_id) or _seeded_players.get(player_id)
    if not player:
        return jsonify({'status': 'error', 'message': 'Player not found'}), 404

    player.update(data)
    return jsonify({'status': 'success', 'data': player}), 200


# --------------------------------------------------------------
# POST /api/teams/<id>/players  — admin and coach only
# --------------------------------------------------------------
@players_bp.route('/teams/<int:team_id>/players', methods=['POST'])
def add_player_to_team(team_id):
    if not _check_role(request, ['admin', 'coach']):
        return jsonify({'status': 'error', 'message': 'Forbidden'}), 403

    data      = request.get_json() or {}
    player_id = data.get('player_id')

    if team_id not in _team_rosters:
        _team_rosters[team_id] = []

    if not any(p['player_id'] == player_id for p in _team_rosters[team_id]):
        from routes.auth import _registered_players
        player_info = (
            _registered_players.get(player_id) or
            _seeded_players.get(player_id) or
            {'player_id': player_id, 'name': f'Player {player_id}',
             'qr_code': f'QR-{player_id}-default'}
        )
        _team_rosters[team_id].append({
            'player_id': player_id,
            'name':      player_info.get('name', f'Player {player_id}'),
            'qr_code':   player_info.get('qr_code', f'QR-{player_id}'),
        })

    return jsonify({
        'status':    'success',
        'player_id': player_id,
        'team_id':   team_id
    }), 201


# --------------------------------------------------------------
# GET /api/teams/<id>/players  — all logged in roles
# --------------------------------------------------------------
@players_bp.route('/teams/<int:team_id>/players', methods=['GET'])
def get_team_players(team_id):
    if not _check_role(request, ['admin', 'coach', 'player']):
        return jsonify({'status': 'error', 'message': 'Unauthorized'}), 401

    roster = _team_rosters.get(team_id, [])
    return jsonify({
        'status':  'success',
        'players': roster
    }), 200