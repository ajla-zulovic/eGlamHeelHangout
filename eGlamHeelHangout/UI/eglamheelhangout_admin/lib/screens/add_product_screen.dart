
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eglamheelhangout_admin/models/category.dart';
import 'package:eglamheelhangout_admin/models/product.dart';
import 'package:eglamheelhangout_admin/models/search_result.dart';
import 'package:eglamheelhangout_admin/providers/category_providers.dart';
import 'package:eglamheelhangout_admin/providers/product_providers.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eglamheelhangout_admin/utils/utils.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late ProductProvider _productProvider;
  late CategoryProvider _categoryProvider;
  SearchResult<Category>? _categoryResult;
  bool _isLoading = true;
  bool _isSubmitting = false;
  PlatformFile? _selectedImage;
  String? _base64Image;
  final Map<int, TextEditingController> _stockControllers = {};
  final List<int> _sizes = List.generate(11, (index) => 36 + index);


  @override
  void initState() {
    super.initState();
      for (var size in _sizes) {
    _stockControllers[size] = TextEditingController();
  }
    _productProvider = context.read<ProductProvider>();
    _categoryProvider = context.read<CategoryProvider>();
    _initForm();
  }
  @override
void dispose() {
  for (var controller in _stockControllers.values) {
    controller.dispose();
  }
  super.dispose();
}


  Future<void> _initForm() async {
    try {
      _categoryResult = await _categoryProvider.get();
      debugPrint("Učitano kategorija: ${_categoryResult?.result.length}");
  for (var k in _categoryResult!.result) {
    debugPrint("Kategorija: ${k.categoryID} - ${k.categoryName}");
  }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
       debugPrint("Greška prilikom učitavanja kategorija: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      });
    }
  }
Widget _buildImagePreview() {
  return Column(
    children: [
      const SizedBox(height: 16),
      Container(
        constraints: const BoxConstraints(minHeight: 200),
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
    ],
  );
}


  Widget _buildFormSection(String title, Widget child) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            _buildFormSection(
              'Basic Information',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'name',
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Name is required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'price',
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Price is required';
                            if (double.tryParse(value) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_categoryResult?.result.isNotEmpty ?? false)
                    FormBuilderDropdown<String>(
                      name: 'categoryID',
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _categoryResult!.result
                          .where((c) => c.categoryID != null)
                          .map((category) => DropdownMenuItem(
                                value: category.categoryID!.toString(),
                                child: Text(category.categoryName ?? 'Unnamed'),
                              ))
                          .toList(),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Category is required' : null,
                    )
                  else
                    const Text("No categories available"),
                ],
              ),
            ),
            _buildFormSection(
              'Description',
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(
                  labelText: 'Product Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                maxLines: 3,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Description is required' : null,
              ),
            ),
            _buildFormSection(
              'Details',
              Column(
                children: [
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
                    name: 'material',
                    decoration: const InputDecoration(
                      labelText: 'Material',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Material is required' : null,
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'heelHeight',
                    decoration: const InputDecoration(
                      labelText: 'Heel Height (cm)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Heel height is required' : null,
                  ),
                ],
              ),
            ),
            _buildFormSection(
              'Sizes',
              Align(
                alignment: Alignment.centerLeft,
              child:Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _sizes.map((size) {
                  return SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Size $size", style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _stockControllers[size],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Qty",
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              )
            ),

            _buildFormSection(
              'Product Image',
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
                    _formKey.currentState?.reset();
                    _selectedImage = null;
                    _base64Image = null;
                    for (var controller in _stockControllers.values) {
                        controller.text = '';
                      }

                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
Future<void> _submitForm() async {
  if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

  setState(() => _isSubmitting = true);

  try {
    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);
    formData['price'] = double.tryParse(formData['price'].toString()) ?? 0;
    formData['heelHeight'] = double.tryParse(formData['heelHeight'].toString()) ?? 0.0;
    formData['categoryID'] = int.tryParse(formData['categoryID'].toString()) ?? 0;


    final sizes = _sizes
        .map((size) {
          final qtyText = _stockControllers[size]?.text ?? '';
          final qty = int.tryParse(qtyText);
          if (qty != null && qty > 0) {
            return {'size': size, 'stockQuantity': qty};
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    if (sizes.isEmpty) {
      throw Exception('At least one size with quantity > 0 is required.');
    }

    formData['sizes'] = sizes;

    if (_base64Image != null) {
      formData['image'] = _base64Image;
    } else {
      throw Exception('Product image is required');
    }

    await _productProvider.insert(formData);

    if (!mounted) return;

    _formKey.currentState?.reset();
   
      for (var controller in _stockControllers.values) {
        controller.text = '';
      }
    setState(() {
      _base64Image = null;
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added successfully!'),
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


  @override
Widget build(BuildContext context) {
  return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _buildForm();
}

}