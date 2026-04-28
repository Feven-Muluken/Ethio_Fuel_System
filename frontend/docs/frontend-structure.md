# Frontend Structure (frontend1)

This project uses a feature-first, scalable Flutter structure:

```text
lib/
  app.dart
  main.dart
  core/
    constants/
      api_endpoints.dart
      app_strings.dart
    env/
      app_config.dart
    network/
      api_client.dart
    router/
      app_router.dart
    theme/
      app_theme.dart
  shared/
    widgets/
      module_card.dart
      responsive_shell.dart
  features/
    auth/
      data/models/
      domain/entities/
      presentation/pages/
      presentation/providers/
    buyer/
      data/models/
      presentation/pages/
    station/
      data/models/
      presentation/pages/
    regulator/
      data/models/
      presentation/pages/
```

Implementation order:

1. `auth` login + token storage.
2. `buyer` quota and pass generation.
3. `station` validation and transaction posting.
4. `regulator` reporting and monitoring.
