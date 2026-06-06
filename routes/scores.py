from flask import Blueprint, jsonify, request, session

scores_bp = Blueprint('scores', __name__, url_prefix='/scores')

_scores = []

def _check_token(req):
    auth = req.headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        return True
    return session.get('role') in ('admin', 'coach', 'player')

def list_scores():
    return jsonify({'status': 'success', 'data': _scores}), 200

def post_score():
    if not _check_token(request):
        return jsonify({'status': 'error'}), 401
    data = request.get_json() or request.form.to_dict()
    
    # ✅ Assign a score_id
    score_id = len(_scores) + 1
    record = {**data, 'score_id': score_id}
    _scores.append(record)
    
    return jsonify({
        'status':   'success',
        'score_id': score_id,        # ✅ now included
        'data':     record
    }), 201

def add_score():
    if request.content_type and 'application/json' in request.content_type:
        data = request.get_json() or {}
    else:
        data = request.form.to_dict()

    score_id = len(_scores) + 1
    record = {**data, 'score_id': score_id}
    _scores.append(record)

    return jsonify({
        'status':   'success',
        'score_id': score_id,        # ✅ now included
        'data':     record
    }), 200

# Register routes on blueprint
scores_bp.add_url_rule('/',    view_func=list_scores, methods=['GET'])
scores_bp.add_url_rule('/',    view_func=post_score,  methods=['POST'])
scores_bp.add_url_rule('/add', view_func=add_score,   methods=['POST'])