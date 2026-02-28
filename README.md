# Run Instruction

`flutter run`


# Scroll Architecture - Explanation

## 1) How horizontal swipe was implemented?
Horizontal swipe is implemented by `TabBarView` in `products_screen.dart`.
- In `initState`, a single `_tabController` is created with `SingleTickerProviderStateMixin`.
- The same controller is passed to both `TabBar` and `TabBarView`.
- Because both widgets share one controller, two-way sync is automatic:
  - tapping a tab changes the page
  - swiping the page changes the selected tab
- This avoids manual listeners or duplicate state for tab index.

## 2) Who owns the vertical scroll and why?
`NestedScrollView` is the vertical scroll owner.
- Outer layer (`headerSliverBuilder`) owns the shared header: `SliverAppBar` with `FlexibleSpaceBar` + pinned `TabBar`.
- Inner layer (each tab) is a `CustomScrollView` in `ProductsTabView`.
- `SliverOverlapAbsorber` (outer) + `SliverOverlapInjector` (inner) connect both layers so content starts at the correct offset under the app bar.
- Each tab has its own `PageStorageKey` and uses `AutomaticKeepAliveClientMixin`, so tab body positions are restored independently.
- This design is used because it gives one shared collapsing header while preserving per-tab list state.

## 3) Trade-offs or limitations of this approach?
Main trade-offs:
- More complexity than a single `CustomScrollView`; nested sliver coordination is harder to reason about.
- `SliverOverlapAbsorber/Injector` must stay correctly paired; otherwise you can get overlap gaps or jumpy layout.
- State preservation depends on stable keys (`PageStorageKey`) and keep-alive behavior.
- Memory usage is slightly higher because inactive tab trees remain alive (`AutomaticKeepAliveClientMixin`).
- Header collapse is shared globally by `NestedScrollView`; it is not independent per tab.
