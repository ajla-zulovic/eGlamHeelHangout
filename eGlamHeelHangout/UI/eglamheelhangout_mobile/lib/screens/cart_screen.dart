import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/providers/cart_providers.dart';
import 'package:eglamheelhangout_mobile/providers/product_providers.dart';
import 'package:eglamheelhangout_mobile/models/cartitem.dart';
import 'package:eglamheelhangout_mobile/screens/product_details_screen.dart';
import 'package:eglamheelhangout_mobile/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.items;
    print("BUILD CartScreen: ${cartProvider.items.length} items");

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    onTap: () async {
                      final productProvider = context.read<ProductProvider>();
                      try {
                        final product = await productProvider.getById(item.productId);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to load product details: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    leading: item.image != null
                        ? Image.memory(base64Decode(item.image!))
                        : const Icon(Icons.image),
                    title: Text("${item.name} (size ${item.size})"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Price: \$${item.price.toStringAsFixed(2)}"),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: item.quantity > 1
                                  ? () => cartProvider.updateQuantity(index, item.quantity - 1)
                                  : null,
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: item.quantity < item.stockQuantity
                                  ? () => cartProvider.updateQuantity(index, item.quantity + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => cartProvider.removeItem(index),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total: \$${cartProvider.total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: cartItems.any((item) => item.stockQuantity > 0)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Checkout"),
            )
          ],
        ),
      ),
    );
  }
}
