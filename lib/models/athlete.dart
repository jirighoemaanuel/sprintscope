import 'package:cloud_firestore/cloud_firestore.dart';

class Athlete {
  final String id;
  final String fullName;
  final String gender;
  final int age;
  final String personalBest;
  final String? notes;
  final String coachId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> videoIds; // List of video IDs associated with this athlete

  Athlete({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.personalBest,
    this.notes,
    required this.coachId,
    required this.createdAt,
    required this.updatedAt,
    this.videoIds = const [],
  });

  factory Athlete.fromMap(Map<String, dynamic> map, String id) {
    return Athlete(
      id: id,
      fullName: map['fullName'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      personalBest: map['personalBest'] ?? '',
      notes: map['notes'],
      coachId: map['coachId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      videoIds: List<String>.from(map['videoIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'personalBest': personalBest,
      'notes': notes,
      'coachId': coachId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'videoIds': videoIds,
    };
  }

  Athlete copyWith({
    String? id,
    String? fullName,
    String? gender,
    int? age,
    String? personalBest,
    String? notes,
    String? coachId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? videoIds,
  }) {
    return Athlete(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      personalBest: personalBest ?? this.personalBest,
      notes: notes ?? this.notes,
      coachId: coachId ?? this.coachId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      videoIds: videoIds ?? this.videoIds,
    );
  }
}
