import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/models/giveawaydto.dart';
import 'package:eglamheelhangout_mobile/providers/giveaway_providers.dart';

class GiveawayParticipationScreen extends StatefulWidget {
  final GiveawayNotification giveaway;

  const GiveawayParticipationScreen({super.key, required this.giveaway});

  @override
  State<GiveawayParticipationScreen> createState() =>
      _GiveawayParticipationScreenState();
}

class _GiveawayParticipationScreenState
    extends State<GiveawayParticipationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitParticipation() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.giveaway.giveawayId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid giveaway!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final giveawayProvider =
          Provider.of<GiveawayProvider>(context, listen: false);

      await giveawayProvider.participate({
        "giveawayId": widget.giveaway.giveawayId,
        "size": int.parse(_sizeController.text),
        "address": _addressController.text.trim(),
        "postalCode": _postalCodeController.text.trim(),
        "city": _cityController.text.trim(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participation submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, Widget content) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          content
        ]),
      ),
    );
  }

  Widget _buildGiveawayInfo() {
    return Column(
      children: [
        Center(
          child: Text(
            'Welcome to our exciting new giveaway! We’re thrilled to have you join the fun. Good luck to everyone, may the odds be in your favor!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.giveaway.giveawayProductImage != null)
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(widget.giveaway.giveawayProductImage!),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Heel Height: ${widget.giveaway.heelHeight.toStringAsFixed(1)} cm',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                'Color: ${widget.giveaway.color}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Text(
                widget.giveaway.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _sizeController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Shoe Size (36–46)'),
            validator: (value) {
              final size = int.tryParse(value ?? '');
              if (size == null || size < 36 || size > 46) {
                return 'Enter a number between 36 and 46';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: (value) =>
                value!.isEmpty ? 'Address is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _postalCodeController,
            decoration: const InputDecoration(labelText: 'Postal Code'),
            validator: (value) =>
                value!.isEmpty ? 'Postal Code is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City'),
            validator: (value) =>
                value!.isEmpty ? 'City is required' : null,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitParticipation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Participate in ${widget.giveaway.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection('Giveaway Info', _buildGiveawayInfo()),
            _buildSection('Participation Form', _buildFormFields()),
          ],
        ),
      ),
    );
  }
}
