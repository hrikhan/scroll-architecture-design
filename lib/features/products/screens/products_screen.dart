import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/utils/refresh_notification_predicate.dart';
import '../../../widgets/banner_header.dart';
import '../../../widgets/pinned_tabbar.dart';
import '../../auth/screens/profile_screen.dart';
import '../viewmodels/products_viewmodel.dart';
import '../widgets/widgets.dart';

const _kHomeScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: ClampingScrollPhysics(),
);

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AppConstants.productTabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productsViewModelProvider);
    final productsByTab = {
      for (final tab in ProductsTab.values)
        tab: ref.watch(productsByTabProvider(tab)),
    };

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
        child: NestedScrollView(
          physics: _kHomeScrollPhysics,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  expandedHeight: AppConstants.bannerExpandedHeight,
                  pinned: true,
                  elevation: 0,
                  forceElevated: innerBoxIsScrolled,
                  backgroundColor: const Color(0xFFF57224),
                  title: const Text('ZaviSoft Store'),
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
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedTabBar(tabBar: tabBar),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              for (final tab in ProductsTab.values)
                ProductsTabView(
                  tab: tab,
                  asyncProducts: asyncProducts,
                  products: productsByTab[tab]!,
                  onRetry: () {
                    ref.read(productsViewModelProvider.notifier).refresh();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
