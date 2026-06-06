from flask import Blueprint, jsonify, request, session

notifications_bp = Blueprint('notifications', __name__, url_prefix='/api')

_notifications = [
    {
        'notification_id': 1,
        'user_id':         3,
        'type':            'certificate_ready',
        'message':         'Your certificate is ready for download.',
        'read':            False
    }
]

@notifications_bp.route('/notifications/', methods=['GET'])
@notifications_bp.route('/notifications',  methods=['GET'])
def list_notifications():
    auth = request.headers.get('Authorization', '')
    if not auth.startswith('Bearer ') and session.get('role') not in ('admin', 'coach', 'player'):
        return jsonify({'status': 'error', 'notifications': []}), 401

    uid    = request.args.get('user_id', type=int)
    result = _notifications
    if uid:
        result = [n for n in _notifications if n['user_id'] == uid]

    return jsonify({'status': 'success', 'notifications': result}), 200

@notifications_bp.route('/notifications/', methods=['POST'])
@notifications_bp.route('/notifications',  methods=['POST'])
def create_notification():
    auth = request.headers.get('Authorization', '')
    if not auth.startswith('Bearer ') and session.get('role') not in ('admin',):
        return jsonify({'status': 'error'}), 401
    data = request.get_json() or {}
    notif = {
        'notification_id': len(_notifications) + 1,
        'user_id':         data.get('user_id'),
        'type':            data.get('type',    'general'),
        'message':         data.get('message', ''),
        'read':            False
    }
    _notifications.append(notif)
    return jsonify({'status': 'success', 'data': notif}), 201