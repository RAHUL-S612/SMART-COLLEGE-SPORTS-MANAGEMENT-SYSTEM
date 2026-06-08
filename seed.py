from app import app
from models import db
from models.user import User
from flask_bcrypt import Bcrypt

with app.app_context():
    db.create_all()
    bcrypt = Bcrypt(app)

    if not User.query.filter_by(email='rahul@college.edu').first():
        hashed = bcrypt.generate_password_hash('Admin@123').decode('utf-8')
        admin = User(
            email='rahul@college.edu',
            password=hashed,
            role='admin',
            name='Rahul'
        )
        db.session.add(admin)
        db.session.commit()
        print('Admin created!')
    else:
        print('Admin already exists!')