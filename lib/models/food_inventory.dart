class FoodInventory {
  const FoodInventory({
    required this.dogProfileId,
    required this.productName,
    required this.productSku,
    required this.purchasedGrams,
    required this.remainingGrams,
    required this.dailyPortionGrams,
    required this.purchasedAt,
    required this.lastUpdatedAt,
  });

  final String dogProfileId;
  final String productName;
  final String productSku;
  final double purchasedGrams;
  final double remainingGrams;
  final int dailyPortionGrams;
  final DateTime purchasedAt;
  final DateTime lastUpdatedAt;

  double get daysRemaining =>
      dailyPortionGrams > 0 ? remainingGrams / dailyPortionGrams : 0;

  bool get isLowStock => daysRemaining <= 5;

  bool get shouldReorder => daysRemaining <= 7;

  DateTime get estimatedDepletionDate =>
      lastUpdatedAt.add(Duration(days: daysRemaining.floor()));

  FoodInventory copyWith({
    double? remainingGrams,
    double? purchasedGrams,
    String? productName,
    String? productSku,
    int? dailyPortionGrams,
    DateTime? purchasedAt,
    DateTime? lastUpdatedAt,
  }) {
    return FoodInventory(
      dogProfileId: dogProfileId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      purchasedGrams: purchasedGrams ?? this.purchasedGrams,
      remainingGrams: remainingGrams ?? this.remainingGrams,
      dailyPortionGrams: dailyPortionGrams ?? this.dailyPortionGrams,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dogProfileId': dogProfileId,
      'productName': productName,
      'productSku': productSku,
      'purchasedGrams': purchasedGrams,
      'remainingGrams': remainingGrams,
      'dailyPortionGrams': dailyPortionGrams,
      'purchasedAt': purchasedAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory FoodInventory.fromJson(Map<String, dynamic> json) {
    return FoodInventory(
      dogProfileId: json['dogProfileId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String,
      purchasedGrams: (json['purchasedGrams'] as num).toDouble(),
      remainingGrams: (json['remainingGrams'] as num).toDouble(),
      dailyPortionGrams: json['dailyPortionGrams'] as int,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }
}
