class Product {
  const Product({
    required this.sku,
    required this.name,
    required this.price,
    required this.tags,
    required this.description,
    this.isSubscriptionEligible = true,
  });

  final String sku;
  final String name;
  final double price;
  final List<String> tags;
  final String description;
  final bool isSubscriptionEligible;
}
