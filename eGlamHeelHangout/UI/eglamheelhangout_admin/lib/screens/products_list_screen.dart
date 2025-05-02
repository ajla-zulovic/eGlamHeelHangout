import 'package:flutter/material.dart';
import 'package:eglamheelhangout_admin/providers/product_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_admin/main.dart';

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
    {'page': const ReportScreen(), 'title': 'Report Page'},
    {'page': const AddProductScreen(), 'title': 'Add Product'},
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
            ...List.generate(_pages.length, (index) {
              return ListTile(
                title: Text(_pages[index]['title']),
                onTap: () => _selectPage(index),
              );
            }),
            const Divider(),
            ListTile(
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Home Screen'));
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

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Product Screen'));
  }
}

class AddGiveawayScreen extends StatelessWidget {
  const AddGiveawayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Giveaway Screen'));
  }
}
