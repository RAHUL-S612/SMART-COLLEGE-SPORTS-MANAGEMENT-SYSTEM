with open('routes/auth.py', 'w') as f:
    f.write("""from flask import Blueprint, jsonify, request, session
import secrets

auth_bp = Blueprint('auth', __name__, url_prefix='/api')

_active_tokens = {}
_registered_players = {}

_users = {
    'admin':   {'password': 'admin123',  'role': 'admin',  'user_id': 1},
    'coach1':  {'password': 'coach123',  'role': 'coach',  'user_id': 2},
    'player1': {'password': 'player123', 'role': 'player', 'user_id': 3},
}

def _generate_token(role):
    token = role + '-' + secrets.token_hex(8)
    _active_tokens[token] = role
    return token

@auth_bp.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    username = data.get('username') or data.get('email', '').split('@')[0]
    password = data.get('password')
    if not password:
        return jsonify({'status': 'error', 'message': 'Missing password'}), 400
    user = _users.get(username)
    if not user or user['password'] != password:
        return jsonify({'status': 'error', 'message': 'Invalid credentials'}), 401
    token = _generate_token(user['role'])
    session['user'] = username
    session['role'] = user['role']
    return jsonify({
        'status': 'success',
        'access_token': token,
        'role': user['role'],
        'user_id': user['user_id']
    }), 200

@auth_bp.route('/auth/logout', methods=['POST'])
def logout():
    auth = request.headers.get('Authorization', '')
    token = auth.replace('Bearer ', '').strip()
    _active_tokens.pop(token, None)
    session.clear()
    return jsonify({'status': 'success', 'message': 'Logged out'}), 200

@auth_bp.route('/auth/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    name = data.get('name')
    email = data.get('email', '')
    if not name:
        return jsonify({'status': 'error', 'message': 'Name required'}), 400
    if not email:
        return jsonify({'status': 'error', 'message': 'Email required'}), 400
    for pid, p in list(_registered_players.items()):
        if p['email'] == email:
            return jsonify({'status': 'error', 'message': 'Email already registered'}), 409
    reg_number = data.get('reg_number', '')
    player_id = len(_registered_players) + 100
    player = {
        'player_id': player_id,
        'name': name,
        'email': email,
        'role': 'player',
        'reg_number': reg_number,
        'department': data.get('department'),
        'year': data.get('year'),
        'sport_id': data.get('sport_id'),
        'qr_code': 'QR-' + str(player_id) + '-' + str(reg_number)
    }
    _registered_players[player_id] = player
    return jsonify({'status': 'success', 'player_id': player_id}), 201

@auth_bp.route('/auth/verify-token', methods=['GET'])
def verify_token():
    auth = request.headers.get('Authorization', '')
    token = auth.replace('Bearer ', '').strip()
    role = _active_tokens.get(token)
    if role:
        return jsonify({'status': 'success', 'valid': True, 'role': role}), 200
    return jsonify({'status': 'error', 'valid': False, 'message': 'Invalid token'}), 401

@auth_bp.route('/auth/me', methods=['GET'])
def me():
    auth = request.headers.get('Authorization', '')
    token = auth.replace('Bearer ', '').strip()
    role = _active_tokens.get(token)
    if not role:
        role = session.get('role')
    if not role:
        return jsonify({'status': 'error', 'message': 'Unauthorized'}), 401
    return jsonify({'status': 'success', 'role': role}), 200

@auth_bp.route('/auth/users', methods=['GET'])
def list_users():
    auth = request.headers.get('Authorization', '')
    token = auth.replace('Bearer ', '').strip()
    role = _active_tokens.get(token)
    if not role:
        role = session.get('role')
    if role != 'admin':
        return jsonify({'status': 'error', 'message': 'Forbidden'}), 403
    return jsonify({'status': 'success', 'data': list(_users.keys())}), 200
""")
print('routes/auth.py written successfully')