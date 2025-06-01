import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/favorite_providers.dart';
import '../utils/utils.dart';
import 'product_details_screen.dart';

class MyFavoritesScreen extends StatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  List<Product> _favorites = [];
  bool _isLoading = true;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final provider = context.read<FavoriteProvider>();
      final favorites = await provider.getFavorites();

      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading favorites: ${e.toString()}")),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );

        if (updated == true) {
          _loadFavorites();
        }
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: product.image != null &&
                              product.image!.isNotEmpty &&
                              product.image!.length > 100
                          ? imageFromBase64String(product.image!)
                          : const Icon(Icons.image_not_supported, size: 50),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatNumber(product.price),
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(Icons.favorite, color: Colors.pink),
                onPressed: _isToggling
                    ? null
                    : () async {
                        setState(() => _isToggling = true);
                        try {
                          final result = await context
                              .read<FavoriteProvider>()
                              .toggle(product.productID!);
                          if (!result) _loadFavorites();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Error updating favorites: ${e.toString()}")),
                          );
                        } finally {
                          setState(() => _isToggling = false);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favorites.isEmpty) {
      return const Center(child: Text("You have no favorite products."));
    }

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: GridView.builder(
        itemCount: _favorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
        itemBuilder: (context, index) {
          if (index >= _favorites.length) {
            return const SizedBox(); // sigurnosna mjera
          }

          final product = _favorites[index];
          return _buildProductCard(product);
        },
      ),
    );
  }
}
