import 'package:flutter_application_1/models/care_plan.dart';
import 'package:flutter_application_1/models/food_inventory.dart';

class InventoryService {
  /// Total daily portion in grams summed from the AI care plan schedule.
  int dailyPortionGramsFromPlan(CarePlan plan) {
    return plan.feedingSchedule.fold(
      0,
      (int total, FeedingScheduleEntry entry) => total + entry.portionGrams,
    );
  }

  /// Create a new inventory record when a bag is first logged.
  FoodInventory createInventory({
    required String dogProfileId,
    required String productName,
    required String productSku,
    required double bagWeightKg,
    required int dailyPortionGrams,
  }) {
    final double grams = bagWeightKg * 1000;
    final DateTime now = DateTime.now();
    return FoodInventory(
      dogProfileId: dogProfileId,
      productName: productName,
      productSku: productSku,
      purchasedGrams: grams,
      remainingGrams: grams,
      dailyPortionGrams: dailyPortionGrams,
      purchasedAt: now,
      lastUpdatedAt: now,
    );
  }

  /// Deduct one day's worth of food.
  FoodInventory consumeDay(FoodInventory inventory) {
    final double updated =
        (inventory.remainingGrams - inventory.dailyPortionGrams).clamp(0, double.infinity);
    return inventory.copyWith(
      remainingGrams: updated,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Log a new bag purchase: restocks on top of any remaining amount.
  FoodInventory restock(FoodInventory inventory, double newBagWeightKg) {
    final double added = newBagWeightKg * 1000;
    return inventory.copyWith(
      purchasedGrams: inventory.purchasedGrams + added,
      remainingGrams: inventory.remainingGrams + added,
      purchasedAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
  }
}
