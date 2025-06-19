import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/giveaway.dart';
import '../models/giveawaydto.dart';
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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _giveaways.isEmpty
              ? const Center(child: Text("No active giveaways available."))
              : ListView.builder(
                  itemCount: _giveaways.length,
                  itemBuilder: (context, index) {
                    final giveaway = _giveaways[index];
                    final bool hasParticipated = giveaway.isClosed; // TEMP dok ne dodaš pravo polje

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Row(
                        children: [
                            // Lijeva strana: Slika
                            ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                                height: 100,
                                width: 120,
                                child: FittedBox(
                                fit: BoxFit.cover,
                                child: imageFromBase64String(giveaway.giveawayProductImage),
                                ),
                            ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Sredina: Tekst
                            Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(
                                    giveaway.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
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

                            // Desno: Dugme
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
                                minimumSize: const Size(60, 40),
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
