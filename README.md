# Flutter MVVM + Riverpod + Single-Scroll Architecture

Production-ready demo using:
- MVVM architecture
- Riverpod (`AsyncNotifier` + providers)
- `http` package (no Dio)
- `SharedPreferences` token persistence
- FakeStore API (`https://fakestoreapi.com/`)

## Features
- Login with FakeStore auth endpoint
- Persisted session token + cached user profile
- Profile screen (reads stored user from session state)
- Daraz-style product listing UI
- Collapsible banner header + sticky tab bar
- Tabs switch by tap and horizontal swipe
- Pull-to-refresh from any tab
- Clean separation: UI / ViewModel / Repository / DataSource

## Project Structure

```txt
lib/
├── main.dart
├── core/
│   ├── network/
│   │   └── api_client.dart
│   ├── storage/
│   │   ├── shared_prefs_service.dart
│   │   └── shared_prefs_provider.dart
│   └── constants.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_remote_datasource.dart
│   │   │   └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── auth_repository.dart
│   │   │   └── user_model.dart
│   │   ├── viewmodels/
│   │   │   └── auth_viewmodel.dart
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       └── profile_screen.dart
│   │
│   └── products/
│       ├── data/
│       │   ├── product_remote_datasource.dart
│       │   └── products_repository_impl.dart
│       ├── domain/
│       │   ├── product_model.dart
│       │   └── products_repository.dart
│       ├── viewmodels/
│       │   └── products_viewmodel.dart
│       └── screens/
│           └── products_screen.dart
│
└── widgets/
    ├── pinned_tabbar.dart
    └── banner_header.dart
```

## Run
1. `flutter pub get`
2. `flutter run`

## Architecture Notes (Mandatory)

### 1) Horizontal swipe implementation
- `TabBarView` is used for tab pages.
- `TabBarView` internally uses a `PageView`, so horizontal drag is isolated to page switching.
- `TabBar` tap and `TabBarView` swipe are both active.

### 2) Vertical scroll owner
- The screen is built with `RefreshIndicator -> NestedScrollView`.
- `NestedScrollView` coordinates the header slivers and the active tab content so the app behaves like one continuous vertical experience.
- Inner tab content uses `CustomScrollView + SliverList` and is coordinated by the outer nested scroll behavior.

### 3) Trade-offs and limitations
- `NestedScrollView` is powerful but more complex than a plain list.
- Sliver composition requires discipline (header/body ownership, pinned behavior, refresh notifications).
- To preserve tab positions and avoid jump/reset behavior, each tab uses a `PageStorageKey` and keep-alive.

## FakeStore Default Credential
- `username`: `mor_2314`
- `password`: `83r5^_`
