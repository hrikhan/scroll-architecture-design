import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/utils/refresh_notification_predicate.dart';
import '../../auth/screens/profile_screen.dart';
import '../domain/product_model.dart';
import '../viewmodels/products_viewmodel.dart';
import '../../../widgets/banner_header.dart';
import '../../../widgets/pinned_tabbar.dart';
import '../../../widgets/product_card.dart';

const _kHomeScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: ClampingScrollPhysics(),
);
const _kTabSwipeVelocityThreshold = 350.0;
const _kTabSwipeDistanceThreshold = 56.0;
const _kGridCrossAxisCount = 2;
const _kGridSpacing = 12.0;
const _kGridChildAspectRatio = 0.72;
const _kGridHorizontalPadding = 24.0;

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final Map<ProductsTab, ScrollController> _tabScrollControllers;
  double _horizontalDragDistance = 0;
  int _activeTabIndex = 0;

  ProductsTab get _activeTab => ProductsTab.values[_activeTabIndex];
  ScrollController get _activeScrollController =>
      _tabScrollControllers[_activeTab]!;

  @override
  void initState() {
    super.initState();
    _tabScrollControllers = {
      for (final tab in ProductsTab.values) tab: ScrollController(),
    };
    _tabController = TabController(
      length: AppConstants.productTabs.length,
      vsync: this,
    )..addListener(_syncActiveTab);
  }

  @override
  void dispose() {
    for (final controller in _tabScrollControllers.values) {
      controller.dispose();
    }
    _tabController
      ..removeListener(_syncActiveTab)
      ..dispose();
    super.dispose();
  }

  void _syncActiveTab() {
    if (_activeTabIndex == _tabController.index || !mounted) {
      return;
    }
    setState(() {
      _activeTabIndex = _tabController.index;
    });
  }

  void _onHorizontalDragStart(DragStartDetails _) {
    _horizontalDragDistance = 0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.delta.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final hasVelocityIntent = velocity.abs() >= _kTabSwipeVelocityThreshold;
    final hasDistanceIntent =
        _horizontalDragDistance.abs() >= _kTabSwipeDistanceThreshold;

    if (!hasVelocityIntent && !hasDistanceIntent) {
      return;
    }

    final moveToNextTab = hasVelocityIntent
        ? velocity < 0
        : _horizontalDragDistance < 0;
    _switchTab(moveToNextTab ? 1 : -1);
  }

  void _switchTab(int delta) {
    final targetIndex = (_tabController.index + delta).clamp(
      0,
      _tabController.length - 1,
    );
    if (targetIndex == _tabController.index) {
      return;
    }
    _tabController.animateTo(targetIndex);
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productsViewModelProvider);
    final products = ref.watch(productsByTabProvider(_activeTab));
    final maxTabProductCount = ProductsTab.values
        .map((tab) => ref.watch(productsByTabProvider(tab)).length)
        .fold<int>(0, (maxCount, count) => count > maxCount ? count : maxCount);

    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: false,
      tabs: AppConstants.productTabs
          .map((label) => Tab(text: label))
          .toList(growable: false),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(productsViewModelProvider.notifier).refresh(),
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        notificationPredicate: shouldHandlePullToRefresh,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: CustomScrollView(
            controller: _activeScrollController,
            physics: _kHomeScrollPhysics,
            slivers: [
              SliverAppBar(
                expandedHeight: AppConstants.bannerExpandedHeight,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFF57224),
                title: const Text('FakeStore'),
                actions: [
                  IconButton(
                    tooltip: 'Profile',
                    icon: const Icon(Icons.person_outline),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
                flexibleSpace: const FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: BannerHeader(),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedTabBar(tabBar: tabBar),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ..._buildBodySlivers(asyncProducts, products, maxTabProductCount),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBodySlivers(
    AsyncValue<List<Product>> asyncProducts,
    List<Product> products,
    int maxTabProductCount,
  ) {
    final hasInitialData = asyncProducts.hasValue;
    if (asyncProducts.isLoading && !hasInitialData) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (asyncProducts.hasError && !hasInitialData) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ErrorState(
            message: asyncProducts.error.toString(),
            onRetry: () {
              ref.read(productsViewModelProvider.notifier).refresh();
            },
          ),
        ),
      ];
    }

    if (products.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('No products found in this tab.')),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ProductCard(product: products[index]);
          }, childCount: products.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _kGridCrossAxisCount,
            crossAxisSpacing: _kGridSpacing,
            mainAxisSpacing: _kGridSpacing,
            childAspectRatio: _kGridChildAspectRatio,
          ),
        ),
      ),
      if (maxTabProductCount > products.length)
        SliverToBoxAdapter(
          child: SizedBox(
            height: _extraScrollSpaceForShortTab(
              context,
              currentCount: products.length,
              maxCount: maxTabProductCount,
            ),
          ),
        ),
    ];
  }

  double _extraScrollSpaceForShortTab(
    BuildContext context, {
    required int currentCount,
    required int maxCount,
  }) {
    if (maxCount <= currentCount) {
      return 0;
    }

    final currentRows =
        (currentCount + _kGridCrossAxisCount - 1) ~/ _kGridCrossAxisCount;
    final maxRows =
        (maxCount + _kGridCrossAxisCount - 1) ~/ _kGridCrossAxisCount;
    final extraRows = maxRows - currentRows;
    if (extraRows <= 0) {
      return 0;
    }

    final viewportWidth = MediaQuery.sizeOf(context).width;
    final tileWidth =
        (viewportWidth - _kGridHorizontalPadding - _kGridSpacing) /
        _kGridCrossAxisCount;
    final tileHeight = tileWidth / _kGridChildAspectRatio;
    return extraRows * (tileHeight + _kGridSpacing);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load products'),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
