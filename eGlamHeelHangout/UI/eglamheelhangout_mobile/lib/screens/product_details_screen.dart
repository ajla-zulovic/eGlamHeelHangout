import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eglamheelhangout_mobile/models/product.dart';
import 'package:eglamheelhangout_mobile/providers/product_providers.dart';
import 'package:eglamheelhangout_mobile/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/models/productsize.dart';
import 'package:eglamheelhangout_mobile/models/review.dart';
import 'package:eglamheelhangout_mobile/providers/review_providers.dart';
import 'package:eglamheelhangout_mobile/providers/cart_providers.dart';
import 'package:eglamheelhangout_mobile/models/cartitem.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:eglamheelhangout_mobile/screens/cart_screen.dart';

import 'package:http/http.dart' as http;


class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductProvider _productProvider;
  late ReviewProvider _reviewProvider;
  List<ProductSize> _sizes = [];
  bool isLoading = true;
  double? averageRating;
  int? selectedSize;
  int quantity = 1;


  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _reviewProvider = context.read<ReviewProvider>();
    _loadSizes();
    _loadAverageRating();
  }

  Future<void> _loadSizes() async {
    final result = await _productProvider.getProductSizes(widget.product!.productID!);
    setState(() {
      _sizes = result;
      isLoading = false;
    });
  }

  Future<void> _loadAverageRating() async {
    try {
      final result = await _reviewProvider.fetchAverageRating(widget.product!.productID!);
      setState(() {
        averageRating = result;
      });
    } catch (e) {
      print('Failed to load average rating: $e');
    }
  }


void _addToCart() {
  if (selectedSize == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a size before adding to cart."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    final cartProvider = context.read<CartProvider>();

    final selectedProductSize = _sizes.firstWhere(
      (s) => s.size.toString() == selectedSize.toString(),
      orElse: () => throw Exception("Selected size not found"),
    );

    // Provjeri da li je već u korpi
    final alreadyInCart = cartProvider.items.any((item) =>
      item.productId == widget.product?.productID &&
      item.size == selectedSize);

    if (alreadyInCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This product (with selected size) is already in the cart."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Dodavanje nove stavke s provjerenom količinom
    if (selectedProductSize.stockQuantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("This product is out of stock for size $selectedSize."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    cartProvider.addItem(
      CartItem(
        productId: widget.product?.productID ?? 0,
        sizeId: selectedProductSize.productSizeId ?? 0,
        size: selectedSize!,
        name: widget.product?.name ?? "Unnamed",
        price: widget.product?.price ?? 0.0,
        image: widget.product?.image,
        quantity: 1,
        stockQuantity: selectedProductSize.stockQuantity,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item added to cart!"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print("Error in _addToCart: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unexpected error occurred while adding to cart."),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _showRatingDialog() {
    double selectedRating = 3.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rate this product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: selectedRating,
              minRating: 1,
              maxRating: 5,
              allowHalfRating: false,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                selectedRating = rating;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.black),
              overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)), 
            ),
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Submit"),
            onPressed: () async {
              try {
                await _reviewProvider.insert({
                  'productId': widget.product!.productID!,
                  'rating': selectedRating.toInt()
                });
                Navigator.of(context).pop();
                _loadAverageRating();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thank you for rating!"),backgroundColor: Colors.green,));
              } catch (e) {
                Navigator.of(context).pop();

                if (e is http.Response) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.body}")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }

            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = context.watch<CartProvider>();
print("DETAIL SCREEN: ${cartProvider.items.length} items");


    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? 'Product Details'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        actions: [
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
              ),
            ],
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
                Center(
                  child: ElevatedButton.icon(
                    onPressed:_addToCart,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Add to Cart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedSize == null ? Colors.grey : Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                if (selectedSize == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Please select a size before adding to cart.",
                  style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                ),
              ),
                  const SizedBox(height: 20),
                  Text(product?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(formatNumber(product?.price), style: const TextStyle(fontSize: 18, color: Colors.green)),
                  const SizedBox(height: 20),
                  if (product?.description != null)
                    Text(product!.description!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Material:${product?.material ?? ''}"),
                  Text("Color:${product?.color ?? ''}"),
                  if (product?.heelHeight != null) Text("Heel Height: ${product!.heelHeight} cm"),
                  const SizedBox(height: 30),
                  const Text("Available Sizes:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _sizes.map((size) {
                    final isAvailable = size.stockQuantity > 0;
                    final isSelected = selectedSize == size.size;

                    return InkWell(
                      onTap: isAvailable
                          ? () {
                              setState(() {
                                selectedSize = size.size;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? (isSelected ? Colors.black : Colors.white)
                              : Colors.grey.shade300,
                          border: Border.all(
                            color: isAvailable
                                ? Colors.black
                                : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${size.size}",
                          style: TextStyle(
                            color: isAvailable
                                ? (isSelected ? Colors.white : Colors.black)
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),


                  const SizedBox(height: 30),
                  if (averageRating != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Average Rating:", style: TextStyle(fontWeight: FontWeight.bold)),
                        RatingBarIndicator(
                          rating: averageRating!,
                          itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 24.0,
                          direction: Axis.horizontal,
                        ),
                        Text(averageRating!.toStringAsFixed(1)),
                      ],
                    ),
                  const SizedBox(height: 10),
                 Center(
                  child: OutlinedButton.icon(
                    onPressed: _showRatingDialog,
                    icon: const Icon(Icons.star_border, color: Colors.black),
                    label: const Text(
                      "Rate this product",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      backgroundColor: Colors.white,
                      shadowColor: Colors.grey.withOpacity(0.1),
                      elevation: 1,
                    ),
                  ),
                ),
                ],
              ),
            ),
    );
  }
}