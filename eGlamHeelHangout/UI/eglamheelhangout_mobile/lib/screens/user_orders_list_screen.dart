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
  Color _statusColor(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'delivered':
      return Colors.green;
    case 'canceled':
      return Colors.red;
    default:
      return Colors.orange;
  }
}

Widget _statusPill(String? s) {
  final c = _statusColor(s);
  final text = (s ?? 'Unknown');
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.5)),
    ),
    child: Text(
      text,
      style: TextStyle(color: c, fontWeight: FontWeight.w600),
    ),
  );
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
                            Row(
                              children: [
                                const Text("Status: "),
                                _statusPill(order.orderStatus), 
                              ],
                            ),
                          ],
                        ),
                      ),
                      children: [
                
                        ...order.items.map((item) {
                          return ListTile(
                            title: Text(item.productName ?? ''),
                            subtitle: Text("Size: ${item.size} • Quantity: ${item.quantity}"),
                            trailing: Text("\$${(item.pricePerUnit * item.quantity).toStringAsFixed(2)}"),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        if ((order.orderStatus ?? '').toLowerCase() == 'canceled')
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.10),
                              border: Border.all(color: Colors.red.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(Icons.info_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Your order was canceled. If this was unexpected, please contact us at +387 62 000 000.",
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
  );
}

}
