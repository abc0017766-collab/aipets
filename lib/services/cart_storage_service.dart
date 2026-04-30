import 'dart:convert';

import 'package:flutter_application_1/models/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartStorageService {
  String _key(String dogProfileId) => 'cart_$dogProfileId';

  Future<Cart> loadCart(String dogProfileId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key(dogProfileId));
    if (raw == null || raw.isEmpty) {
      return Cart();
    }
    return Cart.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveCart(String dogProfileId, Cart cart) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(dogProfileId), jsonEncode(cart.toJson()));
  }

  Future<void> clearCart(String dogProfileId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(dogProfileId));
  }
}
