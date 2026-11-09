# Peopleo Contacts

## API FastAPI

Bash:

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
export JWT_SECRET="use-a-random-secret-of-your-own"
uvicorn main:app --reload
```

PowerShell on Windows:

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt -r requirements-dev.txt
$env:JWT_SECRET = "use-a-random-secret-of-your-own"
uvicorn main:app --reload
```

API documentation: http://127.0.0.1:8000/docs. SQLite stores accounts and contacts; each contact belongs to its signed-in user.

## Flutter

```bash
cd mobile
flutter pub get
flutter run
```

The Android emulator uses `http://10.0.2.2:8000` by default. For Windows or Chrome, run with `--dart-define=API_URL=http://127.0.0.1:8000`.

## Contact data and comparisons

The app keeps contacts in a `List<Map<String, dynamic>>`. Each map has `id`, `prenom`, `nom`, and `telephone`; repositories exchange these maps as JSON. Search compares names without case sensitivity and compares phone digits after removing spaces and punctuation. Before add or edit, the app compares normalized phone numbers to reject duplicates. SQLite remains available as an alternate `ContactRepository` implementation.

## Checks

```bash
cd mobile
flutter analyze
flutter test
cd ../backend
python -m pytest -q
```
