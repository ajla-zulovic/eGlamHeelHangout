import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/models/notifications.dart';
import 'package:eglamheelhangout_mobile/providers/notifications_providers.dart';
import 'package:eglamheelhangout_mobile/screens/product_details_screen.dart';
import 'package:eglamheelhangout_mobile/screens/giveaway_participant_screen.dart';
import 'package:eglamheelhangout_mobile/providers/product_providers.dart';
import 'package:eglamheelhangout_mobile/providers/giveaway_providers.dart';
import 'package:eglamheelhangout_mobile/models/giveawaydto.dart';


class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<Notifications> _notifications = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
   setState(() => _isLoading = true);
  final provider = context.read<NotificationProvider>();
  final notifs = await provider.getUnreadNotifications();
  setState(() {
    _notifications = notifs;
    _isLoading = false;
  });
  }

  Future<void> _markAsRead(int id) async {
    await context.read<NotificationProvider>().markAsRead(id);
    _loadNotifications();
  }

  void _showWinnerDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Giveaway Winner!"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body:_isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text("No unread notifications."))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications, size: 30, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.message ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text("Sent: ${notif.dateSent?.toString().split(".").first ?? ""}"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (notif.giveawayId != null && notif.notificationType == "NewGiveaway")
                          ElevatedButton(
                             onPressed: () async {
                              try {
                                final g = await context.read<GiveawayProvider>().getById(notif.giveawayId!);
                                final dto = GiveawayNotification(
                                  giveawayId: g.giveawayId,
                                  title: g.title,
                                  description: g.description ?? '',
                                  heelHeight: (g.heelHeight ?? 0).toDouble(),
                                  color: g.color ?? '',
                                  giveawayProductImage: g.giveawayProductImage,
                                );

                                if (!mounted) return;
                                final participated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => GiveawayParticipationScreen(giveaway: dto)),
                                );
                                await _markAsRead(notif.notificationId!);

                                if (participated == true) {
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to open giveaway: $e')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(60, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Participate"),
                          ),
                       if (notif.productId != null)
                        ElevatedButton(
                          onPressed: () async {
                            final product = await context.read<ProductProvider>().getById(notif.productId!);

                            if (product == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to load product details.")),
                              );
                              return;
                            }

                            
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            );

                            
                            await _markAsRead(notif.notificationId!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(110, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("View"),
                        ),

                      ],
                    ),
                  ),
                );

              },
            ),
    );
  }
}
