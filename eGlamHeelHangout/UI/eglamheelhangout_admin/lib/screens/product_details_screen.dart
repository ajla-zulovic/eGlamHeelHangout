import 'package:flutter/material.dart';
import 'package:eglamheelhangout_admin/models/product.dart';
import 'package:eglamheelhangout_admin/utils/utils.dart';
import 'package:eglamheelhangout_admin/providers/product_providers.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name ?? 'Product Details'),
        backgroundColor: Colors.grey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              Container(
                height: 300,
                width: double.infinity,
                alignment: Alignment.center,
                child: Image.network(
                  '${productProvider.baseUrl}/${product.imageUrl!}',
                  fit: BoxFit.contain,
                  headers: const {
                    "Accept": "image/*",
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Image load error: $error');
                    return const Icon(Icons.broken_image, size: 80);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 80),
              ),
            const SizedBox(height: 20),
            Text(
              product.name ?? 'No name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: ${formatNumber(product.price ?? 0)} KM',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              product.description ?? 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}