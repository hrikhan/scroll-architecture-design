# Products Feature Notes

This file documents the mandatory architecture decisions for the product listing screen.

## 1) How horizontal swipe was implemented
- Horizontal swipe is handled in `products_screen.dart` with a `GestureDetector` around the page body.
- Drag delta is accumulated during `onHorizontalDragUpdate`.
- On `onHorizontalDragEnd`, a tab switch is triggered only if swipe intent passes threshold checks:
  - velocity threshold: `350.0`
  - distance threshold: `56.0`
- Tab changes are applied through `_tabController.animateTo(...)`.
- Tap on `TabBar` and horizontal swipe both use the same `TabController`.

## 2) Who owns the vertical scroll and why
- A single `CustomScrollView` is the only vertical scroll owner in the products screen.
- `SliverAppBar` (collapsible header), pinned tab bar, and product list/grid all live in that same scroll tree.
- `RefreshIndicator` is attached to this same vertical scroll stream.
- Per-tab offsets are stored/restored with one shared `ScrollController`, so switching tabs keeps each tab's last vertical position.
- Single ownership avoids nested-scroll conflicts and scroll jitter.

## 3) Trade-offs or limitations
- Offset restore uses `jumpTo`, so tab switch is a discrete reposition (not animated).
- Custom swipe thresholds are tuned constants and may need UX tuning on some devices.
- This approach does not provide `TabBarView`-style partial drag animation between tabs.
- A full-screen horizontal gesture detector can conflict with future horizontally draggable child widgets unless scoped tighter.
