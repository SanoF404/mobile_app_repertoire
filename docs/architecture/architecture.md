# Peopleo Contacts — Architecture Documentation

> Generated from source code analysis. All components and relationships are verified from the actual code.

---

## 1. High-Level Architecture

```mermaid
graph TB
    subgraph Mobile["📱 Flutter Mobile App (mobile/)"]
        UI["Presentation Layer\nScreens & Widgets"]
        STATE["State Layer\nProvider / ChangeNotifier"]
        DATA["Data Layer\nRepositories"]
    end

    subgraph Backend["🖥️ FastAPI Backend (backend/)"]
        API["REST API\nmain.py"]
        AUTH_BE["Auth Module\n/signup · /login"]
        PERSONS["Contacts Module\n/personnes"]
        DB[("SQLite\ncontacts.db")]
    end

    subgraph Storage["📦 Local Storage"]
        SEC["flutter_secure_storage\nJWT token"]
        SQLITE_LOCAL[("SQLite local\npeopleo.db\nalternate repo")]
        ASSETS["Assets\nliste_a.json\nliste_b.json"]
    end

    UI --> STATE
    STATE --> DATA
    DATA -- "HTTP REST / JSON" --> API
    API --> AUTH_BE
    API --> PERSONS
    AUTH_BE --> DB
    PERSONS --> DB
    DATA -- "read/write JWT" --> SEC
    DATA -- "optional offline" --> SQLITE_LOCAL
    UI -- "loadString" --> ASSETS
```

---

## 2. Detailed Component Diagram

```mermaid
graph LR
    subgraph app["app/"]
        PeopleoApp["PeopleoApp\nStatelessWidget\n- MultiProvider\n- MaterialApp\n- routing"]
    end

    subgraph core["core/theme/"]
        AppTheme["AppTheme\n- light ThemeData"]
        AppColors["AppColors\n- background\n- navy\n- text"]
        neumorphic["neumorphicDecoration()\nBoxDecoration factory"]
        LocaleModel["LocaleModel\nChangeNotifier\n- locale\n- toggle()"]
    end

    subgraph auth["features/auth/"]
        AuthService["AuthService\n- login()\n- signup()\n- token()\n- logout()"]
        LoginPage["LoginPage\nStatefulWidget"]
        SignUpPage["SignUpPage\nStatefulWidget"]
    end

    subgraph contacts["features/contacts/"]
        ContactRepo["interface ContactRepository\n- lister()\n- ajouter()\n- modifier()\n- supprimer()"]
        RestRepo["RestRepository\nimplements ContactRepository\nHTTP calls to /personnes"]
        SqliteRepo["SqliteRepository\nimplements ContactRepository\nlocal SQLite fallback"]
        ContactsModel["ContactsModel\nChangeNotifier\n- items\n- charger()\n- ajouter()\n- modifier()\n- supprimer()\n- chercher()"]
        ContactsPage["ContactsPage\nStatefulWidget\n- search bar\n- list + swipe-delete\n- add/edit dialog"]
        ContactCard["ContactCard\nStatelessWidget"]
        ContactValidator["validateTelephone()\ndomain function"]
    end

    subgraph comparison["features/comparison/"]
        ComparisonPage["ComparisonPage\nStatefulWidget\n- chargerDonnees()\n- comparerListes()\n- trouverDifferences()"]
    end

    subgraph directory["features/directory/"]
        DirIllustration["DirectoryIllustration\nStatelessWidget\ndecorative only"]
    end

    subgraph models["models/"]
        Contact["Contact\n- id?\n- nom\n- prenom\n- telephone\n- nomComplet\n- fromJson()\n- toJson()"]
    end

    subgraph l10n["l10n/"]
        AppLoc["AppLocalizations\nfr + ar\n18 string keys"]
    end

    PeopleoApp --> ContactsModel
    PeopleoApp --> LocaleModel
    PeopleoApp --> LoginPage
    PeopleoApp --> SignUpPage
    PeopleoApp --> ContactsPage
    PeopleoApp --> ComparisonPage

    LoginPage --> AuthService
    LoginPage --> DirIllustration
    SignUpPage --> AuthService

    ContactsPage --> ContactsModel
    ContactsPage --> AuthService
    ContactsPage --> ContactCard
    ContactsPage --> ContactValidator
    ContactsPage --> AppLoc
    ContactsPage --> LocaleModel

    ContactsModel --> ContactRepo
    ContactsModel --> Contact
    RestRepo -.implements.-> ContactRepo
    SqliteRepo -.implements.-> ContactRepo
    RestRepo --> AuthService

    AppTheme --> AppColors
    neumorphic --> AppColors
```

---

## 3. Data Flow — CRUD and Authentication

```mermaid
sequenceDiagram
    actor User
    participant UI as ContactsPage
    participant Model as ContactsModel
    participant Repo as RestRepository
    participant Secure as flutter_secure_storage
    participant API as FastAPI /personnes
    participant DB as SQLite contacts.db

    Note over UI,DB: Load contacts on screen open
    UI->>Model: charger()
    Model->>Repo: lister()
    Repo->>Secure: read jwt
    Secure-->>Repo: eyJ...
    Repo->>API: GET /personnes Bearer token
    API->>DB: SELECT FROM persons WHERE owner_id=?
    DB-->>API: rows
    API-->>Repo: 200 JSON list
    Repo-->>Model: List of maps
    Model-->>UI: notifyListeners()

    Note over UI,DB: Add a contact
    User->>UI: fills form + Save
    UI->>Model: ajouter contact
    Model->>Model: _telephoneExiste check
    Model->>Repo: ajouter jsonMap
    Repo->>Secure: read jwt
    Repo->>API: POST /personnes Bearer + JSON body
    API->>DB: INSERT INTO persons
    DB-->>API: new row
    API-->>Repo: 201 JSON
    Model->>Repo: lister refresh
    Model-->>UI: notifyListeners()

    Note over UI,DB: Authentication
    User->>UI: LoginPage SIGN IN
    UI->>+AuthService: login email password
    AuthService->>API: POST /login form-urlencoded
    API->>DB: SELECT users WHERE email=?
    API->>API: verify_password PBKDF2
    API-->>AuthService: 200 access_token
    AuthService->>Secure: write jwt token
    AuthService-->>-UI: done
    UI->>UI: navigate to /contacts
```

---

## 4. Deployment Diagram

```mermaid
graph TB
    subgraph DEV["Developer Machine"]
        subgraph flutter_process["Flutter process"]
            APK["Android APK / iOS App"]
        end
        subgraph uvicorn_process["uvicorn  port 8000"]
            FASTAPI["FastAPI main.py"]
            SQLITE_FILE["contacts.db SQLite file"]
        end
        FASTAPI --- SQLITE_FILE
    end

    subgraph android_emulator["Android Emulator"]
        APP["Peopleo App\n10.0.2.2:8000 to host"]
        SEC_STORE["Encrypted Storage\nflutter_secure_storage"]
        APP --- SEC_STORE
    end

    APK --> android_emulator
    APP -- "HTTP REST GET POST PUT DELETE" --> FASTAPI

    subgraph env_vars["Environment config"]
        JWT_ENV["JWT_SECRET env var"]
        DB_ENV["CONTACTS_DB env var optional"]
        API_URL["--dart-define=API_URL optional\ndefault 10.0.2.2:8000"]
    end

    JWT_ENV -.-> FASTAPI
    DB_ENV -.-> FASTAPI
    API_URL -.-> APP
```

---

## 5. Database Schema

```mermaid
erDiagram
    users {
        INTEGER id PK
        TEXT email "UNIQUE NOT NULL"
        TEXT password_hash "PBKDF2 salt dollar digest"
    }
    persons {
        INTEGER id PK
        TEXT nom "NOT NULL"
        TEXT prenom "NOT NULL"
        TEXT telephone "UNIQUE NOT NULL"
        INTEGER owner_id FK
    }
    users ||--o{ persons : "owns ON DELETE CASCADE"
```

---

## Technology Stack

| Component | Technology | Version |
|---|---|---|
| Backend framework | FastAPI | >= 0.115, < 1 |
| Backend server | Uvicorn | >= 0.30, < 1 |
| Backend database | SQLite | stdlib |
| Backend auth | PBKDF2-HMAC-SHA256 + HS256 JWT | stdlib |
| Form parsing | python-multipart | >= 0.0.9 |
| Mobile framework | Flutter / Dart | SDK ^3.13.5 |
| State management | Provider | ^6.1.5 |
| HTTP client | http | ^1.6.0 |
| Secure token storage | flutter_secure_storage | ^10.0.0 |
| Local DB alternate | sqflite | ^2.4.2 |
| Localization | flutter_localizations | SDK · fr + ar |
| Backend tests | pytest + httpx | >= 8, >= 0.27 |
| Flutter tests | flutter_test | SDK |
| Linting | flutter_lints | ^6.0.0 |
