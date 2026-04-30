import 'dart:async';
import 'dart:convert';

import 'package:flutter_application_1/models/breed_analysis.dart';
import 'package:http/http.dart' as http;

abstract class BreedAnalysisApi {
  Future<BreedAnalysisResult> analyzeBreed(BreedAnalysisRequest request);
}

class HuggingFaceBreedAnalysisApi implements BreedAnalysisApi {
  HuggingFaceBreedAnalysisApi({
    required this.apiToken,
    this.modelId = 'dima806/dog-breeds-image-classification',
    http.Client? client,
  }) : _client = client ?? http.Client();

  factory HuggingFaceBreedAnalysisApi.fromEnvironment() {
    return HuggingFaceBreedAnalysisApi(
      apiToken: const String.fromEnvironment('HF_API_TOKEN'),
      modelId: const String.fromEnvironment(
        'HF_MODEL_ID',
        defaultValue: 'dima806/dog-breeds-image-classification',
      ),
    );
  }

  final String apiToken;
  final String modelId;
  final http.Client _client;

  @override
  Future<BreedAnalysisResult> analyzeBreed(BreedAnalysisRequest request) async {
    if (apiToken.trim().isEmpty) {
      throw StateError('HF_API_TOKEN is missing.');
    }
    if (request.imageBytes == null || request.imageBytes!.isEmpty) {
      throw ArgumentError('Image bytes are required for real AI analysis.');
    }

    final Uri uri = Uri.parse('https://api-inference.huggingface.co/models/$modelId');

    final http.Response response = await _client
        .post(
          uri,
          headers: <String, String>{
            'Authorization': 'Bearer $apiToken',
            'Content-Type': 'application/octet-stream',
          },
          body: request.imageBytes,
        )
        .timeout(const Duration(seconds: 20));

    final dynamic decoded = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      throw StateError('HF API error ${response.statusCode}: ${response.body}');
    }

    if (decoded is Map<String, dynamic> && decoded['error'] != null) {
      throw StateError(decoded['error'].toString());
    }

    if (decoded is! List<dynamic> || decoded.isEmpty) {
      throw StateError('HF API returned unexpected prediction format.');
    }

    final List<Map<String, dynamic>> predictions = decoded
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> item) => item.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          ),
        )
        .cast<Map<String, dynamic>>()
        .toList();

    predictions.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final double sa = (a['score'] as num?)?.toDouble() ?? 0;
        final double sb = (b['score'] as num?)?.toDouble() ?? 0;
        return sb.compareTo(sa);
      });

    if (predictions.isEmpty) {
      throw StateError('HF API did not return usable predictions.');
    }

    final Map<String, dynamic> best = predictions.first;
    final String rawLabel = (best['label']?.toString() ?? 'Unknown Breed').trim();
    final String normalizedLabel = rawLabel.replaceAll('_', ' ');
    final double confidence = ((best['score'] as num?)?.toDouble() ?? 0).clamp(0, 1);

    final String bodyCondition = confidence >= 0.75 ? 'Likely healthy' : 'Needs manual review';

    return BreedAnalysisResult(
      primaryBreed: normalizedLabel,
      confidence: confidence,
      bodyCondition: bodyCondition,
      notes: <String>[
        'Analyzed by Hugging Face model: $modelId',
        'Confidence ${(confidence * 100).toStringAsFixed(1)}%. Verify manually for mixed breeds.',
      ],
    );
  }
}

class FallbackBreedAnalysisApi implements BreedAnalysisApi {
  FallbackBreedAnalysisApi({
    required this.primary,
    required this.fallback,
  });

  final BreedAnalysisApi primary;
  final BreedAnalysisApi fallback;

  @override
  Future<BreedAnalysisResult> analyzeBreed(BreedAnalysisRequest request) async {
    try {
      return await primary.analyzeBreed(request);
    } catch (_) {
      final BreedAnalysisResult mockResult = await fallback.analyzeBreed(request);
      return BreedAnalysisResult(
        primaryBreed: mockResult.primaryBreed,
        confidence: mockResult.confidence,
        bodyCondition: mockResult.bodyCondition,
        notes: <String>[
          ...mockResult.notes,
          'Real API unavailable, using local fallback analysis.',
        ],
      );
    }
  }
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
