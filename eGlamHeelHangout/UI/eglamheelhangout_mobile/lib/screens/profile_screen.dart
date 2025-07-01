import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_providers.dart';
import '../utils/current_user.dart';
import '../screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserProvider _userProvider;
  User? _user;
  bool _isEditing = false;
  final _controllers = <String, TextEditingController>{};
  DateTime? _selectedDate;
  String? _base64Image;
  PlatformFile? _selectedImage;
  bool _imageRemoved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadUserData();
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final phoneRegex = RegExp(r'^\+?[0-9]{6,15}$');
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  Future<void> _loadUserData() async {
    if (CurrentUser.userId == null) return;
    final user = await _userProvider.getById(CurrentUser.userId!);
    setState(() {
      _user = user;
      _controllers['firstName'] = TextEditingController(text: user.firstName);
      _controllers['lastName'] = TextEditingController(text: user.lastName);
      _controllers['email'] = TextEditingController(text: user.email);
      _controllers['phoneNumber'] = TextEditingController(text: user.phoneNumber);
      _controllers['address'] = TextEditingController(text: user.address);
      _selectedDate = user.dateOfBirth;
      _base64Image = user.profileImage;
      _selectedImage = null;
      _imageRemoved = false;
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImage = result.files.first;
        _base64Image = base64Encode(_selectedImage!.bytes!);
        _imageRemoved = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && _user != null) {
      final updatedUser = User(
        firstName: _controllers['firstName']?.text,
        lastName: _controllers['lastName']?.text,
        email: _controllers['email']?.text,
        phoneNumber: _controllers['phoneNumber']?.text,
        address: _controllers['address']?.text,
        dateOfBirth: _selectedDate,
        profileImage: _imageRemoved ? null : _base64Image ?? _user!.profileImage,
      );

      try {
        await _userProvider.update(_user!.userId!, updatedUser.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
        _formKey.currentState?.reset();
        _loadUserData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: \${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("My Profile", style: TextStyle(fontSize: 24)),
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    _formKey.currentState?.reset();
                    _loadUserData();
                  }
                  setState(() => _isEditing = !_isEditing);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                 radius: 60,
                  backgroundImage: _selectedImage != null
                      ? MemoryImage(_selectedImage!.bytes!)
                      : (_base64Image != null && _base64Image!.isNotEmpty
                          ? MemoryImage(base64Decode(_base64Image!))
                          : null),
                  child: (_selectedImage == null && (_base64Image == null || _base64Image!.isEmpty))
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                if (_isEditing)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      if (_base64Image == null)
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: const Text("Upload Image"),
                        )
                      else
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _base64Image = null;
                              _selectedImage = null;
                              _imageRemoved = true;
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("Remove Image", style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                children: [
                  _buildField("firstName", "First Name"),
                  _buildField("lastName", "Last Name"),
                  _buildField("email", "Email", TextInputType.emailAddress, _emailValidator),
                  _buildField("phoneNumber", "Phone Number", TextInputType.phone, _phoneValidator),
                  _buildField("address", "Address"),
                  const SizedBox(height: 5),
                  if (_isEditing) ...[
                    const Text("Date of Birth"),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : "Select date",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Security", style: TextStyle(fontSize: 18)),
                        TextButton.icon(
                          icon: const Icon(Icons.lock_outline),
                          label: const Text("Change Password"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String key, String label,
      [TextInputType keyboardType = TextInputType.text,
      FormFieldValidator<String>? validator]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        enabled: _isEditing,
        controller: _controllers[key],
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(), 
          filled: true,
          fillColor: Colors.white, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator ?? (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
