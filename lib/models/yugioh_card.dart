// Update model YugiohCard untuk menyimpan data harga
import 'dart:convert';

class YugiohCard {
  final int id;
  final String name;
  final String type;
  final String desc;
  final int? atk;
  final int? def;
  final int? level;
  final String? race;
  final String? attribute;
  final List<String> cardImages;
  final Map<String, dynamic>? cardPrices; // Tambahkan field untuk harga kartu

  YugiohCard({
    required this.id,
    required this.name,
    required this.type,
    required this.desc,
    this.atk,
    this.def,
    this.level,
    this.race,
    this.attribute,
    required this.cardImages,
    this.cardPrices, // Tambahkan parameter untuk harga kartu
  });

  factory YugiohCard.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['card_images'] != null) {
      for (var img in json['card_images']) {
        images.add(img['image_url'] ?? '');
      }
    }

    return YugiohCard(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      desc: json['desc'] ?? '',
      atk: json['atk'],
      def: json['def'],
      level: json['level'],
      race: json['race'],
      attribute: json['attribute'],
      cardImages: images,
      cardPrices: json['card_prices'] != null && json['card_prices'].isNotEmpty
          ? json['card_prices'][0]
          : null, // Ambil data harga dari API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'desc': desc,
      'atk': atk,
      'def': def,
      'level': level,
      'race': race,
      'attribute': attribute,
      'image_url': cardImages.isNotEmpty ? cardImages.first : '',
      'card_prices': cardPrices, // Tambahkan harga ke JSON
    };
  }

  factory YugiohCard.fromDatabase(Map<String, dynamic> map) {
    Map<String, dynamic>? prices;
    if (map['card_prices'] != null) {
      try {
        prices = Map<String, dynamic>.from(
            map['card_prices'] is String
                ? json.decode(map['card_prices'])
                : map['card_prices']
        );
      } catch (e) {
        prices = null;
      }
    }

    return YugiohCard(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      desc: map['desc'],
      atk: map['atk'],
      def: map['def'],
      level: map['level'],
      race: map['race'],
      attribute: map['attribute'],
      cardImages: [map['image_url'] ?? ''],
      cardPrices: prices,
    );
  }
}
