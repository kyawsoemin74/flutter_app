import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

/// Utility class for handling country flags using the country_flags package.
/// Provides scalable and maintainable flag rendering with robust error handling.
class CountryFlagHelper {
  // Fallback mapping for country names to ISO codes (minimal, for edge cases)
  static const Map<String, String> _countryNameToCode = {
    'spain': 'ES',
    'japan': 'JP',
    'argentina': 'AR',
    'england': 'GB',
    'germany': 'DE',
    'france': 'FR',
    'italy': 'IT',
    'brazil': 'BR',
    'portugal': 'PT',
    'saudi-arabia': 'SA',
    'belgium': 'BE',
    'croatia': 'HR',
    'denmark': 'DK',
    'sweden': 'SE',
    'norway': 'NO',
    'finland': 'FI',
    'poland': 'PL',
    'austria': 'AT',
    'switzerland': 'CH',
    'greece': 'GR',
    'turkey': 'TR',
    'russia': 'RU',
    'ukraine': 'UA',
    'serbia': 'RS',
    'czech republic': 'CZ',
    'slovakia': 'SK',
    'hungary': 'HU',
    'romania': 'RO',
    'bulgaria': 'BG',
    'slovenia': 'SI',
    'bosnia and herzegovina': 'BA',
    'montenegro': 'ME',
    'kosovo': 'XK',
    'albania': 'AL',
    'north macedonia': 'MK',
    'mexico': 'MX',
    'usa': 'US',
    'canada': 'CA',
    'australia': 'AU',
    'new zealand': 'NZ',
    'south korea': 'KR',
    'china': 'CN',
    'india': 'IN',
    'egypt': 'EG',
    'morocco': 'MA',
    'tunisia': 'TN',
    'algeria': 'DZ',
    'nigeria': 'NG',
    'ghana': 'GH',
    'cameroon': 'CM',
    'senegal': 'SN',
    'ivory coast': 'CI',
    'south africa': 'ZA',
    'uruguay': 'UY',
    'chile': 'CL',
    'colombia': 'CO',
    'ecuador': 'EC',
    'peru': 'PE',
    'venezuela': 'VE',
    'paraguay': 'PY',
    'bolivia': 'BO',
    'iran': 'IR',
    'iraq': 'IQ',
    'saudi arabia': 'SA',
    'united arab emirates': 'AE',
    'qatar': 'QA',
    'kuwait': 'KW',
    'oman': 'OM',
    'bahrain': 'BH',
    'jordan': 'JO',
    'lebanon': 'LB',
    'syria': 'SY',
    'israel': 'IL',
    'palestine': 'PS',
    'thailand': 'TH',
    'vietnam': 'VN',
    'indonesia': 'ID',
    'malaysia': 'MY',
    'singapore': 'SG',
    'philippines': 'PH',
    'hong kong': 'HK',
    'taiwan': 'TW',
    // ASEAN + Asia
    'myanmar': 'MM',
    'burma': 'MM',
    'laos': 'LA',
    'cambodia': 'KH',
    'brunei': 'BN',
    'timor-leste': 'TL',
    'uzbekistan': 'UZ',
    'kazakhstan': 'KZ',
    'kyrgyzstan': 'KG',
    'tajikistan': 'TJ',
    'turkmenistan': 'TM',
    'afghanistan': 'AF',
    'pakistan': 'PK',
    'bangladesh': 'BD',
    'sri lanka': 'LK',
    'nepal': 'NP',
    'maldives': 'MV',
    'mongolia': 'MN',
    'north korea': 'KP',

    // Middle East
    'yemen': 'YE',

    // Europe
    'netherlands': 'NL',
    'ireland': 'IE',
    'northern ireland': 'GB',
    'scotland': 'GB',
    'wales': 'GB',
    'luxembourg': 'LU',
    'iceland': 'IS',
    'estonia': 'EE',
    'latvia': 'LV',
    'lithuania': 'LT',
    'cyprus': 'CY',
    'malta': 'MT',
    'andorra': 'AD',
    'liechtenstein': 'LI',
    'san marino': 'SM',
    'monaco': 'MC',
    'faroe islands': 'FO',
    'gibraltar': 'GI',
    'georgia': 'GE',
    'armenia': 'AM',
    'azerbaijan': 'AZ',
    'belarus': 'BY',
    'moldova': 'MD',

    // Africa
    'ethiopia': 'ET',
    'kenya': 'KE',
    'uganda': 'UG',
    'tanzania': 'TZ',
    'zambia': 'ZM',
    'zimbabwe': 'ZW',
    'mozambique': 'MZ',
    'angola': 'AO',
    'namibia': 'NA',
    'botswana': 'BW',
    'madagascar': 'MG',
    'libya': 'LY',
    'sudan': 'SD',
    'dr congo': 'CD',
    'congo': 'CG',
    'gabon': 'GA',
    'mali': 'ML',
    'guinea': 'GN',
    'burkina faso': 'BF',
    'cape verde': 'CV',

    // Americas
    'guatemala': 'GT',
    'honduras': 'HN',
    'el salvador': 'SV',
    'costa rica': 'CR',
    'nicaragua': 'NI',
    'panama': 'PA',
    'jamaica': 'JM',
    'trinidad and tobago': 'TT',
    'dominican republic': 'DO',
    'haiti': 'HT',
    'cuba': 'CU',
    'puerto rico': 'PR',

    // Oceania
    'fiji': 'FJ',
    'papua new guinea': 'PG',
    'samoa': 'WS',
    'tahiti': 'PF',
    'solomon islands': 'SB',
    'vanuatu': 'VU',
    'new caledonia': 'NC',
      };

  /// Builds a country flag widget from the given flag URL and country name.
  /// Uses the country_flags package for scalable, maintainable flag rendering.
  ///
  /// Attempts to extract the country code from the flag URL first.
  /// If that fails, tries to map the country name to an ISO code.
  /// Falls back to a flag icon if no valid code is found or package fails.
  ///
  /// Returns a 20x20 sized flag image or an Icons.flag fallback.
  static Widget buildCountryFlag({
    String? flagUrl,
    String? countryName,
    double width = 20.0,
    double height = 20.0,
  }) {
    final countryCode = _extractCountryCode(flagUrl, countryName);

    if (countryCode == null || countryCode.isEmpty) {
      debugPrint('CountryFlag: No valid country code found for URL: $flagUrl, Country: $countryName');
      return Icon(Icons.flag, color: Colors.white70, size: width);
    }

    try {
      return CountryFlags.flag(
        countryCode,
        height: height,
        width: width,
        borderRadius: 2.0,
      );
    } catch (e) {
      debugPrint('CountryFlag: Error rendering flag for code $countryCode: $e');
      return Icon(Icons.flag, color: Colors.white70, size: width);
    }
  }

  /// Extracts a valid 2-letter uppercase country code from URL or country name.
  /// Returns null if no valid code is found.
  static String? _extractCountryCode(String? flagUrl, String? countryName) {
    // First, try to extract from URL
    if (flagUrl != null && flagUrl.trim().isNotEmpty) {
      final codeFromUrl = _extractCodeFromUrl(flagUrl);
      if (codeFromUrl != null) return codeFromUrl.toUpperCase();
    }

    // Fallback: try to map from country name
    if (countryName != null && countryName.trim().isNotEmpty) {
      final normalizedName = countryName.trim().toLowerCase();
      final code = _countryNameToCode[normalizedName];
      if (code != null) return code;
    }

    return null;
  }

  /// Extracts a 2-letter country code from a flag URL.
  /// Supports various URL formats and file extensions.
  static String? _extractCodeFromUrl(String url) {
    try {
      final normalizedUrl = url.toLowerCase().trim();

      // Handle different URL formats
      final uri = Uri.tryParse(normalizedUrl);
      String path;
      if (uri != null && uri.path.isNotEmpty) {
        path = uri.path;
      } else {
        // Fallback for non-standard URLs
        path = normalizedUrl;
      }

      // Split by common separators
      final segments = path.split(RegExp(r'[\/\\]')).where((s) => s.isNotEmpty).toList();

      if (segments.isEmpty) return null;

      // Try the last segment first
      String candidate = segments.last;

      // Remove query parameters and fragments
      candidate = candidate.split('?').first.split('#').first;

      // Remove file extensions
      candidate = candidate
          .replaceAll(RegExp(r'\.(svg|png|jpg|jpeg|gif|webp)$'), '')
          .toLowerCase();

      // Clean up: remove non-alphanumeric except hyphens/underscores
      candidate = candidate.replaceAll(RegExp(r'[^a-z0-9\-_]'), '');

      // Check if it's exactly 2 letters
      if (candidate.length == 2 && RegExp(r'^[a-z]{2}$').hasMatch(candidate)) {
        return candidate;
      }

      // If not, try to find a 2-letter code within the string
      final match = RegExp(r'\b[a-z]{2}\b').firstMatch(candidate);
      if (match != null) {
        return match.group(0);
      }

      // Try other segments if last didn't work
      for (int i = segments.length - 2; i >= 0; i--) {
        candidate = segments[i]
            .split('?').first.split('#').first
            .replaceAll(RegExp(r'\.(svg|png|jpg|jpeg|gif|webp)$'), '')
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\-_]'), '');

        if (candidate.length == 2 && RegExp(r'^[a-z]{2}$').hasMatch(candidate)) {
          return candidate;
        }
      }

      return null;
    } catch (e) {
      debugPrint('CountryFlag: Error extracting code from URL $url: $e');
      return null;
    }
  }
}