
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../Ads_Code/ads_code.dart';
import '../constent.dart';
import '../model/Ads/ads.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  Future<Ads?> fetchAds() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.adsEndpoint}'),
        headers: AppConfig.headers,
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Ads.fromJson(data);
      } else {
        debugPrint('Ads API failed with status: ${response.statusCode}');
        return _getFallbackAds();
      }
    } catch (e) {
      debugPrint('Ads API error: $e');
      return _getFallbackAds();
    }
  }

  Ads _getFallbackAds() {
    // Fallback to local hardcoded data
    return Ads.fromJson(adsdata);
  }
}
