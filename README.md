# Ethio Fuel Pass v1.0

Monorepo scaffold for a Flutter Web frontend and Django REST backend, based on the Ethio Fuel Pass SRS.

## Project Structure

```text
EFP/
  backend/
    apps/
      accounts/
      vehicles/
      quotas/
      transactions/
      stations/
      reporting/
    fuel_pass_backend/
    tests/
    manage.py
    requirements.txt
  frontend/
    lib/
      core/
      features/
    pubspec.yaml
  docs/
    roadmap.md
    architecture.md
    api-contract.md
  infra/
    docker-compose.yml
  scripts/
    bootstrap.ps1
  .env.example
  .gitignore
```

## Quick Start

1. Backend
   - `cd backend`
   - `python -m venv .venv`
   - `.venv\\Scripts\\activate`
   - `pip install -r requirements.txt`
   - `python manage.py migrate`
   - `python manage.py runserver`

2. Frontend (Flutter Web)
   - `cd frontend`
   - `flutter pub get`
   - `flutter run -d chrome`

3. Optional local database
   - `docker compose -f infra/docker-compose.yml up -d db`

## Core Modules

- Authentication (JWT)
- Vehicle management
- Quota management
- Transaction logging
- Station operations
- Regulator reporting

See docs in `docs/` for detailed milestones and contracts.