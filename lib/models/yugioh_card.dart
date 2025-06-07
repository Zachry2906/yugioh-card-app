import 'dart:convert';

class YugiohCard {
  final int id;
  final String name;
  final String type;
  final String desc;
  final String? race;
  final String? attribute;
  final int? level;
  final int? atk;
  final int? def;
  final List<String> cardImages;
  final Map<String, String>? cardPrices;

  YugiohCard({
    required this.id,
    required this.name,
    required this.type,
    required this.desc,
    this.race,
    this.attribute,
    this.level,
    this.atk,
    this.def,
    required this.cardImages,
    this.cardPrices,
  });

  factory YugiohCard.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['card_images'] != null) {
      for (var image in json['card_images']) {
        images.add(image['image_url'] ?? '');
      }
    }

    Map<String, String>? prices;
    if (json['card_prices'] != null && json['card_prices'].isNotEmpty) {
      final priceData = json['card_prices'][0];
      prices = {
        'tcgplayer_price': priceData['tcgplayer_price']?.toString() ?? '0',
        'cardmarket_price': priceData['cardmarket_price']?.toString() ?? '0',
        'ebay_price': priceData['ebay_price']?.toString() ?? '0',
        'amazon_price': priceData['amazon_price']?.toString() ?? '0',
      };
    }

    return YugiohCard(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      desc: json['desc'] ?? '',
      race: json['race'],
      attribute: json['attribute'],
      level: json['level'],
      atk: json['atk'],
      def: json['def'],
      cardImages: images,
      cardPrices: prices,
    );
  }

  // Convert to database format
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'desc': desc,
      'race': race,
      'attribute': attribute,
      'level': level,
      'atk': atk,
      'def': def,
      'card_images': jsonEncode(cardImages),
      'card_prices': cardPrices != null ? jsonEncode(cardPrices) : null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // Create from database format
  factory YugiohCard.fromDatabase(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['card_images'] != null) {
      try {
        final imagesList = jsonDecode(json['card_images']) as List;
        images = imagesList.cast<String>();
      } catch (e) {
        print('Error parsing card images: $e');
      }
    }

    Map<String, String>? prices;
    if (json['card_prices'] != null) {
      try {
        final pricesMap = jsonDecode(json['card_prices']) as Map<String, dynamic>;
        prices = pricesMap.cast<String, String>();
      } catch (e) {
        print('Error parsing card prices: $e');
      }
    }

    return YugiohCard(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      desc: json['desc'] ?? '',
      race: json['race'],
      attribute: json['attribute'],
      level: json['level'],
      atk: json['atk'],
      def: json['def'],
      cardImages: images,
      cardPrices: prices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'desc': desc,
      'race': race,
      'attribute': attribute,
      'level': level,
      'atk': atk,
      'def': def,
      'card_images': cardImages,
      'card_prices': cardPrices,
    };
  }
}
