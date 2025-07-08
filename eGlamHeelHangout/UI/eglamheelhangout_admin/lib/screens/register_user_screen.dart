import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_admin/providers/user_providers.dart';
import 'package:eglamheelhangout_admin/screens/products_list_screen.dart';
import 'package:eglamheelhangout_admin/utils/utils.dart';
import 'package:eglamheelhangout_admin/utils/current_user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.grey[800],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset("assets/images/logologo.png", height: 130, width: 130),
                      const SizedBox(height: 24),
                      _buildTextField(_firstNameController, "First Name"),
                      _buildTextField(_lastNameController, "Last Name"),
                      _buildTextField(_usernameController, "Username"),
                      _buildTextField(_emailController, "Email", type: TextInputType.emailAddress),
                      _buildTextField(_phoneController, "Phone Number", type: TextInputType.phone),
                      _buildTextField(
                        _passwordController,
                        "Password",
                        obscure: !_showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      _buildTextField(
                        _confirmPasswordController,
                        "Confirm Password",
                        obscure: !_showConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[500],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_passwordController.text != _confirmPasswordController.text) {
                                _showErrorDialog("Passwords do not match");
                                return;
                              }

                              final userProvider = context.read<UserProvider>();
                              try {
                                await userProvider.register({
                                  "firstName": _firstNameController.text,
                                  "lastName": _lastNameController.text,
                                  "username": _usernameController.text,
                                  "email": _emailController.text,
                                  "phoneNumber": _phoneController.text,
                                  "password": _passwordController.text,
                                  "passwordPotvrda": _confirmPasswordController.text,
                                });

                                Authorization.username = _usernameController.text;
                                Authorization.password = _passwordController.text;

                                final currentUser = await userProvider.getCurrentUser();
                                CurrentUser.set(currentUser.userId!, currentUser.username!);

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const ProductsListScreen()),
                                );
                                 ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Registration successful!"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              } catch (e) {
                                _showErrorDialog(e.toString());
                              }
                            }
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Already have an account? Log in!",
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType? type,
    Widget? suffixIcon,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: suffixIcon,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Please enter $label";
            if (label == "Email" && !value.contains("@")) return "Invalid email";
            if (label == "Phone Number" && value.length < 6) return "Invalid phone number";
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Registration failed"),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
