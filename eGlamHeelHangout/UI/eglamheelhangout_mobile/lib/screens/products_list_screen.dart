import 'dart:async';
import 'dart:convert';
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
import 'package:eglamheelhangout_mobile/screens/active_giveaway_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eglamheelhangout_mobile/models/giveaway.dart';
import 'package:eglamheelhangout_mobile/models/discount.dart';
import 'package:eglamheelhangout_mobile/providers/discount_providers.dart';
import 'package:eglamheelhangout_mobile/models/giveawaydto.dart';
import 'package:eglamheelhangout_mobile/models/notifications.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:eglamheelhangout_mobile/providers/notifications_providers.dart';
import 'package:eglamheelhangout_mobile/screens/unread_notif_screen.dart';
import 'package:badges/badges.dart' as badges;



class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen>with RouteAware {
  int selectedIndex = 0;
  late ProductProvider _productProvider;

  final List<Map<String, dynamic>> _pages = [
    {'page': const HomeScreen(), 'title': 'Home '},
    {'page': const ProfileScreen(), 'title': 'Profile'},
    {'page': const MyFavoritesScreen(), 'title': 'My Favorites'},
    {'page': const UserOrdersListScreen(), 'title': 'History Orders'},
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
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[selectedIndex]['title'], style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[800],
       actions: [

  IconButton(
    icon: const Icon(Icons.card_giftcard, color: Colors.white),
    tooltip: 'Giveaways',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ActiveGiveawaysScreen()),
      );
    },
  ),
  
  IconButton(
    icon: const Icon(Icons.shopping_cart, color: Colors.white),
    tooltip: 'Cart',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
      );
    },
  ),Consumer<NotificationProvider>(
  builder: (context, notifProvider, _) {
    final unreadCount = notifProvider.unreadCount;

    return badges.Badge(
      showBadge: unreadCount > 0,
      badgeContent: Text(
        unreadCount.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      position: badges.BadgePosition.topEnd(top: 0, end: 4),
      badgeStyle: const badges.BadgeStyle(
        badgeColor: Colors.red,
        elevation: 0,
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications, color: Colors.white),
        tooltip: 'Notifications',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationListScreen()),
          );
          await context.read<NotificationProvider>().refreshUnreadCount(); 
        },
      ),
    );
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
              child: const Text('Menu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => _selectPage(0)),
            ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () => _selectPage(1)),
            ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('My Favorites'),
                onTap: () => _selectPage(2)),
                 ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('History Orders'),
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

class _HomeScreenState extends State<HomeScreen> with RouteAware{
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
  late BuildContext dialogContext;
  bool _hubConnectionStarted = false;
  List<Product>? _recommendedProducts;
  bool _isLoadingRecommendations = true;
  bool _showRecommendations = true;



  @override
  void initState() {
    super.initState();
    signalrUrl = const String.fromEnvironment("SIGNALR_URL", defaultValue: "http://localhost:7277/giveawayHub");
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _initialize();
    _initializeSignalR(); 
     WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<NotificationProvider>().refreshUnreadCount();
  });
  }
Future<void> _initializeSignalR() async {
  _hubConnection = HubConnectionBuilder()
      .withUrl(
        signalrUrl,
        HttpConnectionOptions(
          transport: HttpTransportType.webSockets,
          skipNegotiation: true,
        ),
      )
      .build();

  _hubConnection.on("ReceiveGiveaway", (arguments) {
    print("ReceiveGiveaway event triggered");
    context.read<NotificationProvider>().refreshUnreadCount();
    final data = arguments?.first;
    if (data != null) {
      print("Data: ${data.toString()}");

      try {
        final giveaway = GiveawayNotification.fromJson(Map<String, dynamic>.from(data));
        print("MAPIRANJE ?...");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            print("Prikazujem dialog...");
            _showGiveawayDialog(giveaway);
          }
        });
      } catch (e, stackTrace) {
        print(" Greška prilikom mapiranja giveaway objekta: $e");
        print(" StackTrace: $stackTrace");
      }
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

_hubConnection.on("ReceiveProduct", (arguments) {
  print(" [SignalR] ReceiveProduct event triggered");
  context.read<NotificationProvider>().refreshUnreadCount();
  final data = arguments?.first;
  if (data != null) {
    print(" RAW PRODUCT DATA: $data");

    final notificationId = data['notificationId'];
    final productId = data['productId'];
    final productName = data['name'];
    final message = data['message'];

    print("Parsed -> productId: $productId, name: $productName, message: $message");

    _fetchData();

    if (context.mounted) {
      print(" Calling _showProductDialog...");
      _showProductDialog(
        productName ?? "Unknown product",
        notificationId: notificationId,
        productId: productId,
      );
    }
  }
});

_hubConnection.on("ReceiveDiscount", (arguments) {
  print("ReceiveDiscount event triggered");
  context.read<NotificationProvider>().refreshUnreadCount();
  final data = arguments?.first;
  if (data != null) {
    final notificationId = data['notificationId'];
    final productId = data['productId'];
    final message = data['message'];

    _fetchData(); 
    if (context.mounted) {
      _showDiscountDialog(message ?? "Discount available!", notificationId: notificationId, productId: productId);
    }
  }
});

  try {
    await _hubConnection.start();
    print("SignalR connected to: $signalrUrl");
  } catch (e) {
    print("SignalR failed to connect: $e");
  }
}



void _showDiscountDialog(String message, {int? notificationId, int? productId}) {
  Future.delayed(const Duration(milliseconds: 200), () async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Sales!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (productId != null) {
                final product = await context.read<ProductProvider>().getById(productId);
                if (!mounted) return;
                Navigator.of(dialogContext).push(
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                );

              }
            },
            child: const Text("View"),
          ),
        ],
      ),
    );
  });
}




void _showGiveawayDialog(GiveawayNotification giveaway) {
  print(">> Pokrećem _showGiveawayDialog za: ${giveaway.title}");
  Future.delayed(Duration(milliseconds: 200), () {
    if (!mounted) return;

    print("Prikazujem giveaway dialog");
try {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("New Giveaway!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Would you like to participate in ${giveaway.title}?"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("No"),
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
          child: const Text("Yes"),
        ),
      ],
    ),
  );
} catch (e, stack) {
  print(" Dijalog nije prikazan: $e");
}
  });
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
void _showProductDialog(String name, {int? notificationId, int? productId}) {
  print(" Showing ProductDialog for: $name (productId: $productId)");

  Future.delayed(const Duration(milliseconds: 200), () async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Product!"),
        content: Text("Do you want to view details for $name?"),
        actions: [
          TextButton(
            onPressed: () {
              print(" User chose not to view product");
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              print("View clicked! Getting product by ID...");
              Navigator.of(context).pop();

              if (notificationId != null) {
                print("Marking notification $notificationId as read");
                await context.read<NotificationProvider>().markAsRead(notificationId);
              }

              if (productId != null) {
                final product = await context.read<ProductProvider>().getById(productId);
                print("Product loaded: ${product.name}, price: ${product.price}, discount: ${product.discountPercentage}");

                if (!mounted) return;

                print(" Navigating to ProductDetailScreen...");
               Navigator.of(dialogContext).push(
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              );

              } else {
                print(" productId is null, cannot open detail screen.");
              }
            },
            child: const Text("View"),
          ),
        ],
      ),
    );
  });
}



  @override
  void dispose() {
    _hubConnection.stop();
    _debounceTimer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  

  @override
  void didPopNext() {
    _fetchData();
  }

Future<void> _initialize() async {
  try {
    await context.read<FavoriteProvider>().refreshFavorites();
    await _fetchCategories();
    await _fetchData();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    print(">>> userId = $userId");
    if (userId != null) {
      try {
        final recommended = await _productProvider.getRecommendedProducts(userId);
        if (mounted) {
          setState(() {
            _recommendedProducts = recommended;
            _isLoadingRecommendations = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _recommendedProducts = [];
            _isLoadingRecommendations = false;
          });
        }
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
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
    return SizedBox(
    height: 500,
    child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(), 
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
    ),
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
  dialogContext = context;
  if (_isLoading && result == null) {
    return const Center(child: CircularProgressIndicator());
  }

  final favoriteProvider = Provider.of<FavoriteProvider>(context);
  final isWide = MediaQuery.of(context).size.width > 600;

 return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 20),
            if (_recommendedProducts != null && _recommendedProducts!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recommended for you",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showRecommendations = !_showRecommendations;
                            });
                          },
                          child: Text(
                            _showRecommendations ? "Hide" : "Show",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                   const SizedBox(height: 20),
                    if (_recommendedProducts!.isEmpty)
                      const Center(
                        child: Text(
                          "There are no recommendations available at this moment.",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      )
                  else if (_showRecommendations)
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _recommendedProducts!.length,
                        itemBuilder: (context, index) {
                          final product = _recommendedProducts![index];
                         return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 140,
                                height: 240,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                      height: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: product.image != null
                                            ? Image.memory(
                                                  base64Decode(product.image!),
                                                  fit: BoxFit.contain,
                                                  gaplessPlayback: true,
                                                  filterQuality: FilterQuality.medium,
                                                )

                                            : const Icon(Icons.image_not_supported, size: 50),
                                      ),
                                    ),


                                      const SizedBox(height: 8),
                                      Text(
                                        product.name ?? '',
                                        style: const TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      if (product.discountedPrice != null &&
                                      product.discountedPrice! > 0 &&
                                      product.discountPercentage != null &&
                                      product.discountPercentage! > 0)
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
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
                                        const SizedBox(height: 2),
                                        Text(
                                          '(${product.discountPercentage!.toStringAsFixed(0)}% OFF)',
                                          style: const TextStyle(color: Colors.green, fontSize: 12),
                                        ),
                                      ],
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        formatNumber(product.price),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
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
                                  icon: Icon(
                                    product.isFavorite == true ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.pink,
                                  ),
                                  onPressed: () async {
                                    try {
                                      final liked = await context.read<FavoriteProvider>().toggle(product.productID!);
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
                        );

                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
      if (_isCategoryLoading)
        SliverToBoxAdapter(child: _buildProductShimmer())
      else
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
               final product = result?.result[index];
              if (product == null) return const SizedBox(); 

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 100, 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.image != null
                      ?Image.memory(
                      base64Decode(product.image!),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.medium,
                    )

                      : const Icon(Icons.image_not_supported, size: 50),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                product.name ?? '',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (product.discountedPrice != null &&
                  product.discountedPrice! > 0 &&
                  product.discountPercentage != null &&
                  product.discountPercentage! > 0)
                Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 2),
                    Text(
                      '(${product.discountPercentage!.toStringAsFixed(0)}% OFF)',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    formatNumber(product.price),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 4),
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
              childCount: result?.result.length ?? 0,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
          ),
        ),
    ],
  ),
);

}

}