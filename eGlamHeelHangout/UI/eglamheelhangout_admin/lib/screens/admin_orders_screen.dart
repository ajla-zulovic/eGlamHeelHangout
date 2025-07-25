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

 final TextEditingController _usernameController = TextEditingController();
  String? _selectedStatus;
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  
  Future<void> _loadOrders({String? username, String? status}) async {
    try {
      var provider = context.read<OrderProvider>();
      final filter = <String, dynamic>{};
      if (username != null && username.isNotEmpty) {
        filter['username'] = username;
      }
      if (status != null && status.isNotEmpty) {
        filter['orderStatus'] = status;
      }

      var data = await provider.get(filter: filter);
      setState(() {
        _orders = data.result;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    _usernameController.clear();
    _selectedStatus = null;
    _loadOrders();
  }



  Future<void> _changeOrderStatus(int orderId, String newStatus) async {
    try {
      var provider = context.read<OrderProvider>();
      await provider.updateOrderStatus(orderId, newStatus);
      await _loadOrders();

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

  Future<void> _confirmAndDelete(int orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Order"),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        var provider = context.read<OrderProvider>();
        await provider.delete(orderId);
        await _loadOrders();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Order deleted successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete order: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
    ),
    body: Column(
      children: [
       Padding(
  padding: const EdgeInsets.all(12.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
  
    Row(
  children: [
  Expanded(
  flex: 3,
  child: SizedBox(
    height: 40,
    child: TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        hintText: "Search for username...",
        prefixIcon: const Icon(Icons.search, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  ),
),

    const SizedBox(width: 12),

    Expanded(
  flex: 2,
  child: SizedBox(
    height: 40,
    child: DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        hintText: "Select Status",
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      items: ['Pending', 'Delivered', 'Canceled']
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedStatus = value),
    ),
  ),
),

    const SizedBox(width: 12),

    // BUTTON
    SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: () {
          _loadOrders(
            username: _usernameController.text,
            status: _selectedStatus,
          );
        },
        icon: const Icon(Icons.search, size: 18),
        label: const Text("Search", style: TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 10), // Visina 36px
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    ),
  ],
),

      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _resetFilters,
          child: const Text(
            "Reset Filters",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ],
  ),
),
        const Divider(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inbox, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            "No orders available",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Once users make a purchase, their orders will appear here.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
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
                                    title: Text(item.productName ?? 'N/A'),
                                    subtitle: Text("Size: ${item.size} | Qty: ${item.quantity}"),
                                    trailing: Text("€${(item.pricePerUnit * item.quantity).toStringAsFixed(2)}"),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (order.orderStatus == "Pending") ...[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => _changeOrderStatus(order.orderId!, "Delivered"),
                                      child: const Text("Mark as Delivered"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => _changeOrderStatus(order.orderId!, "Canceled"),
                                      child: const Text("Cancel Order"),
                                    ),
                                  ],
                                  if (order.orderStatus == "Delivered" || order.orderStatus == "Canceled") ...[
                                    TextButton(
                                      onPressed: () => _confirmAndDelete(order.orderId!),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                      child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}

}
