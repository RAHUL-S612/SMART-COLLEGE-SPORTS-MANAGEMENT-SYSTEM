# app.py
# Smart College Sports Management System (SCSS)
# Main application factory

from flask import Flask, Blueprint
from models import db


def create_app():
    app = Flask(__name__)

    # -- Configuration -----------------------------------------
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/sports_db'
    app.config['SECRET_KEY']                     = 'dev-secret-key'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['TESTING']                        = False
    app.config['JSON_SORT_KEYS']                 = False

    # Allow /route and /route/ without 308 redirect
    app.url_map.strict_slashes = False

    # -- Database ----------------------------------------------
    db.init_app(app)

    # -- Root route --------------------------------------------
    @app.route('/')
    def index():
        return '''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SCSS - Sports Management</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: Arial, sans-serif;
            background: #1e1e2e;
            color: #cdd6f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            text-align: center;
            padding: 40px 60px;
            background: #313244;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.4);
        }
        h1 { color: #89b4fa; font-size: 28px; margin-bottom: 10px; }
        p  { color: #a6adc8; margin-bottom: 16px; }
        .badge {
            display: inline-block;
            background: #a6e3a1;
            color: #1e1e2e;
            padding: 4px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .endpoints {
            margin-top: 20px;
            text-align: left;
            font-size: 13px;
            color: #89dceb;
        }
        .endpoints li { margin: 4px 0; list-style: none; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Smart College Sports Management</h1>
        <p>SCSS v1.0 - API Server Running</p>
        <span class="badge">&#x2705; Status: Online</span>
        <ul class="endpoints">
            <li>POST /api/auth/login</li>
            <li>GET  /api/players</li>
            <li>POST /api/matches/</li>
            <li>POST /api/scores/</li>
            <li>GET  /api/leaderboard/1</li>
            <li>GET  /api/analytics/overview</li>
            <li>GET  /api/certificates/</li>
            <li>GET  /api/notifications/</li>
        </ul>
    </div>
</body>
</html>''', 200

    # -- Register Blueprints -----------------------------------
    from routes.auth             import auth_bp
    from routes.teams            import teams_bp
    from routes.matches          import matches_bp
    from routes.players          import players_bp
    from routes.analytics        import analytics_bp
    from routes.leaderboard      import leaderboard_bp
    from routes.certificates     import certificates_bp
    from routes.notifications    import notifications_bp
    from routes.qr               import qr_bp
    from routes.inventory_routes import inventory_bp
    from routes.scores           import scores_bp, list_scores, post_score

    app.register_blueprint(auth_bp)            # /api/auth/...
    app.register_blueprint(teams_bp)           # /teams/...
    app.register_blueprint(matches_bp)         # /api/matches/...
    app.register_blueprint(players_bp)         # /api/players/...
    app.register_blueprint(analytics_bp)       # /api/analytics/...
    app.register_blueprint(leaderboard_bp)     # /api/leaderboard/...
    app.register_blueprint(certificates_bp)    # /api/certificates/...
    app.register_blueprint(notifications_bp)   # /api/notifications/...
    app.register_blueprint(qr_bp)              # /api/qr/...
    app.register_blueprint(inventory_bp)       # /api/inventory/...
    app.register_blueprint(scores_bp)          # /scores/

    # Second registration for /api/scores/
    scores_api_bp = Blueprint(
        'scores_api', __name__, url_prefix='/api/scores'
    )
    scores_api_bp.add_url_rule(
        '/', view_func=list_scores, methods=['GET']
    )
    scores_api_bp.add_url_rule(
        '/', view_func=post_score,  methods=['POST']
    )
    app.register_blueprint(scores_api_bp)      # /api/scores/

    # -- Error Handlers ----------------------------------------
    @app.errorhandler(404)
    def not_found(e):
        from flask import jsonify, request
        if request.path.startswith('/api/'):
            return jsonify({
                'status':  'error',
                'message': 'Endpoint not found',
                'path':    request.path
            }), 404
        return jsonify({
            'status':  'error',
            'message': 'Not found'
        }), 404

    @app.errorhandler(405)
    def method_not_allowed(e):
        from flask import jsonify, request
        return jsonify({
            'status':  'error',
            'message': 'Method not allowed',
            'path':    request.path
        }), 405

    @app.errorhandler(500)
    def internal_error(e):
        from flask import jsonify
        return jsonify({
            'status':  'error',
            'message': 'Internal server error'
        }), 500

    return app


# -- Run directly --------------------------------------------
if __name__ == '__main__':
    import os
    if os.name == 'nt':  # Windows
        from waitress import serve
        serve(app, host='0.0.0.0', port=5000)
    else:  # Linux (Render)
        app.run()
    )