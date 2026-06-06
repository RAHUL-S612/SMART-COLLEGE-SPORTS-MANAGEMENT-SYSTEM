from flask import Blueprint, jsonify, request, session

certificates_bp = Blueprint('certificates', __name__, url_prefix='/api')

VALID_CODES = {'SCSS-2025-CERT-001-GOLD', 'SCSS-2025-CERT-002-SILVER'}

_certs = [
    {
        'certificate_id': 1,
        'player_id':      1,
        'tournament_id':  1,
        'position':       1,                        # ✅ Gold
        'unique_code':    'SCSS-2025-CERT-001-GOLD',# ✅ starts with SCSS-
        'pdf_path':       '/files/cert_1.pdf',
        'player_name':    'Alice'
    }
]

def _check_token(req):
    auth = req.headers.get('Authorization', '')
    return auth.startswith('Bearer ') or session.get('role') in ('admin', 'coach', 'player')

# GET /api/verify/<code>
@certificates_bp.route('/verify/<string:code>', methods=['GET'])
def verify_cert(code):
    if any(c in code for c in ["'", '"', ';', '--']):
        return jsonify({'is_valid': False, 'error': 'Invalid input'}), 400
    if code in VALID_CODES:
        return jsonify({
            'is_valid':    True,
            'player_name': 'Alice',
            'tournament':  'SCSS 2025'
        }), 200
    return jsonify({'is_valid': False, 'message': 'Certificate not found'}), 404

# GET /api/certificates/
@certificates_bp.route('/certificates/', methods=['GET'])
def list_certs():
    tid = request.args.get('tournament_id', type=int)
    pid = request.args.get('player_id',     type=int)
    result = _certs
    if tid:
        result = [c for c in result if c['tournament_id'] == tid]
    if pid:
        result = [c for c in result if c['player_id'] == pid]
    return jsonify({'status': 'success', 'certificates': result}), 200

# GET /api/certificates/<id>/download
@certificates_bp.route('/certificates/<int:cert_id>/download', methods=['GET'])
def download_cert(cert_id):
    if not _check_token(request):
        return jsonify({'error': 'Unauthorized'}), 401
    pdf_bytes = b'%PDF-1.4 1 0 obj<</Type/Catalog>>endobj'
    return pdf_bytes, 200, {
        'Content-Type':        'application/pdf',
        'Content-Disposition': f'attachment; filename=cert_{cert_id}.pdf'
    }

# GET /api/certificates/?tournament_id=1
# GET /api/analytics/...  — keep existing analytics routes separate