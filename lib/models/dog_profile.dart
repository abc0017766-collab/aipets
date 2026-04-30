enum DogGender { male, female }

enum ActivityLevel { low, medium, high }

class DogProfile {
  DogProfile({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.breed,
    required this.ageInMonths,
    required this.weightKg,
    required this.gender,
    required this.activityLevel,
    this.healthConditions = const <String>[],
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String ownerId;
  final String name;
  final String breed;
  final int ageInMonths;
  final double weightKg;
  final DogGender gender;
  final ActivityLevel activityLevel;
  final List<String> healthConditions;
  final String? imagePath;
  final DateTime createdAt;

  bool get isPuppy => ageInMonths < 12;
  bool get isSenior => ageInMonths >= 84;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      'ageInMonths': ageInMonths,
      'weightKg': weightKg,
      'gender': gender.name,
      'activityLevel': activityLevel.name,
      'healthConditions': healthConditions,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DogProfile.fromJson(Map<String, dynamic> json) {
    return DogProfile(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      ageInMonths: json['ageInMonths'] as int,
      weightKg: (json['weightKg'] as num).toDouble(),
      gender: DogGender.values.firstWhere(
        (DogGender value) => value.name == json['gender'],
        orElse: () => DogGender.male,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (ActivityLevel value) => value.name == json['activityLevel'],
        orElse: () => ActivityLevel.medium,
      ),
      healthConditions: (json['healthConditions'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic value) => value.toString())
          .toList(),
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
