import '../domain/product_model.dart';
import '../domain/products_repository.dart';
import 'product_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> fetchProducts() => _remoteDataSource.fetchProducts();
}
