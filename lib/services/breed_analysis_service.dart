import 'package:flutter_application_1/models/breed_analysis.dart';

abstract class BreedAnalysisApi {
  Future<BreedAnalysisResult> analyzeBreed(BreedAnalysisRequest request);
}

class MockBreedAnalysisApi implements BreedAnalysisApi {
  @override
  Future<BreedAnalysisResult> analyzeBreed(BreedAnalysisRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final String normalized = request.imagePath.toLowerCase();

    if (normalized.contains('lab')) {
      return const BreedAnalysisResult(
        primaryBreed: 'Labrador Retriever',
        confidence: 0.91,
        bodyCondition: 'Healthy',
        notes: <String>[
          'Broad head and short coat suggest Labrador traits.',
          'Keep a weekly weight log for food calibration.',
        ],
      );
    }

    if (normalized.contains('beagle')) {
      return const BreedAnalysisResult(
        primaryBreed: 'Beagle',
        confidence: 0.89,
        bodyCondition: 'Slightly overweight',
        notes: <String>[
          'Body shape suggests moderate excess weight.',
          'Consider lower-calorie treats and more walk reminders.',
        ],
      );
    }

    if (normalized.contains('shepherd')) {
      return const BreedAnalysisResult(
        primaryBreed: 'German Shepherd',
        confidence: 0.86,
        bodyCondition: 'Healthy',
        notes: <String>[
          'Long muzzle and upright ears indicate shepherd lineage.',
          'High-activity feeding recommendations are a likely fit.',
        ],
      );
    }

    return const BreedAnalysisResult(
      primaryBreed: 'Mixed Breed',
      confidence: 0.72,
      bodyCondition: 'Needs manual review',
      notes: <String>[
        'Placeholder image analysis could not match a specific breed confidently.',
        'Connect a real vision API to improve breed detection and body scoring.',
      ],
    );
  }
}
