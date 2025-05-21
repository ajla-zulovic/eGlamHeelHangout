import 'package:flutter/material.dart';
import '../models/giveaway.dart';
import 'base_providers.dart';

class GiveawayProvider extends BaseProvider<Giveaway> {
  GiveawayProvider() : super("Giveaway");

  @override
  Giveaway fromJson(Map<String, dynamic> json) {
    return Giveaway.fromJson(json);
  }
}