import 'dart:typed_data';

class BreedAnalysisRequest {
  const BreedAnalysisRequest({
    required this.imagePath,
    required this.dogName,
    this.ownerNotes,
    this.imageBytes,
  });

  final String imagePath;
  final String dogName;
  final String? ownerNotes;
  final Uint8List? imageBytes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'imagePath': imagePath,
      'dogName': dogName,
      'ownerNotes': ownerNotes,
      'hasImageBytes': imageBytes != null,
    };
  }
}

class BreedAnalysisResult {
  const BreedAnalysisResult({
    required this.primaryBreed,
    required this.confidence,
    required this.bodyCondition,
    required this.notes,
  });

  final String primaryBreed;
  final double confidence;
  final String bodyCondition;
  final List<String> notes;
}
