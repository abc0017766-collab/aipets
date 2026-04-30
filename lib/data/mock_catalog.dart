import 'package:flutter_application_1/models/product.dart';

const List<Product> mockCatalog = <Product>[
  Product(
    sku: 'FOOD-LB-HP-10KG',
    name: 'High Protein Large Breed Formula',
    price: 64.99,
    tags: <String>['large-breed', 'high-protein', 'adult'],
    description: 'Dry food for active large-breed adult dogs.',
  ),
  Product(
    sku: 'FOOD-SENIOR-JOINT-5KG',
    name: 'Senior Joint Support Formula',
    price: 52.49,
    tags: <String>['senior', 'joint-support', 'sensitive'],
    description: 'Gentle nutrition with glucosamine for aging dogs.',
  ),
  Product(
    sku: 'FOOD-PUPPY-GROWTH-5KG',
    name: 'Puppy Growth Starter',
    price: 39.99,
    tags: <String>['puppy', 'growth', 'high-protein'],
    description: 'Balanced growth formula for puppies.',
  ),
  Product(
    sku: 'SUPP-DIGEST-PLUS',
    name: 'Digestive Care Supplement',
    price: 24.95,
    tags: <String>['sensitive', 'supplement', 'digestion'],
    description: 'Daily probiotic blend for sensitive stomachs.',
  ),
  Product(
    sku: 'TREATS-LEAN-BITES',
    name: 'Lean Training Bites',
    price: 12.50,
    tags: <String>['weight-control', 'treats', 'adult'],
    description: 'Low-calorie treats for training sessions.',
    isSubscriptionEligible: false,
  ),
  Product(
    sku: 'FOOD-HYPO-CARE-8KG',
    name: 'Hypoallergenic Care Formula',
    price: 69.00,
    tags: <String>['hypoallergenic', 'sensitive', 'adult'],
    description: 'Limited ingredient recipe for allergy-prone dogs.',
  ),
];
