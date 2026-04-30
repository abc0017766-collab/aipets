import 'package:flutter_application_1/models/product.dart';

class FeedingScheduleEntry {
  const FeedingScheduleEntry({
    required this.timeLabel,
    required this.portionGrams,
  });

  final String timeLabel;
  final int portionGrams;
}

class ReminderItem {
  const ReminderItem({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

class CarePlan {
  const CarePlan({
    required this.dailyCalories,
    required this.foodType,
    required this.feedingSchedule,
    required this.healthAlerts,
    required this.productSuggestions,
    required this.reminders,
  });

  final int dailyCalories;
  final String foodType;
  final List<FeedingScheduleEntry> feedingSchedule;
  final List<String> healthAlerts;
  final List<Product> productSuggestions;
  final List<ReminderItem> reminders;
}
