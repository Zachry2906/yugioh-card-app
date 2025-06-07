class Deck {
  int? id;
  final String name;
  final String description;
  final DateTime createdAt;
  int cardCount;

  Deck({
    this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.cardCount = 0,
  });

  // Convert to database format
  Map<String, dynamic> toDatabase() {
    return {
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from database format
  factory Deck.fromDatabase(Map<String, dynamic> json) {
    return Deck(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      cardCount: 0, // Will be set separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'card_count': cardCount,
    };
  }
}
