import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../auth/screens/profile_screen.dart';
import '../domain/product_model.dart';
import '../viewmodels/products_viewmodel.dart';
import '../../../widgets/banner_header.dart';
import '../../../widgets/pinned_tabbar.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBar = TabBar(
      isScrollable: false,
      tabs: AppConstants.productTabs
          .map((label) => Tab(text: label))
          .toList(growable: false),
    );

    return DefaultTabController(
      length: AppConstants.productTabs.length,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => ref.read(productsViewModelProvider.notifier).refresh(),
          notificationPredicate: (notification) {
            return notification.metrics.axis == Axis.vertical;
          },
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
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
              ];
            },
            body: const TabBarView(
              children: [
                _ProductsTabView(tab: ProductsTab.all, storageKey: 'products-all'),
                _ProductsTabView(tab: ProductsTab.men, storageKey: 'products-men'),
                _ProductsTabView(tab: ProductsTab.women, storageKey: 'products-women'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductsTabView extends ConsumerStatefulWidget {
  const _ProductsTabView({
    required this.tab,
    required this.storageKey,
  });

  final ProductsTab tab;
  final String storageKey;

  @override
  ConsumerState<_ProductsTabView> createState() => _ProductsTabViewState();
}

class _ProductsTabViewState extends ConsumerState<_ProductsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final asyncProducts = ref.watch(productsViewModelProvider);
    final products = ref.watch(productsByTabProvider(widget.tab));
    final hasInitialData = asyncProducts.hasValue;

    return CustomScrollView(
      key: PageStorageKey(widget.storageKey),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (asyncProducts.isLoading && !hasInitialData)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (asyncProducts.hasError && !hasInitialData)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorState(
              message: asyncProducts.error.toString(),
              onRetry: () {
                ref.read(productsViewModelProvider.notifier).refresh();
              },
            ),
          )
        else if (products.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No products found in this tab.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(product: products[index]),
                ),
                childCount: products.length,
              ),
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              color: Colors.white,
              alignment: Alignment.center,
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFF57224),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${product.ratingRate} (${product.ratingCount})'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
