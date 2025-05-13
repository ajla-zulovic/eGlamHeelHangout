import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eglamheelhangout_admin/models/product.dart';
import 'package:eglamheelhangout_admin/models/category.dart';
import 'package:eglamheelhangout_admin/models/search_result.dart';
import 'package:eglamheelhangout_admin/providers/product_providers.dart';
import 'package:eglamheelhangout_admin/providers/category_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_admin/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  PlatformFile? _selectedImage;
  String? _base64Image;

  Map<String, dynamic> _initialValue = {};
  Map<String, bool> _isEditing = {
    "name": false,
    "price": false,
    "description": false,
  };
  late ProductProvider _productProvider;
  bool isLoading = true;
  late CategoryProvider _categoryProvider;
  SearchResult<Category>? categoryResult;
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _categoryProvider = context.read<CategoryProvider>();
    initForm();
  }

  Future initForm() async {
    categoryResult = await _categoryProvider.get();
    _categoryName = categoryResult?.result.firstWhere(
      (c) => c.categoryID == widget.product?.categoryID,
      orElse: () => Category(0, 'Unknown'),
    ).categoryName;

    _initialValue = {
      'name': widget.product?.name,
      'price': widget.product?.price?.toString(),
      'description': widget.product?.description,
      'categoryName': _categoryName,
      'material': widget.product?.material,
      'color': widget.product?.color,
      'heelHeight': widget.product?.heelHeight?.toString(),
    };

    setState(() {
      isLoading = false;
    });
  }

  void _resetEditStates() {
    setState(() {
      _isEditing.updateAll((key, value) => false);
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product?.name ?? 'Product Details'),
        backgroundColor: Colors.grey[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildForm(),
                  const SizedBox(height: 20),
                  if ((_base64Image != null && _base64Image!.isNotEmpty) ||
                      (widget.product?.image?.isNotEmpty ?? false))
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _base64Image != null && _base64Image!.isNotEmpty
                          ? Image.memory(base64Decode(_base64Image!))
                          : imageFromBase64String(widget.product?.image),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Change Image"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();
                          _resetEditStates();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final isValid = _formKey.currentState?.saveAndValidate() ?? false;
                          if (!isValid) return;

                          try {
                              final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

                              formData['image'] = _base64Image ?? widget.product?.image;

                              formData.removeWhere((key, _) =>
                                  !["name", "description", "price", "image"].contains(key));

                              await _productProvider.update(widget.product!.productID!, formData);
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully saved changes'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pop(context, true);
                              return;
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    )
                                  ],
                                ),
                              );
                            }

                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "name",
                  enabled: _isEditing["name"] ?? false,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter product name' : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing["name"] = !(_isEditing["name"] ?? false);
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "price",
                  enabled: _isEditing["price"] ?? false,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter price';
                    if (double.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing["price"] = !(_isEditing["price"] ?? false);
                  });
                },
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "description",
                  enabled: _isEditing["description"] ?? false,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing["description"] = !(_isEditing["description"] ?? false);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: "categoryName",
            enabled: false,
            decoration: const InputDecoration(labelText: "Category"),
          ),
          FormBuilderTextField(
            name: "material",
            enabled: false,
            decoration: const InputDecoration(labelText: "Material"),
          ),
          FormBuilderTextField(
            name: "color",
            enabled: false,
            decoration: const InputDecoration(labelText: "Color"),
          ),
          FormBuilderTextField(
            name: "heelHeight",
            enabled: false,
            decoration: const InputDecoration(labelText: "Heel Height (cm)"),
          ),
        ],
      ),
    );
  }
}
