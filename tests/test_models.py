# tests/test_models.py
import inspect

# ─────────────────────────────────────────────────────────────
# User Model
# ─────────────────────────────────────────────────────────────
def test_user_model_exists():
    from models.user import User
    assert User is not None

def test_user_model_tablename():
    from models.user import User
    assert User.__tablename__ == 'users'

def test_user_model_has_fields():
    from models.user import User
    cols = [c.name for c in User.__table__.columns]
    assert 'user_id'    in cols
    assert 'email'      in cols
    assert 'role'       in cols
    assert 'name'       in cols
    assert 'password'   in cols
    assert 'is_active'  in cols
    assert 'created_at' in cols
    assert 'updated_at' in cols

def test_user_model_columns_count():
    from models.user import User
    cols = [c.name for c in User.__table__.columns]
    assert len(cols) >= 7

def test_user_model_role_enum():
    from models.user import User
    col = User.__table__.columns['role']
    assert col.default.arg == 'player'

def test_user_model_is_active_default():
    from models.user import User
    col = User.__table__.columns['is_active']
    assert col.default.arg is True

def test_user_to_dict_source():
    from models.user import User
    src = inspect.getsource(User.to_dict)
    assert 'user_id'   in src
    assert 'email'     in src
    assert 'role'      in src
    assert 'is_active' in src
    assert 'name'      in src

def test_user_repr_source():
    from models.user import User
    src = inspect.getsource(User.__repr__)
    assert 'user_id' in src or 'email' in src

def test_user_to_dict_return_type():
    from models.user import User
    src = inspect.getsource(User.to_dict)
    assert 'return' in src
    assert 'created_at' in src

def test_user_model_nullable_constraints():
    from models.user import User
    cols = {c.name: c for c in User.__table__.columns}
    assert cols['name'].nullable  is False
    assert cols['email'].nullable is False
    assert cols['role'].nullable  is False

# ─────────────────────────────────────────────────────────────
# Sport Model
# ─────────────────────────────────────────────────────────────
def test_sport_model_importable():
    from routes.sport import Sport
    assert Sport is not None
    assert Sport.__tablename__ == 'sports'

def test_sport_model_columns():
    from routes.sport import Sport
    cols = [c.name for c in Sport.__table__.columns]
    assert 'sport_id'      in cols
    assert 'sport_name'    in cols
    assert 'is_active'     in cols
    assert 'max_team_size' in cols
    assert 'description'   in cols
    assert 'created_at'    in cols

def test_sport_to_dict_keys():
    from routes.sport import Sport
    src = inspect.getsource(Sport.to_dict)
    assert 'sport_id'      in src
    assert 'sport_name'    in src
    assert 'is_active'     in src
    assert 'max_team_size' in src
    assert 'description'   in src

def test_sport_repr_source():
    from routes.sport import Sport
    src = inspect.getsource(Sport.__repr__)
    assert 'sport_id' in src or 'sport_name' in src

def test_sport_default_max_team_size():
    from routes.sport import Sport
    col = Sport.__table__.columns['max_team_size']
    assert col.default.arg == 11

def test_sport_is_active_default():
    from routes.sport import Sport
    col = Sport.__table__.columns['is_active']
    assert col.default.arg is True

def test_sport_sport_name_unique():
    from routes.sport import Sport
    col = Sport.__table__.columns['sport_name']
    assert col.unique is True

def test_sport_to_dict_return():
    from routes.sport import Sport
    src = inspect.getsource(Sport.to_dict)
    assert 'return' in src

# ─────────────────────────────────────────────────────────────
# Tournament Model
# ─────────────────────────────────────────────────────────────
def test_tournament_model_importable():
    from routes.tournament import Tournament
    assert Tournament is not None
    assert Tournament.__tablename__ == 'tournaments'

def test_tournament_model_columns():
    from routes.tournament import Tournament
    cols = [c.name for c in Tournament.__table__.columns]
    assert 'tournament_id' in cols
    assert 'name'          in cols
    assert 'status'        in cols
    assert 'format'        in cols
    assert 'venue'         in cols
    assert 'start_date'    in cols
    assert 'end_date'      in cols
    assert 'qr_code'       in cols
    assert 'qr_url'        in cols

def test_tournament_to_dict_keys():
    from routes.tournament import Tournament
    src = inspect.getsource(Tournament.to_dict)
    assert 'tournament_id' in src
    assert 'name'          in src
    assert 'status'        in src
    assert 'format'        in src
    assert 'venue'         in src
    assert 'start_date'    in src
    assert 'end_date'      in src
    assert 'qr_code'       in src

def test_tournament_repr_source():
    from routes.tournament import Tournament
    src = inspect.getsource(Tournament.__repr__)
    assert 'tournament_id' in src or 'name' in src

def test_tournament_status_default():
    from routes.tournament import Tournament
    col = Tournament.__table__.columns['status']
    assert col.default.arg == 'upcoming'

def test_tournament_format_default():
    from routes.tournament import Tournament
    col = Tournament.__table__.columns['format']
    assert col.default.arg == 'knockout'

def test_tournament_name_not_nullable():
    from routes.tournament import Tournament
    col = Tournament.__table__.columns['name']
    assert col.nullable is False

def test_tournament_to_dict_return():
    from routes.tournament import Tournament
    src = inspect.getsource(Tournament.to_dict)
    assert 'return'         in src
    assert 'created_at'     in src

# ─────────────────────────────────────────────────────────────
# Inventory Model
# ─────────────────────────────────────────────────────────────
def test_inventory_model_importable():
    from routes.inventory import Inventory
    assert Inventory is not None
    assert Inventory.__tablename__ == 'inventory'

def test_inventory_model_columns():
    from routes.inventory import Inventory
    cols = [c.name for c in Inventory.__table__.columns]
    assert 'item_id'     in cols
    assert 'name'        in cols
    assert 'quantity'    in cols
    assert 'condition'   in cols
    assert 'available'   in cols
    assert 'description' in cols
    assert 'sport_id'    in cols
    assert 'created_at'  in cols
    assert 'updated_at'  in cols

def test_inventory_to_dict_keys():
    from routes.inventory import Inventory
    src = inspect.getsource(Inventory.to_dict)
    assert 'item_id'   in src
    assert 'name'      in src
    assert 'quantity'  in src
    assert 'condition' in src
    assert 'available' in src

def test_inventory_condition_default():
    from routes.inventory import Inventory
    col = Inventory.__table__.columns['condition']
    assert col.default.arg == 'good'

def test_inventory_quantity_default():
    from routes.inventory import Inventory
    col = Inventory.__table__.columns['quantity']
    assert col.default.arg == 0

def test_inventory_available_default():
    from routes.inventory import Inventory
    col = Inventory.__table__.columns['available']
    assert col.default.arg == 0

def test_inventory_to_dict_return():
    from routes.inventory import Inventory
    src = inspect.getsource(Inventory.to_dict)
    assert 'return'     in src
    assert 'updated_at' in src

# ─────────────────────────────────────────────────────────────
# QRLog Model
# ─────────────────────────────────────────────────────────────
def test_qrlog_model_importable():
    from routes.inventory import QRLog
    assert QRLog is not None
    assert QRLog.__tablename__ == 'qr_logs'

def test_qrlog_model_columns():
    from routes.inventory import QRLog
    cols = [c.name for c in QRLog.__table__.columns]
    assert 'log_id'     in cols
    assert 'qr_type'    in cols
    assert 'ref_id'     in cols
    assert 'scanned_by' in cols
    assert 'ip_address' in cols
    assert 'scanned_at' in cols

def test_qrlog_to_dict_keys():
    from routes.inventory import QRLog
    src = inspect.getsource(QRLog.to_dict)
    assert 'log_id'     in src
    assert 'qr_type'    in src
    assert 'ref_id'     in src
    assert 'scanned_by' in src
    assert 'scanned_at' in src

def test_qrlog_to_dict_return():
    from routes.inventory import QRLog
    src = inspect.getsource(QRLog.to_dict)
    assert 'return' in src