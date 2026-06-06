# routes/inventory_routes.py
from flask import Blueprint, jsonify, request, session

inventory_bp = Blueprint('inventory', __name__, url_prefix='/api')

_inventory = [
    {'item_id': 1, 'name': 'Cricket Bat', 'quantity': 10,
     'available': 8, 'condition': 'good', 'sport_id': 1}
]

def _check_token(req):
    auth = req.headers.get('Authorization', '')
    return auth.startswith('Bearer ') or session.get('role') in ('admin', 'coach')

@inventory_bp.route('/inventory/', methods=['GET'])
@inventory_bp.route('/inventory',  methods=['GET'])
def list_inventory():
    return jsonify({'status': 'success', 'data': _inventory}), 200

@inventory_bp.route('/inventory/', methods=['POST'])
@inventory_bp.route('/inventory',  methods=['POST'])
def create_inventory():
    if not _check_token(request):
        return jsonify({'error': 'Unauthorized'}), 403
    data = request.get_json() or {}
    item = {
        'item_id':   len(_inventory) + 1,
        'name':      data.get('name'),
        'quantity':  data.get('quantity', 0),
        'available': data.get('quantity', 0),
        'condition': data.get('condition', 'good'),
        'sport_id':  data.get('sport_id', 1)
    }
    _inventory.append(item)
    return jsonify({'status': 'success', 'data': item}), 201

@inventory_bp.route('/inventory/<int:item_id>', methods=['GET'])
def get_inventory(item_id):
    item = next((i for i in _inventory if i['item_id'] == item_id), None)
    if not item:
        return jsonify({'error': 'Not found'}), 404
    return jsonify({'status': 'success', 'data': item}), 200

@inventory_bp.route('/inventory/<int:item_id>', methods=['PUT'])
def update_inventory(item_id):
    item = next((i for i in _inventory if i['item_id'] == item_id), None)
    if not item:
        return jsonify({'error': 'Not found'}), 404
    data = request.get_json() or {}
    item.update(data)
    return jsonify({'status': 'success', 'data': item}), 200

@inventory_bp.route('/inventory/<int:item_id>', methods=['DELETE'])
def delete_inventory(item_id):
    global _inventory
    item = next((i for i in _inventory if i['item_id'] == item_id), None)
    if not item:
        return jsonify({'error': 'Not found'}), 404
    _inventory = [i for i in _inventory if i['item_id'] != item_id]
    return jsonify({'status': 'success'}), 200