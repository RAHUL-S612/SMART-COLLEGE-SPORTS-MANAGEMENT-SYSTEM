# app.py
# Smart College Sports Management System (SCSS)
# Main application factory

import os
from flask import Flask, Blueprint
from flask import render_template
from models import db
from routes.teams import teams_bp
from routes.matches import matches_bp
from routes.players import players_bp

def create_app():
    app = Flask(__name__)

    # -- Configuration -----------------------------------------
    database_url = os.environ.get('DATABASE_URL', 'mysql+pymysql://root:@localhost/sports_db')
    if database_url.startswith('postgres://'):
        database_url = database_url.replace('postgres://', 'postgresql://', 1)
    app.config['SQLALCHEMY_DATABASE_URI'] = database_url
    app.config['SECRET_KEY']              = os.environ.get('SECRET_KEY', 'SmartSportal@2026')
    app.config['JWT_SECRET_KEY']          = os.environ.get('JWT_SECRET_KEY', 'JWT@SmartSportal2026')
    app.config['FLASK_ENV']               = os.environ.get('FLASK_ENV', 'development')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['TESTING']                        = False
    app.config['JSON_SORT_KEYS']                 = False
    app.config['SQLALCHEMY_ENGINE_OPTIONS']      = {'connect_args': {'connect_timeout': 5}}

    # Allow /route and /route/ without 308 redirect
    app.url_map.strict_slashes = False

    # -- Database ----------------------------------------------
    db.init_app(app)

    # -- Root route --------------------------------------------
    @app.route('/')
    def index():
        return render_template('SCSS_Frontend_Pro')



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

    app.register_blueprint(auth_bp)
    app.register_blueprint(teams_bp)
    app.register_blueprint(matches_bp)
    app.register_blueprint(players_bp)
    app.register_blueprint(analytics_bp)
    app.register_blueprint(leaderboard_bp)
    app.register_blueprint(certificates_bp)
    app.register_blueprint(notifications_bp)
    app.register_blueprint(qr_bp)
    app.register_blueprint(inventory_bp)
    app.register_blueprint(scores_bp)

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
    app.register_blueprint(scores_api_bp)

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


# -- For gunicorn (Render) -----------------------------------
app = create_app()

# -- Run directly (Windows local) ----------------------------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
