import 'package:flutter/material.dart';
import 'package:eglamheelhangout_mobile/models/giveaway.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:eglamheelhangout_mobile/utils/utils.dart';
import 'package:eglamheelhangout_mobile/providers/base_providers.dart';
import 'package:eglamheelhangout_mobile/providers/giveaway_providers.dart';

class GiveawayParticipationScreen extends StatefulWidget {
  final Giveaway giveaway;

  const GiveawayParticipationScreen({super.key, required this.giveaway});

  @override
  State<GiveawayParticipationScreen> createState() => _GiveawayParticipationScreenState();
}

class _GiveawayParticipationScreenState extends State<GiveawayParticipationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitParticipation() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isSubmitting = true;
  });

  try {
    final giveawayProvider = Provider.of<GiveawayProvider>(context, listen: false);

    await giveawayProvider.participate(
      giveawayId: widget.giveaway.giveawayId,
      size: int.parse(_sizeController.text),
      address: _addressController.text,
      postalCode: _postalCodeController.text,
      city: _cityController.text,
    );

    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Participation submitted!')));
    Navigator.of(context).pop();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() {
      _isSubmitting = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Participate in ${widget.giveaway.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Please fill in your details:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Shoe Size (36-46)'),
                validator: (value) {
                  final size = int.tryParse(value ?? '');
                  if (size == null || size < 36 || size > 46) {
                    return 'Enter size between 36 and 46';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (value) => value!.isEmpty ? 'Postal Code is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitParticipation,
                child: _isSubmitting ? CircularProgressIndicator(color: Colors.white) : Text('Submit Participation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
