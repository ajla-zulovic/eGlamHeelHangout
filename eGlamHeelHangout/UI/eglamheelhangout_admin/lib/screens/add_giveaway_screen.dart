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
import 'package:intl/intl.dart';

class AddGiveawayScreen extends StatefulWidget {
  const AddGiveawayScreen({super.key});

  @override
  State<AddGiveawayScreen> createState() => _AddGiveawayScreenState();
}

class _AddGiveawayScreenState extends State<AddGiveawayScreen> {
 // final _formKey = GlobalKey<FormBuilderState>();
  var _formKey = GlobalKey<FormBuilderState>();

  bool _isSubmitting = false;
  PlatformFile? _selectedImage;
  String? _base64Image;
  DateTime? _selectedEndDate;
  bool _imageValidationFailed = false;


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
        _selectedEndDate = null;
        _imageValidationFailed = false;
      });
    }
  }

Widget _buildImagePreview() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Container(
        height: 250,
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
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _selectedImage!.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _base64Image = null;
                              _selectedImage = null;
                              _imageValidationFailed = true;
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                        ),
                      ],
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
      if (_imageValidationFailed)
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Image is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
    ],
  );
}



 Future<void> _submitForm() async {
  if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

  if (_base64Image == null) {
  setState(() {
    _imageValidationFailed = true;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Image is required'),
      backgroundColor: Colors.red,
    ),
  );
  return;
} else {
  setState(() {
    _imageValidationFailed = false;
  });
}

  setState(() => _isSubmitting = true);

  try {
    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);
    formData['endDate'] = (formData['endDate'] as DateTime).toIso8601String();
    formData['giveawayProductImage'] = _base64Image;

    final provider = context.read<GiveawayProvider>();
    await provider.insert(formData);

    if (!mounted) return;

    //_formKey.currentState?.reset();
    setState(() {
      _formKey = GlobalKey<FormBuilderState>();
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
      const SnackBar(
        content: Text('Something went wrong. Please try again.'),
        backgroundColor: Colors.red,
      ),
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
                      labelText: 'Heel Height (e.g. 7.5)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Heel height is required';
                      }
                      final height = double.tryParse(value);
                      if (height == null || height <= 0) {
                        return 'Enter a valid number (e.g. 7.5)';
                      }
                      return null;
                    },
                    valueTransformer: (value) => value != null ? double.tryParse(value) : null,
                  ),

                  const SizedBox(height: 16),
                  FormBuilderDateTimePicker(
                    name: 'endDate',
                    inputType: InputType.date,
                    initialValue: DateTime.now().add(const Duration(days: 1)),
                    format: DateFormat('yyyy-MM-dd'),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(2100),
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null) return 'End Date is required';
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final selected = DateTime(value.year, value.month, value.day);

                      if (!selected.isAfter(today)) {
                        return 'End Date must be a future date (after today)';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedEndDate = value;
                      });
                    },
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
                   if (_base64Image == null)
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
       // _formKey.currentState?.reset();
        setState(() {
          _formKey = GlobalKey<FormBuilderState>();
          _base64Image = null;
          _selectedImage = null;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

    const SizedBox(width: 24), 

    ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
          : const Text('Save', style: TextStyle(color: Colors.white)),
    ),
  ],
)

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
