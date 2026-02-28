# Project Brief

## Project Name
Scroll Architecture Design (Flutter)

## Summary
A Flutter demo e-commerce app that combines:
- MVVM architecture
- Riverpod state management (`AsyncNotifier`)
- FakeStore API integration (`https://fakestoreapi.com`)
- Session persistence using `SharedPreferences`
- A sliver-based product listing UI with advanced nested scrolling

The app demonstrates production-style structure, clean feature separation, and robust scroll behavior for tabbed product lists.

## Objectives
- Implement login with remote token retrieval and local session restore.
- Build a Daraz-inspired products page with:
  - collapsible banner header
  - pinned tab bar
  - horizontal tab swipe
  - preserved per-tab vertical offsets
- Keep business logic separated from UI using MVVM + repository pattern.

## Scope

### In scope
- Authentication flow (`login`, `restore session`, `logout`)
- Product fetching and tab-based filtering
- UI states: loading, error, empty, and success
- Pull-to-refresh integration
- Profile screen with cached user info

### Out of scope
- Cart, checkout, order history
- Search backend integration
- Product details page
- Offline product caching/database
- Automated test suite beyond starter template

## Technical Stack
- Flutter (Material 3)
- Dart SDK `^3.10.8`
- `flutter_riverpod` / `hooks_riverpod`
- `http`
- `shared_preferences`

## Architecture
The project follows layered MVVM per feature:
- **UI Layer**: `screens/` and reusable `widgets/`
- **ViewModel Layer**: `AsyncNotifier` providers
- **Domain Layer**: entities/models + repository contracts
- **Data Layer**: remote data source + repository implementation
- **Core Layer**: API client, constants, storage services, utilities

### Feature modules
- `features/auth`
- `features/products`

## Functional Flow

### App startup
1. Initialize Flutter bindings.
2. Create `SharedPreferences` instance.
3. Inject `SharedPrefsService` through `ProviderScope` override.
4. Launch `App`.

### Authentication flow
1. `AuthGate` watches `authViewModelProvider`.
2. `restoreUserSession()` checks persisted token + user JSON.
3. Routes:
   - no session -> `LoginScreen`
   - valid session -> `ProductsScreen`
4. Login request:
   - POST `/auth/login` for token
   - GET `/users` and match user by username
   - save token + serialized user in local storage
5. Logout clears persisted session and returns to login.

### Products flow
1. `ProductsViewModel.build()` fetches products from `/products`.
2. `productsByTabProvider` filters data into:
   - `All`
   - `Men` (`men's clothing`)
   - `Women` (`women's clothing`)
3. `ProductsScreen` renders nested slivers and tab pages.
4. Pull-to-refresh calls `productsViewModel.refresh()`.

## UI and Scroll Strategy
- Single `NestedScrollView` for shared header + tab body coordination
- `SliverAppBar` with `BannerHeader` and pinned `TabBar`
- `TabBarView` for horizontal swiping
- Per-tab `CustomScrollView` with unique `PageStorageKey`
- `AutomaticKeepAliveClientMixin` to preserve tab subtree state
- `SliverOverlapAbsorber/Injector` for accurate overlap behavior

## API Endpoints Used
- `POST /auth/login`
- `GET /users`
- `GET /products`

Base URL: `https://fakestoreapi.com`

## Default Demo Credential
- Username: `mor_2314`
- Password: `83r5^_`

## Project Structure (High Level)
```text
lib/
|- app.dart
|- auth_gate.dart
|- core/
|  |- api_constants.dart
|  |- constants.dart
|  |- network/api_client.dart
|  |- storage/shared_prefs_service.dart
|  `- utils/refresh_notification_predicate.dart
|- features/
|  |- auth/
|  |  |- data/
|  |  |- domain/
|  |  |- viewmodels/
|  |  `- screens/
|  `- products/
|     |- data/
|     |- domain/
|     |- viewmodels/
|     |- widgets/
|     `- screens/
`- widgets/
```

## Quality Notes
- Error handling is centralized through `ApiException`.
- Repository boundaries keep UI independent from API details.
- Session recovery handles invalid cached payloads by clearing stale data.
- Pull-to-refresh gesture is guarded to reduce false triggers.

## Limitations
- No pagination/infinite scrolling yet.
- No retry backoff or request caching.
- No widget/unit/integration tests for feature logic yet.
- Profile is derived from `/users` list match (demo API constraint).

## Quick Instructions
1. Run the app:
   - `flutter pub get`
   - `flutter run`
2. Scroll architecture instructions:
   - See `project_md_file/Q&A.md`
