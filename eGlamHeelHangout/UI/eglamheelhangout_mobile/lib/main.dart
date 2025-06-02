import 'package:flutter/material.dart';
import 'package:eglamheelhangout_mobile/providers/product_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/screens/products_list_screen.dart';
import 'package:eglamheelhangout_mobile/utils/utils.dart';
import 'package:eglamheelhangout_mobile/providers/category_providers.dart';
import 'package:eglamheelhangout_mobile/providers/user_providers.dart';
import 'package:eglamheelhangout_mobile/utils/current_user.dart';
import 'package:eglamheelhangout_mobile/providers/favorite_providers.dart';
import 'package:eglamheelhangout_mobile/providers/review_providers.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


void main() {
   HttpOverrides.global = MyHttpOverrides(); //imam problem s certifikatom
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => CategoryProvider()),
       ChangeNotifierProvider(create: (_) => UserProvider()),
       ChangeNotifierProvider(create: (_) => FavoriteProvider()),
       ChangeNotifierProvider(create: (_) => ReviewProvider()),

      ],
      
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    ),
  );
}
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final ProductProvider _productProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Glam Heel Hangout User",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[800],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/logologo.png",
                        height: 130,
                        width: 130,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var username = _usernameController.text;
                              var password = _passwordController.text;

                              Authorization.username = username;
                              Authorization.password = password;

                              try {
                                await _productProvider.get(); // ovo validira lozinku

                                  final userProvider = context.read<UserProvider>();
                                  final userResult = await userProvider.get(filter: {'username': username});

                                  if (userResult.result.isEmpty) {
                                    throw Exception("User not found");
                                  }

                                  final loggedInUser = await userProvider.getCurrentUser();
                                  CurrentUser.set(loggedInUser.userId!, loggedInUser.username!);

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ProductsListScreen(),
                                  ),
                                );
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: Text("Login failed"),
                                        content: Text(e.toString()),
                                        actions: [
                                          ElevatedButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: Text("Close"),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forget password?",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
