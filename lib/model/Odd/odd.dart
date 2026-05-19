// To parse this JSON data, do
//
//     final odd = oddFromJson(jsonString);

import 'dart:convert';

List<Odd> oddFromJson(String str) {
  final decoded = json.decode(str);
  final list = decoded is List ? decoded : decoded['odds'] ?? [];
  if (list is List) {
    return list.map<Odd>((item) => Odd.fromJson(item as Map<String, dynamic>)).toList();
  }
  return [];
}

String oddToJson(List<Odd> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Odd {
  Odd({
    this.bookmaker,
    this.market,
    this.selection,
    this.odd,
  });

  String? bookmaker;
  String? market;
  String? selection;
  String? odd;

  factory Odd.fromJson(Map<String, dynamic> json) => Odd(
        bookmaker: json['bookmaker']?.toString(),
        market: json['market']?.toString(),
        selection: json['selection']?.toString(),
        odd: json['odd']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'bookmaker': bookmaker,
        'market': market,
        'selection': selection,
        'odd': odd,
      };
}
