from fastapi.testclient import TestClient
import main


def test_signup_login_and_contact_lifecycle(tmp_path):
    main.DB_PATH = tmp_path / 'test_contacts.db'
    main.SECRET = 'test-secret-long-enough-for-hmac'
    with TestClient(main.app) as client:
        signup = client.post('/signup', json={'email': 'sami@example.com', 'password': 'password123'})
        assert signup.status_code == 201
        token = signup.json()['access_token']
        headers = {'Authorization': f'Bearer {token}'}

        created = client.post('/personnes', headers=headers, json={
            'nom': 'Trabelsi', 'prenom': 'Sami', 'telephone': '98123456'
        })
        assert created.status_code == 201
        person_id = created.json()['id']
        assert client.get('/personnes', headers=headers).json()[0]['prenom'] == 'Sami'

        duplicate = client.post('/personnes', headers=headers, json={
            'nom': 'Autre', 'prenom': 'Ali', 'telephone': '98123456'
        })
        assert duplicate.status_code == 409

        updated = client.put(f'/personnes/{person_id}', headers=headers, json={
            'nom': 'Gharbi', 'prenom': 'Leila', 'telephone': '22456789'
        })
        assert updated.status_code == 200
        assert updated.json()['nom'] == 'Gharbi'

        assert client.delete(f'/personnes/{person_id}', headers=headers).status_code == 204
        assert client.get(f'/personnes/{person_id}', headers=headers).status_code == 404
        assert client.get('/personnes').status_code == 401

        login = client.post('/login', data={'username': 'sami@example.com', 'password': 'password123'})
        assert login.status_code == 200
