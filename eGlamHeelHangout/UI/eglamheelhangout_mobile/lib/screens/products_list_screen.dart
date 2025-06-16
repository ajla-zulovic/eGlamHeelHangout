import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eglamheelhangout_mobile/providers/product_providers.dart';
import 'package:eglamheelhangout_mobile/providers/base_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/main.dart';
import 'package:eglamheelhangout_mobile/models/search_result.dart';
import 'package:eglamheelhangout_mobile/models/product.dart';
import 'package:eglamheelhangout_mobile/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:eglamheelhangout_mobile/screens/product_details_screen.dart';
import 'package:eglamheelhangout_mobile/providers/category_providers.dart';
import 'package:eglamheelhangout_mobile/models/category.dart';
import 'package:eglamheelhangout_mobile/models/cartitem.dart';
import 'package:eglamheelhangout_mobile/screens/profile_screen.dart';
import 'package:eglamheelhangout_mobile/providers/favorite_providers.dart';
import 'package:eglamheelhangout_mobile/providers/cart_providers.dart';
import 'package:eglamheelhangout_mobile/providers/giveaway_providers.dart';
import 'package:eglamheelhangout_mobile/screens/favorite_product_screen.dart';
import 'package:eglamheelhangout_mobile/screens/cart_screen.dart';
import 'package:eglamheelhangout_mobile/screens/user_orders_list_screen.dart';
import 'package:eglamheelhangout_mobile/screens/giveaway_participant_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eglamheelhangout_mobile/models/giveaway.dart';
import 'package:signalr_core/signalr_core.dart';


class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  int selectedIndex = 0;
  late ProductProvider _productProvider;

  final List<Map<String, dynamic>> _pages = [
    {'page': const HomeScreen(), 'title': 'Home Page'},
    {'page': const ProfileScreen(), 'title': 'Profile Page'},
    {'page': const MyFavoritesScreen(), 'title': 'My Favorites'},
    {'page': const UserOrdersListScreen(), 'title': 'History Orders List'},
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
    context.read<FavoriteProvider>().getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[selectedIndex]['title'], style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[800],
        actions: 
      [
         Padding(
           padding: const EdgeInsets.only(right: 18), 
           child:IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
                },
            ),
         ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey[800]),
              child: const Text('Menu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
                leading: const Icon(Icons.favorite),
                title: const Text('My Favorites'),
                onTap: () => _selectPage(2)),
                 ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('History Orders List'),
                onTap: () => _selectPage(3)),
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
  late CategoryProvider _categoryProvider;
  SearchResult<Product>? result;
  final TextEditingController _ftsController = TextEditingController();
  Timer? _debounceTimer;
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isCategoryLoading = false;
  late HubConnection _hubConnection;
  late final String signalrUrl;


  @override
  void initState() {
    super.initState();
    signalrUrl = const String.fromEnvironment("SIGNALR_URL", defaultValue: "http://localhost:7277/giveawayHub");
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _initialize();
    _initializeSignalR(); 
  }

Future<void> _initializeSignalR() async {
_hubConnection = HubConnectionBuilder()
    .withUrl(signalrUrl)
    .build();

  _hubConnection.on("ReceiveGiveaway", (arguments) {
    final data = arguments?.first;
    if (data != null) {
        print("Deserializing giveaway...");
      final giveaway = Giveaway.fromJson(Map<String, dynamic>.from(data));
      _showGiveawayDialog(giveaway);
    }
  });

  _hubConnection.on("ReceiveWinner", (arguments) {
    print("Received 'ReceiveWinner' event");
    final data = arguments?.first;
    if (data != null) {
      final winner = data["winnerUsername"];
      final giveawayTitle = data["giveawayTitle"];
      _showWinnerDialog(winner, giveawayTitle);
    }
  });

   try {
    await _hubConnection.start();
    print("SignalR connected to: $signalrUrl");
  } catch (e) {
    print("SignalR failed to connect: $e");
  }
}

void _showGiveawayDialog(Giveaway giveaway) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("New Giveaway!"),
      content: Text("Would you like to participate in ${giveaway.title}?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GiveawayParticipationScreen(giveaway: giveaway),
              ),
            );
          },
          child: Text("Yes"),
        ),
      ],
    ),
  );
}

void _showWinnerDialog(String winner, String giveawayTitle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Giveaway Winner!"),
      content: Text("$winner won the giveaway: $giveawayTitle"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Close"),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _hubConnection.stop();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await context.read<FavoriteProvider>().refreshFavorites();
      await _fetchCategories();
      await _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchCategories() async {
    final categoryResult = await _categoryProvider.get();
    if (mounted) {
      setState(() {
        _categories = categoryResult.result;
      });
    }
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isCategoryLoading = true);
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
          _isCategoryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCategoryLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    }
  }

  Widget _buildProductShimmer() {
    return GridView.builder(
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
          ),
        );
      },
    );
  }

  VoidCallback _handleCategoryChange(int? categoryId) {
    return () {
      setState(() {
        _selectedCategoryId = _selectedCategoryId == categoryId ? null : categoryId;
        _ftsController.clear();
      });
      _fetchData();
    };
  }

  Widget _buildFilterButton(int? id, String label) {
    final isSelected = _selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 120),
        child: OutlinedButton(
          onPressed: _handleCategoryChange(id),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.black : Colors.white,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading && result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.asset("assets/images/logologo.png", height: 120),
          ),
          const SizedBox(height: 20),
         Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 15,
            children: [
              _buildFilterButton(null, 'All'),
              ..._categories.map((cat) => _buildFilterButton(cat.categoryID, cat.categoryName ?? '')),
            ],
          ),
        ),

          const SizedBox(height: 18),
          TextField(
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
                setState(() => _selectedCategoryId = null);
                if (_ftsController.text.isEmpty) {
                  await _fetchData();
                  return;
                }
                try {
                  var data = await _productProvider.get(filter: {'fts': _ftsController.text});
                  if (mounted) setState(() => result = data);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Search error: $e')),
                    );
                  }
                }
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isCategoryLoading
                ? _buildProductShimmer()
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: result?.result.length ?? 0,
                    itemBuilder: (context, index) {
                      final product = result!.result[index];
                      final isFavorite = favoriteProvider.isFavorite(product.productID!);
                      return GestureDetector(
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                          if (updated == true) await _fetchData();
                        },
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: product.image != null && product.image!.isNotEmpty
                                          ? imageFromBase64String(product.image!)
                                          : const Icon(Icons.image_not_supported, size: 50),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.name ?? '',
                                      style: const TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatNumber(product.price),
                                      style: const TextStyle(color: Colors.green, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.pink,
                                  ),
                                  onPressed: () async {
                                    try {
                                      final liked = await favoriteProvider.toggle(product.productID!);
                                      setState(() => product.isFavorite = liked);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  },
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
