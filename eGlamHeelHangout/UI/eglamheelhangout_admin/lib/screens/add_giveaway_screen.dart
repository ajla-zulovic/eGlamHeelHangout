import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_admin/providers/giveaway_providers.dart';
import 'package:eglamheelhangout_admin/models/giveaway.dart';
import 'package:eglamheelhangout_admin/screens/products_list_screen.dart';

class AddGiveawayScreen extends StatefulWidget {
  const AddGiveawayScreen({super.key});

  @override
  State<AddGiveawayScreen> createState() => _AddGiveawayScreenState();
}

class _AddGiveawayScreenState extends State<AddGiveawayScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
  PlatformFile? _selectedImage;
  String? _base64Image;

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
      });
    }
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: _base64Image != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.memory(
                      base64Decode(_base64Image!),
                      fit: BoxFit.contain,
                      height: 150,
                    ),
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _selectedImage!.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No image selected', style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ],
    );
  }

 Future<void> _submitForm() async {
  if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

  setState(() => _isSubmitting = true);

  try {
    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);
    formData['endDate'] = formData['endDate'].toIso8601String();

    if (_base64Image != null) {
      formData['giveawayProductImage'] = _base64Image;
    } else {
      throw Exception('Image is required');
    }

    final provider = context.read<GiveawayProvider>();
    await provider.insert(formData);

    if (!mounted) return;

    // ✅ Reset forme i slike
    _formKey.currentState?.reset();
    setState(() {
      _base64Image = null;
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Giveaway successfully created! Ready to add another?'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}


  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            _section(
              'Giveaway Details',
              Column(
                children: [
                  FormBuilderTextField(
                    name: 'title',
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'color',
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Color is required' : null,
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'heelHeight',
                    decoration: const InputDecoration(
                      labelText: 'Heel Height',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Heel height is required' : null,
                  ),
                  const SizedBox(height: 16),
                  FormBuilderDateTimePicker(
                    name: 'endDate',
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    inputType: InputType.date,
                    validator: (value) =>
                        (value == null) ? 'End date is required' : null,
                  ),
                ],
              ),
            ),
            _section(
              'Description',
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                maxLines: 3,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Description is required' : null,
              ),
            ),
            _section(
              'Image',
              Column(
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Image'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _formKey.currentState?.reset();
                    setState(() {
                      _base64Image = null;
                      _selectedImage = null;
                    });
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget content) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700])),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return _buildForm();
  }
}
