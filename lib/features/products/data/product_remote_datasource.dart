import '../../../core/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Product>> fetchProducts() async {
    final response = await _apiClient.get(ApiConstants.productsEndpoint);

    if (response is! List) {
      throw ApiException(statusCode: 500, message: 'Invalid products response');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList(growable: false);
  }
}
