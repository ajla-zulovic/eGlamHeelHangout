import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/giveaway.dart';
import '../providers/giveaway_providers.dart';

class PastGiveawaysScreen extends StatefulWidget {
  const PastGiveawaysScreen({super.key});

  @override
  State<PastGiveawaysScreen> createState() => _PastGiveawaysScreenState();
}

class _PastGiveawaysScreenState extends State<PastGiveawaysScreen> {
  List<Giveaway> _pastGiveaways = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPastGiveaways();
  }

  Future<void> _loadPastGiveaways() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<GiveawayProvider>();
      final data = await provider.getFinishedWithWinner();

      setState(() {
        _pastGiveaways = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading past giveaways: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Past Giveaways")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pastGiveaways.isEmpty
              ? const Center(child: Text("No past giveaways with winners."))
              : ListView.builder(
                  itemCount: _pastGiveaways.length,
                  itemBuilder: (context, index) {
                    final g = _pastGiveaways[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.emoji_events, color: Colors.amber),
                        title: Text(g.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Winner: ${g.winnerName}"),
                            Text("Ended: ${DateFormat('yyyy-MM-dd').format(g.endDate)}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
