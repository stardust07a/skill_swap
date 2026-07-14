# Skill Swap — Flutter Application

A cross-platform Flutter application for exchanging skills without a monetary marketplace. Users define what they can teach and what they want to learn, discover compatible people, exchange requests, chat, and review completed interactions.

The project is a self-contained local prototype: application data is stored in SQLite on the device, while the signed-in user ID is retained with SharedPreferences.

## Highlights

- Registration and local sign-in
- Editable user profiles with city, district, and biography
- Separate “teach” and “learn” skill lists
- Compatibility-based match suggestions
- User detail pages with skills and ratings
- Direct local messaging and conversation history
- Skill-swap request creation and status management
- Five-star reviews and average rating calculation
- Seeded demo users, messages, requests, skills, and reviews
- Dark, responsive interface with reusable gradient components
- Flutter targets for Android, iOS, web, Windows, macOS, and Linux

## Matching algorithm

The local matching engine compares each user with every non-admin user and ranks positive matches.

| Signal | Score |
| --- | ---: |
| The other user teaches a skill the current user wants to learn | +40 |
| The current user teaches a skill the other user wants to learn | +40 |
| Same city | +10 |
| Same district | +10 |
| A skill exchange is possible | +10 |

The displayed score is capped at 100 and results are sorted from highest to lowest.

## Technology

- Flutter / Dart
- Material Design
- `sqflite` for local relational storage
- `shared_preferences` for lightweight session persistence
- `intl` for date formatting

## Getting started

### Requirements

- Flutter SDK compatible with Dart `^3.12.2`
- A configured Flutter target such as Android Studio, an iOS simulator, Chrome, or a desktop toolchain

### Install and run

```bash
git clone https://github.com/stardust07a/skill_swap.git
cd skill_swap
flutter pub get
flutter run
```

Choose a specific target when necessary:

```bash
flutter devices
flutter run -d chrome
```

### Quality checks

```bash
flutter analyze
flutter test
```

## Demo accounts

The database is seeded on first creation. All demo accounts use the password `123456`.

| Account | Email | Example role |
| --- | --- | --- |
| Ahmet | `ahmet@skillswap.com` | Teaches coding and React |
| Selin | `selin@skillswap.com` | Teaches guitar and music |
| Merve | `merve@skillswap.com` | Teaches English |
| Kerem | `kerem@skillswap.com` | Teaches yoga |
| Deniz | `deniz@skillswap.com` | Teaches painting |
| Admin | `admin@skillswap.com` | Seeded administrator account |

## Data model

| Table | Responsibility |
| --- | --- |
| `users` | Identity, location, biography, and admin flag |
| `skills` | Skills a user teaches or wants to learn |
| `messages` | Sender, recipient, message body, and timestamp |
| `requests` | Swap offers and their current status |
| `reviews` | Reviewer, target user, rating, comment, and timestamp |

The database is created as `skill_swap.db` in the platform-specific application database directory.

## Application structure

```text
lib/
├── main.dart                 # Theme, routes, and application entry point
├── db/database_helper.dart   # Schema, seed data, queries, and matching engine
├── models/                   # User, skill, message, request, and review models
├── screens/                  # Authentication and feature screens
└── widgets/                  # Shared navigation, cards, and buttons
```

Important screens include dashboard, profile editing, skill management, matches, user details, messages, chat, requests, and reviews.

## Current limitations

- This is a local prototype; there is no backend API or cross-device synchronization.
- Passwords are stored as plain text in the local SQLite database and are not production-safe.
- SharedPreferences stores only a local user ID and is not a secure authentication session.
- Local data is isolated per installation and can be lost when application data is cleared.
- The included widget test is minimal; database and workflow coverage should be expanded.
- Admin-specific management screens are not currently implemented.

## Production roadmap

- Replace local authentication with a secure backend and hashed passwords
- Add cloud synchronization and real-time messaging
- Introduce request notifications and moderation tools
- Add database migrations, repository abstractions, and broader tests
- Improve accessibility, localization, and offline conflict handling

## Author

Built by **Aziz** as a Flutter, local-database, and product-flow project.
