import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/giveaway.dart';
import '../models/giveawaydto.dart';
import '../screens/past_giveaway_screen.dart';
import '../providers/giveaway_providers.dart';
import '../utils/utils.dart';
import 'giveaway_participant_screen.dart';

class ActiveGiveawaysScreen extends StatefulWidget {
  const ActiveGiveawaysScreen({super.key});

  @override
  State<ActiveGiveawaysScreen> createState() => _ActiveGiveawaysScreenState();
}

class _ActiveGiveawaysScreenState extends State<ActiveGiveawaysScreen> {
  List<Giveaway> _giveaways = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGiveaways();
  }

  Future<void> _loadGiveaways() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<GiveawayProvider>();
      final result = await provider.getActive();
      setState(() {
        _giveaways = result;
        _isLoading = false;
      });
    }  catch (e) {
  setState(() => _isLoading = false);
  final msg = e.toString().replaceFirst('Exception: ', ''); 
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.red),
  );
}
  }

  void _handleParticipation(Giveaway giveaway) async {
    GiveawayNotification dto = GiveawayNotification(
      giveawayId: giveaway.giveawayId,
      title: giveaway.title,
      color: giveaway.color,
      heelHeight: giveaway.heelHeight,
      description: giveaway.description,
      giveawayProductImage: giveaway.giveawayProductImage,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiveawayParticipationScreen(giveaway: dto),
      ),
    );

    if (result == true) {
      _loadGiveaways(); // Reload in case user just participated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Active Giveaways'),
  backgroundColor: Colors.grey[800],
  foregroundColor: Colors.white,
  actions: [
    IconButton(
      icon: const Icon(Icons.history),
      tooltip: "Past Giveaways",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PastGiveawaysScreen()),
        );
      },
    ),
  ],
),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _giveaways.isEmpty
              ? const Center(child: Text("No active giveaways available."))
              : ListView.builder(
                  itemCount: _giveaways.length,
                  itemBuilder: (context, index) {
                    final giveaway = _giveaways[index];
                    final bool hasParticipated = giveaway.isClosed; 

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Row(
                        children: [
                            
                           ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 80,
                              width: 100,
                              color: Colors.grey[200],
                              child: giveaway.giveawayProductImage != null
                                  ? Image.memory(
                                      base64Decode(giveaway.giveawayProductImage!),
                                      fit: BoxFit.contain, 
                                    )
                                  : const Icon(Icons.image_not_supported),
                            ),
                          ),

                            const SizedBox(width: 12),
                            
                          
                            Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(
                                    giveaway.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text("Heel: ${giveaway.heelHeight.toStringAsFixed(1)} cm | ${giveaway.color}"),
                                Text(
                                    "Ends: ${DateFormat('yyyy-MM-dd').format(giveaway.endDate)}",
                                    style: const TextStyle(color: Colors.redAccent),
                                ),
                                ],
                            ),
                            ),

                            
                            ElevatedButton(
                            onPressed: giveaway.isClosed
                                ? null
                                : () {
                                    final dto = GiveawayNotification(
                                        giveawayId: giveaway.giveawayId,
                                        title: giveaway.title,
                                        color: giveaway.color,
                                        heelHeight: giveaway.heelHeight,
                                        description: giveaway.description,
                                        giveawayProductImage: giveaway.giveawayProductImage,
                                    );

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (_) => GiveawayParticipationScreen(giveaway: dto),
                                        ),
                                    );
                                    },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: giveaway.isClosed ? Colors.grey : Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(80, 36),
                                 shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), 
                                ),
                            ),
                            child: Text(giveaway.isClosed ? "Joined" : "Participate"),
                            )
                        ],
                        ),
                    ),
                    );


                  },
                ),
    );
  }
}