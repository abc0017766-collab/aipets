import 'dart:convert';

import 'package:flutter_application_1/models/dog_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorageService {
  static const String _profileKey = 'dog_profile';

  Future<DogProfile?> loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DogProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(DogProfile profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}
