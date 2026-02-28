# Products Feature Notes

This file documents the mandatory architecture decisions for the product listing screen.

## Structure
- Product screen widgets are separated under `lib/features/products/widgets/`.
- `screens/products_screen.dart` now handles coordination/state only.
- `widgets/products_tab_view.dart` renders per-tab slivers.
- `widgets/products_error_state.dart` renders retry/error UI.

## 1) How horizontal swipe was implemented
- Horizontal swipe is handled by `TabBarView` (native page swipe behavior).
- Tab tap and tab swipe are both driven by one shared `TabController`.

## 2) Who owns the vertical scroll and why
- `NestedScrollView` coordinates the collapsing header and the tab bodies.
- Shared header scroll is owned by the outer `NestedScrollView`.
- `SliverOverlapAbsorber` (outer) and `SliverOverlapInjector` (inner) keep sliver overlap behavior correct.
- Each tab body is a dedicated `CustomScrollView` with a unique `PageStorageKey`.
- `AutomaticKeepAliveClientMixin` keeps each tab subtree alive, preserving list state while switching tabs.
- Per-tab list offsets are preserved independently, so one tab list does not overwrite another.
- `RefreshIndicator` uses a custom notification predicate so refresh starts only from a user drag at the top.

## 3) Trade-offs or limitations
- `NestedScrollView` adds coordination complexity compared with one plain `CustomScrollView`.
- Per-tab scroll is restored by key-based scroll storage; behavior depends on stable keys.
- Header collapse state is shared by the nested scroll container, while per-tab body list offsets are preserved.
