import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app/dog_care_app.dart';
import 'package:flutter_application_1/models/cart.dart';
import 'package:flutter_application_1/models/food_inventory.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Onboarding screen loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const DogCareApp());
    await tester.pumpAndSettle();

    expect(find.text('AI Dog Care - Onboarding'), findsOneWidget);
    expect(find.text('Create your dog profile'), findsOneWidget);
    expect(find.text('Dog photo upload'), findsOneWidget);
    expect(find.text('Analyze Breed'), findsOneWidget);
    expect(find.text('Generate AI Care Plan'), findsOneWidget);
  });

  testWidgets('Inventory tab shows log purchase form', (WidgetTester tester) async {
    // Pre-load a saved dog profile so the app goes straight to dashboard.
    const String profileJson = '{'
        '"id":"test-1","ownerId":"owner-1","name":"Buddy","breed":"Labrador Retriever",'
        '"ageInMonths":24,"weightKg":28.0,"gender":"male","activityLevel":"medium",'
        '"healthConditions":[],"imagePath":null,"createdAt":"2026-01-01T00:00:00.000"'
        '}';

    SharedPreferences.setMockInitialValues(<String, Object>{
      'dog_profile': profileJson,
    });

    await tester.pumpWidget(const DogCareApp());
    await tester.pumpAndSettle();

    // Tap the Inventory bottom nav item.
    await tester.tap(find.byIcon(Icons.inventory_2));
    await tester.pumpAndSettle();

    expect(find.text('Log your first food purchase'), findsOneWidget);
    expect(find.text('Log purchase'), findsOneWidget);
  });

  testWidgets('Inventory tab shows bag status when inventory saved', (WidgetTester tester) async {
    final FoodInventory inv = FoodInventory(
      dogProfileId: 'test-2',
      productName: 'High Protein Large Breed',
      productSku: 'FOOD-LB-HP-10KG',
      purchasedGrams: 10000,
      remainingGrams: 6000,
      dailyPortionGrams: 400,
      purchasedAt: DateTime(2026, 4, 1),
      lastUpdatedAt: DateTime(2026, 4, 10),
    );

    const String profileJson = '{'
        '"id":"test-2","ownerId":"owner-1","name":"Max","breed":"Labrador Retriever",'
        '"ageInMonths":36,"weightKg":30.0,"gender":"male","activityLevel":"high",'
        '"healthConditions":[],"imagePath":null,"createdAt":"2026-01-01T00:00:00.000"'
        '}';

    SharedPreferences.setMockInitialValues(<String, Object>{
      'dog_profile': profileJson,
      'inventory_test-2': jsonEncode(inv.toJson()),
    });

    await tester.pumpWidget(const DogCareApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.inventory_2));
    await tester.pumpAndSettle();

    expect(find.text('Current bag'), findsOneWidget);
    expect(find.text('Product: High Protein Large Breed'), findsOneWidget);
    expect(find.text('Restock / new bag'), findsOneWidget);
  });

  testWidgets('Cart tab shows empty state when cart has no items', (WidgetTester tester) async {
    const String profileJson = '{'
        '"id":"test-3","ownerId":"owner-1","name":"Luna","breed":"Beagle",'
        '"ageInMonths":18,"weightKg":12.0,"gender":"female","activityLevel":"medium",'
        '"healthConditions":[],"imagePath":null,"createdAt":"2026-01-01T00:00:00.000"'
        '}';

    SharedPreferences.setMockInitialValues(<String, Object>{
      'dog_profile': profileJson,
    });

    await tester.pumpWidget(const DogCareApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    expect(find.text('Your smart cart is empty'), findsOneWidget);
    expect(find.text('Add products from the Store tab.'), findsOneWidget);
  });

  testWidgets('Cart tab shows items and checkout button when cart has items',
      (WidgetTester tester) async {
    const String profileJson = '{'
        '"id":"test-4","ownerId":"owner-1","name":"Rex","breed":"German Shepherd",'
        '"ageInMonths":48,"weightKg":35.0,"gender":"male","activityLevel":"high",'
        '"healthConditions":[],"imagePath":null,"createdAt":"2026-01-01T00:00:00.000"'
        '}';

    final Cart cart = Cart(items: <CartItem>[
      CartItem(
        sku: 'FOOD-LB-HP-10KG',
        productName: 'High Protein Large Breed Formula',
        pricePerUnit: 64.99,
        type: CartItemType.subscription,
        quantity: 1,
        frequency: SubscriptionFrequency.monthly,
      ),
    ]);

    SharedPreferences.setMockInitialValues(<String, Object>{
      'dog_profile': profileJson,
      'cart_test-4': jsonEncode(cart.toJson()),
    });

    await tester.pumpWidget(const DogCareApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('High Protein Large Breed Formula'), findsOneWidget);
    expect(find.text('Confirm & Subscribe'), findsOneWidget);
  });
}
