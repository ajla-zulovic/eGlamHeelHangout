import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eglamheelhangout_admin/models/product.dart';
import 'package:eglamheelhangout_admin/models/discount.dart';
import 'package:eglamheelhangout_admin/providers/discount_providers.dart';
import 'package:provider/provider.dart';

class SetDiscountScreen extends StatefulWidget {
  final Product product;

  const SetDiscountScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<SetDiscountScreen> createState() => _SetDiscountScreenState();
}

class _SetDiscountScreenState extends State<SetDiscountScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late DiscountProvider _discountProvider;
  Discount? _existingDiscount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _discountProvider = context.read<DiscountProvider>();
    _loadDiscount();
  }

  Future<void> _loadDiscount() async {
    try {
      final result = await _discountProvider.getByProduct(widget.product.productID!);
      setState(() {
        _existingDiscount = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDiscount() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;

    try {
      final formData = _formKey.currentState!.value;

      final discount = Discount(
        productId: widget.product.productID!,
        discountPercentage: int.parse(
  _formKey.currentState!.fields['discountPercentage']!.value.toString()
),
        startDate: formData['startDate'],
        endDate: formData['endDate'],
      );

      await _discountProvider.applyDiscount(discount);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Discount applied"), backgroundColor: Colors.green),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
    }
  }
void _confirmRemoveDiscount(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove Discount'),
      content: const Text('Are you sure you want to remove this discount?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('No'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Yes', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await _removeDiscount();
  }
}

  Future<void> _removeDiscount() async {
    try {
      await _discountProvider.remove(widget.product.productID!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Discount removed"), backgroundColor: Colors.red),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Discount")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey,
                initialValue: _existingDiscount != null
                    ? {
                        
                        'discountPercentage': _existingDiscount!.discountPercentage.toString(),
                        'startDate': _existingDiscount!.startDate,
                        'endDate': _existingDiscount!.endDate,
                      }
                    : {},
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'discountPercentage',
                      decoration: const InputDecoration(labelText: "Discount (%)"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final percent = double.tryParse(value ?? '');
                        if (percent == null) return 'Enter a valid number';
                        if (percent < 0 || percent > 70) return 'Must be between 0% and 70%';
                        return null;
                      },
                    ),
                    FormBuilderDateTimePicker(
                      name: 'startDate',
                      inputType: InputType.date,
                      decoration: const InputDecoration(labelText: "Start Date"),
                      firstDate: DateTime.now(),
                    ),
                    FormBuilderDateTimePicker(
                      name: 'endDate',
                      inputType: InputType.date,
                      decoration: const InputDecoration(labelText: "End Date"),
                      validator: (value) {
                        final start = _formKey.currentState?.fields['startDate']?.value as DateTime?;
                        if (value == null) return 'Required';
                        if (start != null && value.isBefore(start)) {
                          return 'End date must be after start';
                        }
                        return null;
                      },
                    ),
                   
                  const SizedBox(height: 24),
                    Align(
                    alignment: Alignment.centerRight,
                    child: _existingDiscount != null
                        ? ElevatedButton.icon(
                            onPressed: () => _confirmRemoveDiscount(context),
                            icon: const Icon(Icons.delete),
                            label: const Text("Remove Discount"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _saveDiscount,
                            icon: const Icon(Icons.save),
                            label: const Text("Save"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                          ),
                  ),

                  ],
                ),
              ),
            ),
    );
  }
}
