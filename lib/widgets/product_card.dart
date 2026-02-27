import 'package:flutter/material.dart';

import '../features/products/domain/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageCacheSize = ((screenWidth / 2) * devicePixelRatio).round();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height:
                  MediaQuery.sizeOf(context).width / 2 * 0.72 -
                  16, // Adjusted for padding
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                cacheWidth: imageCacheSize,
                cacheHeight: imageCacheSize,
                filterQuality: FilterQuality.low,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${product.ratingRate} (${product.ratingCount})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFFF57224),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
