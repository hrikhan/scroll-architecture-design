import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/network/api_client.dart';
import '../data/product_remote_datasource.dart';
import '../data/products_repository_impl.dart';
import '../domain/product_model.dart';
import '../domain/products_repository.dart';

enum ProductsTab {
  all,
  men,
  women,
}

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDataSource(apiClient);
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductsRepositoryImpl(remoteDataSource);
});

final productsViewModelProvider =
    AsyncNotifierProvider<ProductsViewModel, List<Product>>(ProductsViewModel.new);

final productsByTabProvider = Provider.family<List<Product>, ProductsTab>((ref, tab) {
  final asyncProducts = ref.watch(productsViewModelProvider);
  final products = asyncProducts.value ?? const <Product>[];

  switch (tab) {
    case ProductsTab.all:
      return products;
    case ProductsTab.men:
      return products
          .where((p) => AppConstants.menCategories.contains(p.category))
          .toList(growable: false);
    case ProductsTab.women:
      return products
          .where((p) => AppConstants.womenCategories.contains(p.category))
          .toList(growable: false);
  }
});

class ProductsViewModel extends AsyncNotifier<List<Product>> {
  ProductsRepository get _repository => ref.read(productsRepositoryProvider);

  @override
  Future<List<Product>> build() => _repository.fetchProducts();

  Future<void> refresh() async {
    try {
      final products = await _repository.fetchProducts();
      state = AsyncData(products);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
