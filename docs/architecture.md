# Ethio Fuel Pass Architecture

## System Topology

- Frontend: Flutter Web single-page app with role-based navigation.
- Backend: Django REST API with JWT auth and domain apps.
- Database: PostgreSQL (single source of truth for users, vehicles, quotas, transactions, stations).

## Domain Boundaries

- `accounts`: registration, login, role flags.
- `vehicles`: plate registration and ownership.
- `quotas`: per-vehicle daily/weekly limits and remaining balances.
- `transactions`: station-side fueling events and quota deduction.
- `stations`: station profile and operator assignment.
- `reporting`: regulator-facing aggregated insights.

## Security Baseline

- JWT bearer auth for all protected endpoints.
- Enforce HTTPS in production.
- Log every transaction and admin quota adjustment.
- Add anti-replay tokens for QR flows in phase 2.
