# SCSS — Test Suite Reference
# Smart College Sports Management System | SRS v1.0 | Member 9 — R.LALITHA

## Structure

```
scss/
├── app.py                        ← Flask backend (single-file)
├── pytest.ini                    ← Pytest configuration
├── requirements.txt
└── tests/
    ├── __init__.py
    ├── conftest.py               ← Shared fixtures + seed data
    ├── test_auth.py              ← TC-01, TC-02, TC-03
    ├── test_players.py           ← TC-04
    ├── test_matches.py           ← TC-05, TC-06
    ├── test_scores.py            ← TC-07, TC-08
    ├── test_certificates.py      ← TC-09, TC-10, TC-12
    ├── test_leaderboard.py       ← TC-11
    ├── test_analytics.py         ← TC-13
    └── test_security.py          ← TC-14, TC-15
```

## Quick Start

```bash
# 1. Activate virtual environment
source venv/bin/activate          # Linux/Mac
venv\Scripts\activate             # Windows

# 2. Install test dependencies
pip install pytest pytest-flask pytest-cov coverage

# 3. Run all tests
pytest

# 4. Run with coverage report
pytest --cov=app --cov-report=html --cov-report=term-missing

# 5. Run specific SRS test case
pytest tests/test_auth.py::TestTC01_AdminLogin -v
pytest tests/test_matches.py::TestTC06_ConflictDetection -v

# 6. Run by module group
pytest tests/test_auth.py tests/test_security.py -v
```

## Test Case → File Mapping

| SRS ID | Test Case                              | File                    | Class                         |
|--------|----------------------------------------|-------------------------|-------------------------------|
| TC-01  | Admin login with valid credentials     | test_auth.py            | TestTC01_AdminLogin           |
| TC-02  | Player login with wrong password       | test_auth.py            | TestTC02_WrongPassword        |
| TC-03  | Register with duplicate email          | test_auth.py            | TestTC03_DuplicateEmail...    |
| TC-04  | Add player to team → roster updated    | test_players.py         | TestTC04_AddPlayerToTeam      |
| TC-05  | Schedule match → appears in fixture    | test_matches.py         | TestTC05_ScheduleMatch        |
| TC-06  | Schedule conflict → 409 error          | test_matches.py         | TestTC06_ConflictDetection    |
| TC-07  | Enter score → leaderboard updated      | test_scores.py          | TestTC07_ScoreEntry           |
| TC-08  | Certificate auto-generated after result| test_scores.py          | TestTC08_CertificateAuto...   |
| TC-09  | Scan valid QR → Valid status           | test_certificates.py    | TestTC09_ValidQRScan          |
| TC-10  | Scan fake QR → Invalid status          | test_certificates.py    | TestTC10_InvalidQRScan        |
| TC-11  | Leaderboard visible without login      | test_leaderboard.py     | TestTC11_PublicLeaderboard    |
| TC-12  | Player downloads own certificate       | test_certificates.py    | TestTC12_PlayerCertDownload   |
| TC-13  | Admin generates analytics report       | test_analytics.py       | TestTC13_AnalyticsReport      |
| TC-14  | SQL injection attempt blocked by ORM   | test_security.py        | TestTC14_SQLInjection         |
| TC-15  | Mobile responsive layout               | test_security.py        | TestTC15_ResponsiveLayout     |

## Key Design Decisions

- **SQLite in-memory**: Tests use SQLite (not MySQL) for speed and isolation.
  No risk to real sports_db data.
- **Cookie-based JWT**: app.py uses JWT_TOKEN_LOCATION=["cookies"].
  `login_as()` in conftest.py handles this automatically.
- **Role fixtures**: `admin_client`, `coach_client`, `player_client` fixtures
  are pre-authenticated — no manual login needed in each test.
- **Seed data**: `conftest.py` seeds minimal realistic data matching
  sports_db seed (SRS §7 / Table Scripts Member 6 — A.SATHISH).
