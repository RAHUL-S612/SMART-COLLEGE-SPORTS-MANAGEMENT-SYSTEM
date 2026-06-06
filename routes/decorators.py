"""
SCSS - decorators.py
RBAC decorators that wrap Flask-JWT-Extended.
Each decorator reads the role from the JWT identity and blocks
or allows access accordingly (FR-AU-02, FR-AU-05).

Usage example:
    @app.route("/admin/dashboard")
    @jwt_required()
    @admin_required
    def dashboard():
        ...
"""
from functools import wraps
from flask import jsonify, redirect, url_for, flash
from flask_jwt_extended import get_jwt_identity


def _get_role() -> str:
    """Return role string from JWT identity, or empty string if not present."""
    identity = get_jwt_identity()
    return identity.get("role", "") if identity else ""


def admin_required(fn):
    """Allow only users with role='admin'."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if _get_role() != "admin":
            flash("Admin access required.", "danger")
            return redirect(url_for("auth.login"))
        return fn(*args, **kwargs)
    return wrapper


def coach_or_admin_required(fn):
    """Allow admin and coach roles."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if _get_role() not in ("admin", "coach"):
            flash("Coach or Admin access required.", "danger")
            return redirect(url_for("auth.login"))
        return fn(*args, **kwargs)
    return wrapper


def player_required(fn):
    """Allow only players (and admin for testing)."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if _get_role() not in ("player", "admin"):
            flash("Player access required.", "danger")
            return redirect(url_for("auth.login"))
        return fn(*args, **kwargs)
    return wrapper


def login_required_any(fn):
    """Allow any authenticated user."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if not _get_role():
            flash("Please log in.", "warning")
            return redirect(url_for("auth.login"))
        return fn(*args, **kwargs)
    return wrapper
