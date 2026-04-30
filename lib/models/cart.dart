enum CartItemType { oneTime, subscription }

enum SubscriptionFrequency { weekly, biWeekly, monthly }

class CartItem {
  CartItem({
    required this.sku,
    required this.productName,
    required this.pricePerUnit,
    required this.type,
    this.quantity = 1,
    this.frequency = SubscriptionFrequency.monthly,
  });

  final String sku;
  final String productName;
  final double pricePerUnit;
  final CartItemType type;
  int quantity;
  SubscriptionFrequency frequency;

  static const double subscriptionDiscountRate = 0.10;

  double get unitPrice => type == CartItemType.subscription
      ? pricePerUnit * (1 - subscriptionDiscountRate)
      : pricePerUnit;

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sku': sku,
        'productName': productName,
        'pricePerUnit': pricePerUnit,
        'type': type.name,
        'quantity': quantity,
        'frequency': frequency.name,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        sku: json['sku'] as String,
        productName: json['productName'] as String,
        pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
        type: CartItemType.values.firstWhere(
          (CartItemType v) => v.name == json['type'],
          orElse: () => CartItemType.oneTime,
        ),
        quantity: json['quantity'] as int? ?? 1,
        frequency: SubscriptionFrequency.values.firstWhere(
          (SubscriptionFrequency v) => v.name == json['frequency'],
          orElse: () => SubscriptionFrequency.monthly,
        ),
      );
}

class Cart {
  Cart({List<CartItem>? items}) : items = items ?? <CartItem>[];

  final List<CartItem> items;

  double get subtotal =>
      items.fold(0, (double sum, CartItem item) => sum + item.lineTotal);

  bool get hasSubscriptions =>
      items.any((CartItem i) => i.type == CartItemType.subscription);

  int get itemCount =>
      items.fold(0, (int sum, CartItem item) => sum + item.quantity);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'items': items.map((CartItem i) => i.toJson()).toList(),
      };

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        items: (json['items'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
