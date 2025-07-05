import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:eglamheelhangout_mobile/providers/product_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/screens/products_list_screen.dart';
import 'package:eglamheelhangout_mobile/screens/register_user_screen.dart';
import 'package:eglamheelhangout_mobile/utils/utils.dart';
import 'package:eglamheelhangout_mobile/providers/category_providers.dart';
import 'package:eglamheelhangout_mobile/providers/user_providers.dart';
import 'package:eglamheelhangout_mobile/utils/current_user.dart';
import 'package:eglamheelhangout_mobile/providers/favorite_providers.dart';
import 'package:eglamheelhangout_mobile/providers/review_providers.dart';
import 'package:eglamheelhangout_mobile/providers/cart_providers.dart';
import 'package:eglamheelhangout_mobile/providers/order_providers.dart';
import 'package:eglamheelhangout_mobile/providers/stripe_providers.dart';
import 'package:eglamheelhangout_mobile/providers/giveaway_providers.dart';
import 'package:eglamheelhangout_mobile/providers/notifications_providers.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eglamheelhangout_mobile/providers/discount_providers.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //-> osigurava da su flutter-ve osnovne stvari ready -> poput .env, Stripe,HttpOverrides

 await dotenv.load(fileName: ".env");
 Stripe.publishableKey = dotenv.env['Stripe__PublishableKey']!;
 await Stripe.instance.applySettings();
 print("Stripe Key: ${dotenv.env['Stripe__PublishableKey']}");

 HttpOverrides.global = MyHttpOverrides();
 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => StripeProvider()),
        ChangeNotifierProvider(create: (_) => GiveawayProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
      ],
      child:  flutter.MaterialApp( //const
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver], 
        home: LoginPage(),
      ),
    ),
  );
}

class LoginPage extends flutter.StatefulWidget {
  const LoginPage({flutter.Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends flutter.State<LoginPage> {
  final _usernameController = flutter.TextEditingController();
  final _passwordController = flutter.TextEditingController();
  late final ProductProvider _productProvider;
  final _formKey = flutter.GlobalKey<flutter.FormState>();
  bool _showPassword = false;


  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    flutter.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StripeProvider>().initializeStripe();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      backgroundColor: flutter.Colors.white,
      appBar: flutter.AppBar(
        title: const flutter.Text(
          "Glam Heel Hangout User",
          style: flutter.TextStyle(fontSize: 16, color: flutter.Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: flutter.Colors.grey[800],
      ),
      body: flutter.Center(
        child: flutter.SingleChildScrollView(
          child: flutter.Container(
            margin: const flutter.EdgeInsets.all(20),
            constraints: const flutter.BoxConstraints(maxWidth: 500),
            child: flutter.Card(
              color: flutter.Colors.white,
              elevation: 8,
              shape: flutter.RoundedRectangleBorder(
                borderRadius: flutter.BorderRadius.circular(16),
              ),
              child: flutter.Padding(
                padding: const flutter.EdgeInsets.all(24.0),
                child: flutter.Form(
                  key: _formKey,
                  child: flutter.Column(
                    mainAxisSize: flutter.MainAxisSize.min,
                    children: [
                      flutter.Image.asset(
                        "assets/images/logologo.png",
                        height: 130,
                        width: 130,
                      ),
                      const flutter.SizedBox(height: 24),
                      const flutter.Text(
                        "Login",
                        style: flutter.TextStyle(
                          fontSize: 20,
                          fontWeight: flutter.FontWeight.bold,
                          color: flutter.Colors.grey,
                        ),
                      ),
                      const flutter.SizedBox(height: 24),
                      flutter.TextFormField(
                        decoration: flutter.InputDecoration(
                          labelText: "Username",
                          prefixIcon: const flutter.Icon(flutter.Icons.person),
                          border: flutter.OutlineInputBorder(
                            borderRadius: flutter.BorderRadius.circular(8),
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
                      const flutter.SizedBox(height: 16),
                      flutter.TextFormField(
                      obscureText: !_showPassword,
                      decoration: flutter.InputDecoration(
                        labelText: "Password",
                        prefixIcon: const flutter.Icon(flutter.Icons.lock),
                        suffixIcon: flutter.IconButton(
                          icon: flutter.Icon(_showPassword ? flutter.Icons.visibility_off : flutter.Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        border: flutter.OutlineInputBorder(
                          borderRadius: flutter.BorderRadius.circular(8),
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

                      const flutter.SizedBox(height: 24),
                      flutter.SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: flutter.ElevatedButton(
                          style: flutter.ElevatedButton.styleFrom(
                            backgroundColor: flutter.Colors.blue[500],
                            shape: flutter.RoundedRectangleBorder(
                              borderRadius: flutter.BorderRadius.circular(8),
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
                                await _productProvider.get();

                                final userProvider = context.read<UserProvider>();
                                final userResult = await userProvider.get(filter: {'username': username});

                                if (userResult.result.isEmpty) {
                                  throw Exception("User not found");
                                }

                                final loggedInUser = await userProvider.getCurrentUser();
                                final prefs = await SharedPreferences.getInstance();
                                prefs.setInt("userId", loggedInUser.userId!);
                                CurrentUser.set(
                                loggedInUser.userId!,
                                loggedInUser.username!,
                                fullUser: loggedInUser,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Login successful!"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                                Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const ProductsListScreen(),
                                ),
                              );
                              } catch (e) {
                                flutter.showDialog(
                                  context: context,
                                  builder: (_) => flutter.AlertDialog(
                                    title: const flutter.Text("Login failed"),
                                    content: flutter.Text(e.toString()),
                                    actions: [
                                      flutter.ElevatedButton(
                                        onPressed: () => flutter.Navigator.of(context).pop(),
                                        child: const flutter.Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          child: const flutter.Text(
                            "Login",
                            style: flutter.TextStyle(
                              fontSize: 16,
                              fontWeight: flutter.FontWeight.bold,
                              color: flutter.Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const flutter.SizedBox(height: 16),
                      flutter.TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const flutter.Text(
                          "Don't have an account? Register!",
                          style: flutter.TextStyle(color: flutter.Colors.black),
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
