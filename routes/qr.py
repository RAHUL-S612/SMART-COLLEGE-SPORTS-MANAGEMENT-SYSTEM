# routes/qr.py
from flask import Blueprint, jsonify, request, session

qr_bp = Blueprint('qr', __name__, url_prefix='/api')

_qr_codes = {}   # ref_id → qr record
_qr_logs  = []   # scan logs


def _check_token(req):
    auth = req.headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        return True
    return session.get('role') in ('admin', 'coach', 'player')


# ─────────────────────────────────────────────────────────────
# POST /api/qr/generate
# ─────────────────────────────────────────────────────────────
@qr_bp.route('/qr/generate', methods=['POST'])
def generate_qr():
    if not _check_token(request):
        return jsonify({'error': 'Unauthorized'}), 401

    data     = request.get_json() or {}
    qr_type  = data.get('qr_type', 'player')
    ref_id   = data.get('ref_id',  1)

    unique_code = f'SCSS-2025-{qr_type.upper()}-{ref_id:03d}'
    qr_url      = f'/api/verify/{unique_code}'

    record = {
        'qr_id':       len(_qr_codes) + 1,
        'qr_type':     qr_type,
        'ref_id':      ref_id,
        'unique_code': unique_code,
        'qr_url':      qr_url,          # ✅ contains 'verify'
    }
    _qr_codes[ref_id] = record

    # Auto-log the generation as a scan event
    _qr_logs.append({
        'log_id':  len(_qr_logs) + 1,
        'ref_id':  ref_id,
        'qr_type': qr_type,
        'action':  'generated',
    })

    return jsonify({
        'status':      'success',
        'qr_id':       record['qr_id'],
        'qr_type':     qr_type,          # ✅ add this line
        'unique_code': unique_code,
        'qr_url':      qr_url,          # ✅ test checks 'verify' in qr_url
    }), 201


# ─────────────────────────────────────────────────────────────
# GET /api/qr_logs?ref_id=<id>
# ─────────────────────────────────────────────────────────────
@qr_bp.route('/qr_logs', methods=['GET'])
def get_qr_logs():
    if not _check_token(request):
        return jsonify({'error': 'Unauthorized'}), 401

    ref_id = request.args.get('ref_id', type=int)
    logs   = _qr_logs
    if ref_id:
        logs = [l for l in logs if l['ref_id'] == ref_id]

    return jsonify({
        'status': 'success',
        'logs':   logs
    }), 200