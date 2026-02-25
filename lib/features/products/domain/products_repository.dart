import 'product_model.dart';

abstract class ProductsRepository {
  Future<List<Product>> fetchProducts();
}
