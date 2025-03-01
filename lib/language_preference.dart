import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreference {
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    String? countryCode = prefs.getString('country_code');

    if (languageCode != null) {
      return Locale(languageCode, countryCode);
    }
    return const Locale('ko', 'KR'); // Set Korean as default
  }
}
