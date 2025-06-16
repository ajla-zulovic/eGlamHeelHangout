import 'package:flutter/material.dart';
import '../models/giveaway.dart';
import '../providers/giveaway_providers.dart';
import 'package:intl/intl.dart';
import '../models/search_result.dart';
import '../utils/utils.dart';
import 'dart:convert';

class GiveawaysManageScreen extends StatefulWidget {
  const GiveawaysManageScreen({Key? key}) : super(key: key);

  @override
  State<GiveawaysManageScreen> createState() => _GiveawaysManageScreenState();
}

class _GiveawaysManageScreenState extends State<GiveawaysManageScreen> {
  GiveawayProvider _giveawayProvider = GiveawayProvider();
  List<Giveaway> _giveaways = [];
  bool _isLoading = true;
  String _selectedFilter = "All"; 

  int _allCount = 0;
  int _activeCount = 0;
  int _inactiveCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAllCounts();
    _loadGiveaways();
  }

  Future<void> _loadAllCounts() async {
    try {
      // All
      SearchResult<Giveaway> allData = await _giveawayProvider.getFiltered(isActive: null);
      // Active
      SearchResult<Giveaway> activeData = await _giveawayProvider.getFiltered(isActive: true);
      // Inactive
      SearchResult<Giveaway> inactiveData = await _giveawayProvider.getFiltered(isActive: false);

      setState(() {
        _allCount = allData.count ?? 0;
        _activeCount = activeData.count ?? 0;
        _inactiveCount = inactiveData.count ?? 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading counts: $e"),
         backgroundColor: Colors.red,
         ),
      );
    }
  }

  Future<void> _loadGiveaways() async {
    setState(() {
      _isLoading = true;
    });

    bool? isActive;
    if (_selectedFilter == "Active") {
      isActive = true;
    } else if (_selectedFilter == "Inactive") {
      isActive = false;
    } else {
      isActive = null;
    }

    try {
      SearchResult<Giveaway> data = await _giveawayProvider.getFiltered(isActive: isActive);
      setState(() {
        _giveaways = data.result;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading giveaways: $e"),
         backgroundColor: Colors.red,
         ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateWinner(int giveawayId) async {
    try {
      await _giveawayProvider.pickWinner(giveawayId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Winner generated successfully!"),
         backgroundColor: Colors.green,
         ),
      );
      // Ponovno ucitaj i countove i podatke nakon generisanja
      await _loadAllCounts();
      await _loadGiveaways();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating winner."),
         backgroundColor: Colors.red,
         ),
      );
    }
  }

  Widget _buildFilterButton(String label, int count) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.white,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: () {
          setState(() {
            _selectedFilter = label;
          });
          _loadGiveaways();
        },
        child: Text(
          "$label ($count)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
        
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterButton("All", _allCount),
              _buildFilterButton("Active", _activeCount),
              _buildFilterButton("Inactive", _inactiveCount),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _giveaways.isEmpty
                    ? const Center(child: Text("No giveaways found."))
                    : ListView.builder(
                        itemCount: _giveaways.length,
                        itemBuilder: (context, index) {
                          final giveaway = _giveaways[index];
                          final now = DateTime.now();

                       
            
                        final canGenerateWinner = giveaway.endDate.isBefore(now) &&
                        (giveaway.winnerName == null);



                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ListTile(
                              leading: giveaway.giveawayProductImage.isNotEmpty
                                  ? imageFromBase64String(giveaway.giveawayProductImage)
                                  : const Icon(Icons.image_not_supported),
                              title: Text(giveaway.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("End date: ${DateFormat('yyyy-MM-dd').format(giveaway.endDate)}"),
                                  Text("Winner: ${giveaway.winnerName ?? 'No winner yet'}"),
                                ],
                              ),
                              trailing: canGenerateWinner
                                ? OutlinedButton.icon(
                                    onPressed: () => _generateWinner(giveaway.giveawayId!),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      side: const BorderSide(color: Colors.green, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.emoji_events, size: 20), 
                                    label: const Text(
                                      "Generate Winner",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  )
                                : null,

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
