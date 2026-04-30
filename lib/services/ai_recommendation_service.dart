import 'dart:math';

import 'package:flutter_application_1/models/care_plan.dart';
import 'package:flutter_application_1/models/dog_profile.dart';
import 'package:flutter_application_1/models/product.dart';

class AiRecommendationService {
  CarePlan generatePlan({
    required DogProfile profile,
    required List<Product> catalog,
  }) {
    final int calories = _estimateDailyCalories(profile);
    final List<FeedingScheduleEntry> schedule = _buildFeedingSchedule(profile, calories);
    final String foodType = _resolveFoodType(profile);
    final List<String> riskAlerts = _healthAlerts(profile);
    final List<String> needTags = _needTags(profile, riskAlerts);
    final List<Product> matches = _matchProducts(catalog, needTags);

    return CarePlan(
      dailyCalories: calories,
      foodType: foodType,
      feedingSchedule: schedule,
      healthAlerts: riskAlerts,
      productSuggestions: matches,
      reminders: <ReminderItem>[
        const ReminderItem(
          title: 'Morning feeding',
          message: 'Serve first meal and refresh water.',
        ),
        const ReminderItem(
          title: 'Evening feeding',
          message: 'Serve second meal and check appetite.',
        ),
        const ReminderItem(
          title: 'Weekly weight check',
          message: 'Log weight to improve AI recommendations.',
        ),
      ],
    );
  }

  int _estimateDailyCalories(DogProfile dog) {
    final double rer = (70 * pow(dog.weightKg, 0.75)).toDouble();
    double factor;

    if (dog.isPuppy) {
      factor = 2.5;
    } else if (dog.isSenior) {
      factor = 1.2;
    } else {
      switch (dog.activityLevel) {
        case ActivityLevel.low:
          factor = 1.2;
          break;
        case ActivityLevel.medium:
          factor = 1.5;
          break;
        case ActivityLevel.high:
          factor = 1.8;
          break;
      }
    }

    return (rer * factor).round();
  }

  List<FeedingScheduleEntry> _buildFeedingSchedule(DogProfile dog, int calories) {
    final int mealsPerDay = dog.isPuppy ? 3 : 2;
    final int kcalPerMeal = (calories / mealsPerDay).round();
    final int gramsPerMeal = ((kcalPerMeal / 380) * 100).round();

    if (mealsPerDay == 3) {
      return <FeedingScheduleEntry>[
        FeedingScheduleEntry(timeLabel: '07:00', portionGrams: gramsPerMeal),
        FeedingScheduleEntry(timeLabel: '13:00', portionGrams: gramsPerMeal),
        FeedingScheduleEntry(timeLabel: '19:00', portionGrams: gramsPerMeal),
      ];
    }

    return <FeedingScheduleEntry>[
      FeedingScheduleEntry(timeLabel: '08:00', portionGrams: gramsPerMeal),
      FeedingScheduleEntry(timeLabel: '18:00', portionGrams: gramsPerMeal),
    ];
  }

  String _resolveFoodType(DogProfile dog) {
    if (dog.healthConditions.any((String c) => c.contains('allergy'))) {
      return 'Hypoallergenic dry food';
    }
    if (dog.isPuppy) {
      return 'Puppy growth dry food';
    }
    if (dog.isSenior) {
      return 'Senior joint-support food';
    }
    return 'Balanced high-protein dry food';
  }

  List<String> _healthAlerts(DogProfile dog) {
    final List<String> alerts = <String>[];
    final String breed = dog.breed.toLowerCase();

    if (breed.contains('labrador') && dog.weightKg > 36) {
      alerts.add('Weight is high for Labrador range. Increase exercise and track portions.');
    }
    if (breed.contains('beagle') && dog.weightKg > 15) {
      alerts.add('Beagle may be overweight. Consider lower-calorie treats.');
    }
    if (dog.isSenior) {
      alerts.add('Senior dog: keep joint support and regular vet checks.');
    }
    if (alerts.isEmpty) {
      alerts.add('No immediate risk flags. Keep tracking weight weekly.');
    }

    return alerts;
  }

  List<String> _needTags(DogProfile dog, List<String> alerts) {
    final Set<String> tags = <String>{};

    if (dog.isPuppy) {
      tags.add('puppy');
      tags.add('growth');
    } else if (dog.isSenior) {
      tags.add('senior');
      tags.add('joint-support');
    } else {
      tags.add('adult');
    }

    if (dog.breed.toLowerCase().contains('labrador')) {
      tags.add('large-breed');
    }

    if (dog.activityLevel == ActivityLevel.high) {
      tags.add('high-protein');
    }

    if (dog.healthConditions.any((String c) => c.contains('sensitive')) ||
        alerts.any((String alert) => alert.toLowerCase().contains('overweight'))) {
      tags.add('sensitive');
      tags.add('weight-control');
    }

    if (dog.healthConditions.any((String c) => c.contains('allergy'))) {
      tags.add('hypoallergenic');
    }

    return tags.toList();
  }

  List<Product> _matchProducts(List<Product> catalog, List<String> needTags) {
    final List<Product> sorted = <Product>[...catalog];

    sorted.sort((Product a, Product b) {
      final int scoreA = a.tags.where((String tag) => needTags.contains(tag)).length;
      final int scoreB = b.tags.where((String tag) => needTags.contains(tag)).length;
      return scoreB.compareTo(scoreA);
    });

    return sorted.take(3).toList();
  }
}
