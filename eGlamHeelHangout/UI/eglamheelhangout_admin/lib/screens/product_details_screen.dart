import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eglamheelhangout_admin/models/product.dart';
import 'package:eglamheelhangout_admin/models/category.dart';
import 'package:eglamheelhangout_admin/models/productsize.dart';
import 'package:eglamheelhangout_admin/models/search_result.dart';
import 'package:eglamheelhangout_admin/providers/product_providers.dart';
import 'package:eglamheelhangout_admin/screens/set_discount_screen.dart';
import 'package:eglamheelhangout_admin/providers/category_providers.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_admin/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  DateTime? _selectedStartDate;
  Map<String, dynamic> _initialValue = {};
  late ProductProvider _productProvider;
  late CategoryProvider _categoryProvider;
  bool _isChanged = false;


  bool isLoading = true;
  SearchResult<Category>? categoryResult;
  Map<int, TextEditingController> _stockControllers = {};
  List<ProductSize> _sizes = [];

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _categoryProvider = context.read<CategoryProvider>();
    initForm();
  }

  Future initForm() async {
    categoryResult = await _categoryProvider.get();


    if (widget.product?.sizes != null && widget.product!.sizes!.isNotEmpty) {
      _sizes = widget.product!.sizes!;
    } else {
  
      _sizes = await _productProvider.getProductSizes(widget.product!.productID!);
    }

    _initialValue = {
      'name': widget.product?.name,
      'price': widget.product?.price?.toString(),
      'description': widget.product?.description,
      'material': widget.product?.material,
      'color': widget.product?.color,
      'heelHeight': widget.product?.heelHeight?.toString(),
      'categoryID': widget.product?.categoryID,
    };


    for (int i = 36; i <= 46; i++) {
      final existing = _sizes.firstWhere(
        (s) => s.size == i,
        orElse: () => ProductSize(size: i, stockQuantity: 0, productSizeId: null),
      );

      _stockControllers[i] = TextEditingController(
        text: existing.stockQuantity.toString(),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void _resetEntireForm() {
    _formKey.currentState?.reset();

    for (int size = 36; size <= 46; size++) {
      final originalQty = _sizes.firstWhere(
        (s) => s.size == size,
        orElse: () => ProductSize(size: size, stockQuantity: 0, productSizeId: null),
      ).stockQuantity;

      _stockControllers[size]?.text = originalQty.toString();
    }

    _selectedImage = null;
    _base64Image = null;

    setState(() {
        _isChanged = false;
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
        _isChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product?.name ?? 'Product Details', style: const TextStyle(color: Colors.white), ),
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
                  _buildSizesSection(),
                  const SizedBox(height: 20),
                  _buildImageSection(),
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
                     OutlinedButton(
                      onPressed: _resetEntireForm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                      const SizedBox(width: 10),
                      ElevatedButton(
                      onPressed: _isChanged ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
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
      onChanged: () {
      setState(() {
        _isChanged = true;
      });
    },
      child: Column(
        children: [
          _buildEditableField("name", "Name"),
          _buildEditableField("price", "Price", keyboardType: TextInputType.number),
          if (widget.product?.discountedPrice != null &&
    widget.product?.discountPercentage != null)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      children: [
        Text(
          "\$${widget.product!.price!.toStringAsFixed(2)}",
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "\$${widget.product!.discountedPrice!.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "(${widget.product!.discountPercentage!.toStringAsFixed(0)}% OFF)",
          style: const TextStyle(color: Colors.green),
        ),
      ],
    ),
  ),


          _buildEditableField("description", "Description", maxLines: 3),
          _buildEditableField("material", "Material"),
          _buildEditableField("color", "Color"),
          _buildEditableField("heelHeight", "Heel Height (cm)", keyboardType: TextInputType.number),
          FormBuilderDropdown<int>(
            name: "categoryID",
            initialValue: widget.product?.categoryID,
            decoration: const InputDecoration(labelText: "Category",labelStyle: TextStyle(fontWeight: FontWeight.normal),),
            items: categoryResult!.result
                .map((category) => DropdownMenuItem<int>(
                      value: category.categoryID,
                      child: Text(category.categoryName ?? ""),
                    ))
                .toList(),
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SetDiscountScreen(product: widget.product!),
              ),
            );

            if (result == true) {
              final refreshedProduct =
                  await _productProvider.getById(widget.product!.productID!);

              setState(() {
                widget.product!.discountedPrice = refreshedProduct.discountedPrice;
                widget.product!.discountPercentage = refreshedProduct.discountPercentage;
              });

              await _saveChanges(); 
            }
          },

            icon: const Icon(Icons.discount, color: Colors.white),
            label: const Text(
              "Set Discount",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2), 
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              shadowColor: Colors.grey.shade200,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String name, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: FormBuilderTextField(
            name: name,
            enabled: true,
            decoration: InputDecoration(labelText: label),
            keyboardType: keyboardType,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 0), 
          child: Text(
            "Adjust Stock by Size",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(11, (index) {
            final shoeSize = 36 + index;
            return SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Size $shoeSize", style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _stockControllers[shoeSize],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
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
          }),
        ),
      ],
    );
  }

        

  Widget _buildImageSection() {
    return (_base64Image != null && _base64Image!.isNotEmpty) ||
            (widget.product?.image?.isNotEmpty ?? false)
        ? Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _base64Image != null && _base64Image!.isNotEmpty
                ? Image.memory(base64Decode(_base64Image!))
                : imageFromBase64String(widget.product?.image),
          )
        : const SizedBox();
  }

  Future<void> _saveChanges() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;

    try {
      final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

      formData['image'] = _base64Image ?? widget.product?.image;
      formData['material'] = _formKey.currentState!.fields['material']?.value;
      formData['color'] = _formKey.currentState!.fields['color']?.value;
      formData['heelHeight'] = double.tryParse(_formKey.currentState!.fields['heelHeight']?.value ?? '0');
      formData['categoryID'] = _formKey.currentState!.fields['categoryID']?.value;

      formData['sizes'] = _stockControllers.entries.map((entry) {
        final size = entry.key;
        final qty = int.tryParse(entry.value.text) ?? 0;

        final existingSize = _sizes.firstWhere(
          (s) => s.size == size,
          orElse: () => ProductSize(size: size, stockQuantity: qty, productSizeId: null),
        );

        if (existingSize.stockQuantity != qty) {
          return {
            "size": size,
            "stockQuantity": qty,
            "productSizeId": existingSize.productSizeId ?? 0,
          };
        } else {
          return null;
        }
      }).where((element) => element != null).toList();

      await _productProvider.update(widget.product!.productID!, formData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully saved changes'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
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
  }


}