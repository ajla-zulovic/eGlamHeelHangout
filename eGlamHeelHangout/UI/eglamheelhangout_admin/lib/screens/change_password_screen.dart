import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/user_providers.dart';
import '../utils/utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  Future<void> _submitChange() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

   try {
  final provider = Provider.of<UserProvider>(context, listen: false);
  await provider.changePassword({
    "currentPassword": _currentPasswordController.text,
    "newPassword": _newPasswordController.text,
    "confirmNewPassword": _confirmPasswordController.text,
  });
  Authorization.password = _newPasswordController.text;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Password changed successfully."), backgroundColor: Colors.green),
  );

  Navigator.pop(context);
}catch (e) {
  String errorMessage = "Unknown error occurred";

  if (e is http.Response) {
    try {
      final decoded = jsonDecode(e.body);
      errorMessage = decoded["message"] ?? "Something went wrong.";
    } catch (_) {
      errorMessage = "Failed to parse error response.";
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
  );
} finally {
  setState(() => _isLoading = false);
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _isObscure1,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure1 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _isObscure1 = !_isObscure1);
                    },
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isObscure2,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure2 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _isObscure2 = !_isObscure2);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isObscure3,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure3 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _isObscure3 = !_isObscure3);
                    },
                  ),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_reset),
                label: const Text("Change Password"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10),
                        ),
                ),
                onPressed: _isLoading ? null : _submitChange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
