import '../providers/order_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../providers/cart_providers.dart';
import '../services/payment_service.dart';
import '../models/paymentcreate.dart';
import '../models/order.dart';
import '../models/orderitem.dart';
import '../utils/current_user.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = CurrentUser.user;
    if (user != null) {
      _fullNameController.text = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text("Billing Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildTextField(_fullNameController, 'Full Name'),
                    _buildTextField(_emailController, 'Email', isEmail: true),
                    _buildTextField(_phoneController, 'Phone Number', isPhone: true),
                    _buildTextField(_addressController, 'Address'),
                    _buildTextField(_cityController, 'City'),
                    _buildTextField(_postalCodeController, 'Postal Code', isPostal: true),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Confirm Payment"),
                                  content: const Text("Are you sure you want to proceed with the payment?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("No")),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Yes")),
                                  ],
                                ),
                              );

                              if (confirmed != true) return;

                              if (!_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please complete all fields.")),
                                );
                                return;
                              }

                              setState(() => _isProcessing = true);

                              try {
                                final orderProvider = context.read<OrderProvider>();
                                final newOrder = Order(
                                  orderId: 0,
                                  totalPrice: cartProvider.total,
                                  orderStatus: "Pending",
                                  paymentMethod: "Card",
                                  username: CurrentUser.username ?? '',
                                  orderDate: DateTime.now(),
                                  items: cartProvider.items.map((item) => OrderItem(
                                    productId: item.productId,
                                    productName: item.name,
                                    quantity: item.quantity,
                                    productSizeId: item.productSizeId,
                                    pricePerUnit: item.price,
                                    size: item.size,
                                  )).toList(),
                                  fullName: _fullNameController.text,
                                  email: _emailController.text,
                                  phoneNumber: _phoneController.text,
                                  address: _addressController.text,
                                  city: _cityController.text,
                                  postalCode: _postalCodeController.text,
                                );

                                final createdOrder = await orderProvider.createOrder(newOrder);
                                if (createdOrder == null) throw Exception("Order creation failed");

                                final payment = PaymentCreate(
                                  orderId: createdOrder.orderId!,
                                  totalAmount: (createdOrder.totalPrice * 100).toInt(),
                                  paymentMethodId: "",
                                  username: CurrentUser.username ?? '',
                                );

                                final paymentService = PaymentService();
                                await paymentService.makePayment(payment);

                                cartProvider.clear();

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Payment successful!"), backgroundColor: Colors.green),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  String errorMessage = "Payment failed. Please try again.";
                                  if (e is StripeException) {
                                    errorMessage = e.error.localizedMessage ?? "Stripe error occurred.";
                                  } else {
                                    errorMessage = e.toString();
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                                  );
                                }
                              } finally {
                                setState(() => _isProcessing = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Pay"),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isEmail = false, bool isPhone = false, bool isPostal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          if (isEmail && !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email format';
          if (isPhone && !RegExp(r'^\d{6,15}$').hasMatch(value)) return 'Invalid phone number';
          if (isPostal && !RegExp(r'^[A-Za-z0-9 \-]{3,10}$').hasMatch(value)) return 'Invalid postal code';
          return null;
        },
      ),
    );
  }
}