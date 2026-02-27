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
  - `SliverAppBar` for collapsible banner/search area.
  - `SliverPersistentHeader` with pinned `TabBar`.
  - Product content as `SliverGrid`.
- Watches:
  - `productsViewModelProvider` for loading/data/error.
  - `productsByTabProvider(activeTab)` for filtered data.
- Keeps tab state inside the screen (`TabController` + `_activeTabIndex`).
- Pull-to-refresh calls `productsViewModel.refresh()`.

### `profile_screen.dart`
- Reads current user from `authViewModelProvider`.
- Shows decorated profile sections if user exists; otherwise empty state.
- Logout button calls `authViewModel.logout()` and pops back to first route.

## Mandatory explanation

### 1) How horizontal swipe was implemented
- Horizontal swipe is handled intentionally in `products_screen.dart` via a `GestureDetector` wrapped around the `CustomScrollView`.
- The logic accumulates drag distance in `onHorizontalDragUpdate`.
- On drag end, tab change is triggered only when intent is clear:
  - velocity threshold: `350.0`
  - distance threshold: `56.0`
- If threshold is met, `_tabController.animateTo(...)` switches to previous/next tab.
- Tab taps and swipe both use the same `TabController`, so behavior stays consistent.

### 2) Who owns vertical scroll and why
- The only vertical scroll owner in the products page is `CustomScrollView`.
- Header collapse, pinned tab bar, product grid, and refresh gesture all belong to that same scrollable.
- This prevents nested vertical scroll conflicts, jitter, and offset desync across tabs.
- Tab offsets are stored per tab and restored on tab switch using one shared `ScrollController`, so tab scroll position is preserved.

### 3) Trade-offs / limitations
- Offset restore is discrete (`jumpTo`) rather than animated.
- Horizontal gesture thresholds are tuned constants; they may need adjustment for different UX preferences.
- Since swipe is custom (not `TabBarView`), there is no partial page-drag animation between tabs, only discrete tab transitions.
- A full-screen horizontal gesture detector can conflict with future horizontally draggable child widgets unless gesture scope is narrowed.
