import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eglamheelhangout_admin/providers/product_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_admin/main.dart';
import 'package:eglamheelhangout_admin/models/search_result.dart';
import 'package:eglamheelhangout_admin/models/product.dart';
import 'package:eglamheelhangout_admin/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:eglamheelhangout_admin/screens/product_details_screen.dart'; 
import 'package:eglamheelhangout_admin/screens/add_product_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  int selectedIndex = 0;
  late ProductProvider _productProvider;

  final List<Map<String, dynamic>> _pages = [
    {'page':  HomeScreen(), 'title': 'Home Page'},
    {'page': const ProfileScreen(), 'title': 'Profile Page'},
    {'page': const ReportScreen(), 'title': 'Report Page'},
    {'page': const AddGiveawayScreen(), 'title': 'Add Giveaway'},
  ];

  void _selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[selectedIndex]['title']),
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                await _productProvider.get();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Products refreshed')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Colors.grey[800]),
        child: const Text(
          'Menu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text('Home Page'),
        onTap: () => _selectPage(0),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Profile Page'),
        onTap: () => _selectPage(1),
      ),
      ListTile(
        leading: const Icon(Icons.bar_chart),
        title: const Text('Report Page'),
        onTap: () => _selectPage(2),
      ),
      ListTile(
        leading: const Icon(Icons.card_giftcard),
        title: const Text('Add Giveaway'),
        onTap: () => _selectPage(3),
      ),
     
      ListTile(
       leading: const Icon(Icons.add_circle_outline),
        title: const Text('Add New Product'),
        onTap: () async {
           Navigator.of(context).pop(); 
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );

          if (result == true && mounted) {
            setState(() {
              selectedIndex = 0;
              _pages[0]['page'] = HomeScreen();
            });
          }
          },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    ],
  ),
),
      body: _pages[selectedIndex]['page'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  SearchResult<Product>? result;
  final TextEditingController _ftsController = TextEditingController();
  Timer? _debounceTimer;
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchData(); // automatski povlači podatke kada se HomeScreen obnovi
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _fetchData();
  }

  Future<void> _fetchData() async {
    var data = await _productProvider.get();
    setState(() {
      result = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              "assets/images/logologo.png",
              height: 150,
              width: 150,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 700,
            child: TextField(
              controller: _ftsController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onChanged: (value) {
                if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
                _debounceTimer =
                    Timer(const Duration(milliseconds: 500), () async {
                  if (_ftsController.text.isEmpty) {
                    await _fetchData();
                    return;
                  }
                  try {
                    var data = await _productProvider.get(filter: {
                      'fts': _ftsController.text,
                    });
                    if (mounted) {
                      setState(() {
                        result = data;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Search error: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: result!.result.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 2,
              ),
              itemBuilder: (context, index) {
                final product = result!.result[index];
                return InkWell(
                  onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(product: product),
                    ),
                  );

                  if (updated == true) {
                    await _fetchData(); // ponovo povuci podatke
                  }
                },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: product.image != null && product.image!.isNotEmpty
                                ? imageFromBase64String(product.image!)
                                : const Icon(Icons.image_not_supported, size: 50),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatNumber(product.price),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen'));
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Report Screen'));
  }
}

class AddGiveawayScreen extends StatelessWidget {
  const AddGiveawayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Giveaway Screen'));
  }
}