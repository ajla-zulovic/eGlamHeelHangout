import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_providers.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      var provider = context.read<OrderProvider>();
      var data = await provider.getAllOrders();
      setState(() {
        _orders = data;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }
Future<void> _changeOrderStatus(int orderId, String newStatus) async {
  try {
    var provider = context.read<OrderProvider>();
    await provider.updateOrderStatus(orderId, newStatus);
    await _loadOrders(); // Refresh list after update

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to "$newStatus"!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update order status: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ExpansionTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.blue),
                    title: Text("Purchase dated ${order.orderDate != null ? order.orderDate!.toLocal().toString() : 'N/A'}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Username: ${order.username}"),
                        Text("Total: €${order.totalPrice}"),
                        Text("Status: ${order.orderStatus}"),
                        Text("Payment: ${order.paymentMethod}"),
                      ],
                    ),
                    children: [
                      Column(
                        children: order.items.map((item) {
                          return ListTile(
                            title: Text("${item.productName}"),
                            subtitle: Text("Size: ${item.size} | Qty: ${item.quantity}"),
                            trailing: Text("€${(item.pricePerUnit * item.quantity).toStringAsFixed(2)}"),
                          );
                        }).toList(),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: order.orderStatus == "Pending"
                          ? [
                              ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), 
                                ),
                              ),
                              onPressed: () => _changeOrderStatus(order.orderId!, "Delivered"),
                              child: Text("Mark as Delivered"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _changeOrderStatus(order.orderId!, "Canceled"),
                              child: Text("Cancel Order"),
                            ),

                            ]
                          : [],
                    ),

                      SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
