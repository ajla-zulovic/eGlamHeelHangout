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
import 'package:eglamheelhangout_admin/providers/category_providers.dart';
import 'package:eglamheelhangout_admin/models/category.dart';
import 'package:eglamheelhangout_admin/screens/profile_screen.dart';
import 'package:eglamheelhangout_admin/screens/add_giveaway_screen.dart';
import '../models/order.dart';
import '../providers/order_providers.dart';
import 'package:eglamheelhangout_admin/screens/admin_orders_screen.dart';
import 'package:eglamheelhangout_admin/screens/manage_giveaways_screen.dart';


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
    {'page': const AddProductScreen(), 'title': 'Add Product'},
    {'page': const AdminOrdersScreen(), 'title': 'Manage Orders'},
    {'page': const GiveawaysManageScreen(), 'title': 'Manage Giveaways'},

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
        title: Text(_pages[selectedIndex]['title'],
        style: const TextStyle(color: Colors.white),),
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
            ListTile(leading: const Icon(Icons.home), title: const Text('Home Page'), onTap: () => _selectPage(0)),
            ListTile(leading: const Icon(Icons.person), title: const Text('Profile Page'), onTap: () => _selectPage(1)),
            ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Report Page'), onTap: () => _selectPage(2)),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Add Giveaway'),
            onTap: () => _selectPage(3),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add New Product'),
            onTap: () => _selectPage(4), 
          ),
          ListTile(leading: const Icon(Icons.assignment), title: const Text('Manage Orders'), onTap: () => _selectPage(5)),
           ListTile(leading: const Icon(Icons.assignment), title: const Text('Manage Giveaways'), onTap: () => _selectPage(6)),

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
  CategoryProvider? _categoryProvider;
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;



  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _fetchData();
     _fetchCategories();
  }


Future<void> _fetchCategories() async {
  final categoryResult = await _categoryProvider!.get();
  setState(() {
    _categories = categoryResult.result;
  });
}
Future<void> _fetchData() async {
  setState(() {
    _isLoading = true;
  });
  final filter = <String, dynamic>{};

  if (_selectedCategoryId != null) {
    filter['categoryId'] = _selectedCategoryId;
  }

  if (_ftsController.text.isNotEmpty) {
    filter['fts'] = _ftsController.text;
  }

  final data = await _productProvider.get(filter: filter);
  if (mounted) {
    setState(() {
      result = data;
      _isLoading = false;
    });
  }
}

  void _confirmDelete(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure about this action?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _productProvider.delete(product.productID!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,),
          );
          await _fetchData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
         if (_categories.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // ALL button
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategoryId = null;
                    _ftsController.clear();
                  });
                  _fetchData();
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: _selectedCategoryId == null ? Colors.black : Colors.white,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedCategoryId == null ? Colors.white : Colors.black,
                  ),
                ),
              ),
              ..._categories.map((category) {
                final isSelected = _selectedCategoryId == category.categoryID;
                return OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategoryId = isSelected ? null : category.categoryID;
                      _ftsController.clear();
                    });
                    _fetchData();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.black : Colors.white,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    category.categoryName ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ],
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
              _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
                setState(() {
                  _selectedCategoryId = null; 
                });

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
                      SnackBar(content: Text('Search error: ${e.toString()}')),
                    );
                  }
                }
              });
            }
            ),
          ),
          const SizedBox(height: 120),
          Expanded(
            child: GridView.builder(
              itemCount: result!.result.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
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
                      await _fetchData();
                    }
                  },
                  splashColor: Colors.transparent, 
                  highlightColor: Colors.transparent, 
                  hoverColor: Colors.transparent,
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: product.image != null && product.image!.isNotEmpty
                                      ? imageFromBase64String(product.image!)
                                      : const Icon(Icons.image_not_supported, size: 50),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.name ?? "",
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
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
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            tooltip: 'Delete product',
                            onPressed: () => _confirmDelete(context, product),
                          ),
                        ),
                      ],
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


class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Report Screen'));
  }
}
