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

  CardFieldInputDetails? _card;
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
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                       final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value)) return 'Invalid email format';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final phoneRegex = RegExp(r'^\d{6,15}$');
                        if (!phoneRegex.hasMatch(value)) return 'Invalid phone number format';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(labelText: 'Postal Code'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final postalRegex = RegExp(r'^[A-Za-z0-9 \-]{3,10}$');
                        if (!postalRegex.hasMatch(value)) return 'Invalid postal code format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Card Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    CardField(
                      onCardChanged: (card) => setState(() => _card = card),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate() || _card == null || !_card!.complete) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Complete all fields and card info.")),
                                );
                                return;
                              }

                              setState(() => _isProcessing = true);

                              try {
                                final billingDetails = BillingDetails(
                                  name: _fullNameController.text,
                                  email: _emailController.text,
                                  address: Address(
                                    city: _cityController.text,
                                    country: 'BA',
                                    line1: _addressController.text,
                                    line2: '',
                                    postalCode: _postalCodeController.text,
                                    state: '',
                                  ),
                                );

                                final paymentMethod = await Stripe.instance.createPaymentMethod(
                                  params: PaymentMethodParams.card(
                                    paymentMethodData: PaymentMethodData(
                                      billingDetails: billingDetails,
                                    ),
                                  ),
                                );

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

                                if (createdOrder == null) {
                                  throw Exception("Order creation failed");
                                }

                                final payment = PaymentCreate(
                                  orderId: createdOrder.orderId!,
                                  totalAmount: (createdOrder.totalPrice * 100).toInt(),
                                  paymentMethodId: paymentMethod.id!,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Payment error: $e"), backgroundColor: Colors.red),
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
}
