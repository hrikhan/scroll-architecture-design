# Flutter MVVM + Riverpod + Sliver Product Listing

Demo app with:
- MVVM architecture
- Riverpod (`AsyncNotifier` + providers)
- `http` networking
- `SharedPreferences` session persistence
- FakeStore API (`https://fakestoreapi.com`)

## Run
1. `flutter pub get`
2. `flutter run`

## FakeStore default credential
- `username`: `mor_2314`
- `password`: `83r5^_`

## Project structure

```txt
lib/
|-- main.dart
|-- app.dart
|-- auth_gate.dart
|-- core/
|   |-- constants.dart
|   |-- network/
|   |   `-- api_client.dart
|   |-- storage/
|   |   |-- shared_prefs_provider.dart
|   |   `-- shared_prefs_service.dart
|   `-- utils/
|       `-- refresh_notification_predicate.dart
|-- features/
|   |-- auth/
|   |   |-- data/
|   |   |   |-- auth_remote_datasource.dart
|   |   |   `-- auth_repository_impl.dart
|   |   |-- domain/
|   |   |   |-- auth_repository.dart
|   |   |   `-- user_model.dart
|   |   |-- viewmodels/
|   |   |   `-- auth_viewmodel.dart
|   |   |-- Login_Flow.md
|   |   `-- screens/
|   |       |-- login_screen.dart
|   |       `-- profile_screen.dart
|   `-- products/
|       |-- data/
|       |   |-- product_remote_datasource.dart
|       |   `-- products_repository_impl.dart
|       |-- domain/
|       |   |-- product_model.dart
|       |   `-- products_repository.dart
|       |-- widgets/
|       |   |-- products_error_state.dart
|       |   |-- products_tab_view.dart
|       |   `-- widgets.dart
|       |-- viewmodels/
|       |   `-- products_viewmodel.dart
|       `-- screens/
|           `-- products_screen.dart
`-- widgets/
    |-- banner_header.dart
    |-- pinned_tabbar.dart
    `-- product_card.dart
```

## Page logic

### `main.dart`
- Boots Flutter and creates `SharedPreferences`.
- Wraps the app in `ProviderScope` and injects `SharedPrefsService`.

### `app.dart`
- Builds `MaterialApp` with global theme and `AuthGate` as `home`.

### `auth_gate.dart`
- Watches `authViewModelProvider`.
- Routes to:
  - `LoginScreen` when no user session exists.
  - `ProductsScreen` when a user is restored/logged in.
  - Loading scaffold while restoring session.

### `login_screen.dart`
- Manages login form state (`username`, `password`, validation).
- Calls `authViewModel.login(...)` on submit.
- Shows provider error with `SnackBar` through `ref.listen`.
- Successful login updates auth state; `AuthGate` then shows products page.

### `products_screen.dart`
- Daraz-style listing page using slivers:
  - `NestedScrollView` with `SliverAppBar` for collapsible banner/search area.
  - `SliverPersistentHeader` with pinned `TabBar`.
  - Per-tab content delegated to feature widgets under `features/products/widgets/`.
- Watches:
  - `productsViewModelProvider` for loading/data/error.
  - `productsByTabProvider(tab)` for filtered data.
- Uses one shared `TabController` for tab taps and horizontal swipes.
- Uses `SliverOverlapAbsorber` in outer slivers to coordinate overlap with tab bodies.
- Pull-to-refresh calls `productsViewModel.refresh()`.

### `profile_screen.dart`
- Reads current user from `authViewModelProvider`.
- Shows decorated profile sections if user exists; otherwise empty state.
- Logout button calls `authViewModel.logout()` and pops back to first route.

## Mandatory explanation

### 1) How horizontal swipe was implemented
- Horizontal swipe is handled by `TabBarView` (native page swipe behavior).
- Tab tap and tab swipe are both driven by one shared `TabController`.

### 2) Who owns vertical scroll and why
- `NestedScrollView` coordinates the collapsing header and the tab bodies.
- Shared header scroll is owned by the outer `NestedScrollView`.
- `SliverOverlapAbsorber` (outer) and `SliverOverlapInjector` (inner) keep sliver overlap behavior correct.
- Each tab body is a dedicated `CustomScrollView` with a unique `PageStorageKey`.
- `AutomaticKeepAliveClientMixin` keeps each tab subtree alive, preserving list state while switching tabs.
- Per-tab list offsets are preserved independently, so one tab list does not overwrite another.
- `RefreshIndicator` uses a custom notification predicate so refresh starts only from a user drag at the top.

### 3) Trade-offs / limitations
- `NestedScrollView` adds coordination complexity compared with one plain `CustomScrollView`.
- Per-tab scroll is restored by key-based scroll storage; behavior depends on stable keys.
- Header collapse state is shared by the nested scroll container, while per-tab body list offsets are preserved.
