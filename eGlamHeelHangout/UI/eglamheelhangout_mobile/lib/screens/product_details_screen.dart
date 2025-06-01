import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eglamheelhangout_mobile/models/product.dart';
import 'package:eglamheelhangout_mobile/providers/product_providers.dart';
import 'package:eglamheelhangout_mobile/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/models/productsize.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductProvider _productProvider;
  List<ProductSize> _sizes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _loadSizes();
  }

  Future<void> _loadSizes() async {
    final result = await _productProvider.getProductSizes(widget.product!.productID!);
    setState(() {
      _sizes = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? 'Product Details'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white, 
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product?.image != null && product!.image!.isNotEmpty)
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade500),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: imageFromBase64String(product.image!),
                    ),
                  const SizedBox(height: 20),
                  Text(product?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(formatNumber(product?.price), style: const TextStyle(fontSize: 18, color: Colors.green)),
                  const SizedBox(height: 20),
                  if (product?.description != null)
                    Text(product!.description!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Material: ${product?.material ?? ''}"),
                  Text("Color: ${product?.color ?? ''}"),
                  if (product?.heelHeight != null) Text("Heel Height: ${product!.heelHeight} cm"),
                  const SizedBox(height: 30),
                  const Text("Available Sizes:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _sizes.map((size) {
                      final isAvailable = size.stockQuantity > 0;
                      return ElevatedButton(
                        onPressed: isAvailable ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? Colors.black : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: Text("${size.size}"),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
    );
  }
}
