import 'package:flutter/material.dart';

class PinnedTabBar extends SliverPersistentHeaderDelegate {
  PinnedTabBar({required TabBar tabBar}) : _tabBar = tabBar;

  final TabBar _tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: overlapsContent
            ? const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant PinnedTabBar oldDelegate) {
    return oldDelegate._tabBar != _tabBar;
  }
}
