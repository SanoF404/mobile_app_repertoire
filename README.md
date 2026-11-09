# Peopleo Contacts

## API FastAPI

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
$env:JWT_SECRET = 'replace-with-a-long-random-secret'
uvicorn main:app --reload
```

API documentation: http://127.0.0.1:8000/docs. The API stores users and contacts in `backend/contacts.db`; contacts belong to the authenticated user.

## Flutter

```bash
cd mobile
flutter pub get
flutter run
```

Android emulator API address: `http://10.0.2.2:8000`; desktop and web: `http://127.0.0.1:8000`.
