import 'dart:convert';

import 'package:flutter_application_1/models/food_inventory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryStorageService {
  String _key(String dogProfileId) => 'inventory_$dogProfileId';

  Future<FoodInventory?> loadInventory(String dogProfileId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key(dogProfileId));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return FoodInventory.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveInventory(FoodInventory inventory) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(inventory.dogProfileId),
      jsonEncode(inventory.toJson()),
    );
  }

  Future<void> clearInventory(String dogProfileId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(dogProfileId));
  }
}
