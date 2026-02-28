import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/product_card.dart';
import '../domain/product_model.dart';
import '../viewmodels/products_viewmodel.dart';
import 'products_error_state.dart';

const _kHomeScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: ClampingScrollPhysics(),
);
const _kGridCrossAxisCount = 2;
const _kGridSpacing = 12.0;
const _kGridChildAspectRatio = 0.72;

class ProductsTabView extends StatefulWidget {
  const ProductsTabView({
    super.key,
    required this.tab,
    required this.asyncProducts,
    required this.products,
    required this.onRetry,
  });

  final ProductsTab tab;
  final AsyncValue<List<Product>> asyncProducts;
  final List<Product> products;
  final VoidCallback onRetry;

  @override
  State<ProductsTabView> createState() => _ProductsTabViewState();
}

class _ProductsTabViewState extends State<ProductsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      key: PageStorageKey<String>('products-tab-${widget.tab.name}'),
      physics: _kHomeScrollPhysics,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ..._buildBodySlivers(
          asyncProducts: widget.asyncProducts,
          products: widget.products,
          onRetry: widget.onRetry,
        ),
      ],
    );
  }

  List<Widget> _buildBodySlivers({
    required AsyncValue<List<Product>> asyncProducts,
    required List<Product> products,
    required VoidCallback onRetry,
  }) {
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
          child: ProductsErrorState(
            message: asyncProducts.error.toString(),
            onRetry: onRetry,
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
    ];
  }
}
