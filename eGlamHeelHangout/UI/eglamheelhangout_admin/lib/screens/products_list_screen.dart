import 'dart:async';
import 'dart:convert';
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
import 'package:eglamheelhangout_admin/screens/report_screen.dart';
import 'package:eglamheelhangout_admin/screens/manage_users_screen.dart';
import 'package:eglamheelhangout_admin/screens/manage_categories_screen.dart';
import 'package:eglamheelhangout_admin/providers/discount_providers.dart';

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
    {'page': const ManageUsersScreen(), 'title': 'Manage Users'},
    {'page': const ManageCategoriesScreen(), 'title': 'Manage Categories'},

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
          ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home Page'),
              onTap: () => _selectPage(0)),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile Page'),
              onTap: () => _selectPage(1)),
          ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Report Page'),
              onTap: () => _selectPage(2)),
          ExpansionTile(
            leading: const Icon(Icons.add),
            title: const Text('Add'),
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Product'),
                onTap: () => _selectPage(4),
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard),
                title: const Text('Giveaway'),
                onTap: () => _selectPage(3),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Manage'),
            children: [
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Orders'),
                onTap: () => _selectPage(5),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Giveaways'),
                onTap: () => _selectPage(6),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Users'),
                onTap: () => _selectPage(7),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Categories'),
                onTap: () => _selectPage(8),
              ),
            ],
          ),
          
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
  List<Product> _products = [];
  bool _showDiscountsOnly = false;

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

Future<void> _loadDiscountedProducts() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final data = await _productProvider.getActiveDiscountedProducts(); 

    setState(() {
      result = SearchResult<Product>()
        ..result = data
        ..count = data.length;

      _isLoading = false;
    });
  } catch (e) {
    debugPrint("Error loading discounted products: $e");
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to load discounted products")),
    );
  }
}


Future<void> _fetchCategories() async {
 final categoryResult = await _categoryProvider!.get();
  setState(() {
    _categories = categoryResult.result.where((x) => x.isActive == true).toList();
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
              height: 180,
              width: 180,
            ),
          ),
          if (_categories.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategoryId = null;
                    _ftsController.clear();
                    _showDiscountsOnly = false; 
                  });
                  _fetchData();
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: (_selectedCategoryId == null && !_showDiscountsOnly) ? Colors.black : Colors.white,
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
                    color: (_selectedCategoryId == null && !_showDiscountsOnly) ? Colors.white : Colors.black,

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
                      _showDiscountsOnly = false; 
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
              OutlinedButton.icon(
               onPressed: () async {
                setState(() {
                  _selectedCategoryId = null;
                  _ftsController.clear();
                  _showDiscountsOnly = true; // SET
                });
                await _loadDiscountedProducts();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: _showDiscountsOnly ? Colors.red : Colors.red[50],
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: Icon(Icons.local_offer, color: _showDiscountsOnly ? Colors.white : Colors.red),
              label: Text(
                "Discounts",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _showDiscountsOnly ? Colors.white : Colors.red,
                ),
              ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 700,
            height:40,
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
          const SizedBox(height: 90),
          Expanded(
            child: result == null
            ? const SizedBox.shrink()
            : result!.result.isEmpty
                ? const Center(
                    child: Text(
                      'No products found for your search.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  )
          :  GridView.builder(
              itemCount: result!.result.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
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
                             SizedBox(
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: product.image != null
                                    ? Image.memory(
                                        base64Decode(product.image!),
                                        fit: BoxFit.contain,
                                      )
                                    : const Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),


                              const SizedBox(height: 4),
                              Text(
                                product.name ?? "",
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              if (product.discountedPrice != null && product.discountedPrice! > 0 && product.discountPercentage != null && product.discountPercentage! > 0)
                                Column(
                                  children: [
                                    Text(
                                      formatNumber(product.price),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatNumber(product.discountedPrice),
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '(${product.discountPercentage!.toStringAsFixed(0)}% OFF)',
                                      style: const TextStyle(color: Colors.green, fontSize: 12),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  formatNumber(product.price),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          )

                          ),
                        ),
                        Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _confirmDelete(context, product),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.delete_forever, color: Colors.red[300], size: 20),
                            ),
                          ),
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
