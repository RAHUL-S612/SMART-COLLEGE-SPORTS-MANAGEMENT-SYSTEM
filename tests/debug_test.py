from app import create_app

app = create_app()

with app.test_client() as c:
    r = c.get(
        '/api/notifications/?user_id=3',
        headers={'Authorization': 'Bearer admin-test-token'}
    )
    print('Status:', r.status_code)
    print('Body  :', r.data)
    print('JSON  :', r.get_json())