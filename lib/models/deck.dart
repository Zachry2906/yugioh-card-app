import 'package:tugasakhirpraktikum/models/yugioh_card.dart';

class Deck {
  final int? id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<YugiohCard> cards;

  Deck({
    this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.cards = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Deck copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<YugiohCard>? cards,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      cards: cards ?? this.cards,
    );
  }
}