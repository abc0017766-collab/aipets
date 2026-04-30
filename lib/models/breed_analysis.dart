class BreedAnalysisRequest {
  const BreedAnalysisRequest({
    required this.imagePath,
    required this.dogName,
    this.ownerNotes,
  });

  final String imagePath;
  final String dogName;
  final String? ownerNotes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'imagePath': imagePath,
      'dogName': dogName,
      'ownerNotes': ownerNotes,
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
