import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/providers/order_providers.dart';
import 'package:eglamheelhangout_mobile/models/order.dart';

class UserOrdersListScreen extends StatefulWidget {
  const UserOrdersListScreen({super.key});

  @override
  State<UserOrdersListScreen> createState() => _UserOrdersListScreenState();
}

class _UserOrdersListScreenState extends State<UserOrdersListScreen> {
  late OrderProvider _orderProvider;
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _orderProvider = context.read<OrderProvider>();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      var orders = await _orderProvider.getMyOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading orders: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("You have no orders."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final date = order.orderDate?.toLocal();
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ExpansionTile(
                        leading: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                        title: Text(
                          "Purchase dated ${date != null ? "${date.day}/${date.month}/${date.year}" : "N/A"}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total: \$${order.totalPrice.toStringAsFixed(2)}"),
                              Text("Time: ${date?.toString().split('.')[0] ?? "N/A"}"),
                              Text("Payment: ${order.paymentMethod}"),
                            ],
                          ),
                        ),
                        children: order.items.map((item) {
                          return ListTile(
                            title: Text(item.productName ?? ''),
                            subtitle: Text("Size: ${item.size} • Quantity: ${item.quantity}"),
                            trailing: Text("\$${(item.pricePerUnit * item.quantity).toStringAsFixed(2)}"),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}
