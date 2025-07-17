import 'package:flutter/material.dart';
import 'package:eglamheelhangout_admin/providers/product_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_admin/screens/products_list_screen.dart';
import 'package:eglamheelhangout_admin/utils/utils.dart';
import 'package:eglamheelhangout_admin/providers/category_providers.dart';
import 'package:eglamheelhangout_admin/providers/user_providers.dart';
import 'package:eglamheelhangout_admin/utils/current_user.dart';
import 'package:eglamheelhangout_admin/providers/giveaway_providers.dart';
import 'package:eglamheelhangout_admin/providers/order_providers.dart';
import 'package:eglamheelhangout_admin/providers/discount_providers.dart';
import 'package:eglamheelhangout_admin/providers/report_providers.dart';
import 'package:eglamheelhangout_admin/screens/register_user_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => CategoryProvider()),
       ChangeNotifierProvider(create: (_) => UserProvider()),
       ChangeNotifierProvider(create: (_) => GiveawayProvider()),
       ChangeNotifierProvider(create: (_) => OrderProvider()),
       ChangeNotifierProvider(create: (_) => ReportProvider()),
      ChangeNotifierProvider(create: (_) => DiscountProvider()),

       
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
  bool _showPassword = false;


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
          "Glam Heel Hangout Admin",
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
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
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
                                if (!loggedInUser.roleName!.toLowerCase().contains('admin')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Access denied. Admin role is required.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }


                                CurrentUser.set(loggedInUser.userId!, loggedInUser.username!);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login successful!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ProductsListScreen(),
                                  ),
                                );
                              } catch (e) {
                            String errorMessage = e.toString().toLowerCase().contains('unauthorized')
                                ? 'Invalid username or password.'
                                : 'Login failed. Please try again.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Register!",
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
