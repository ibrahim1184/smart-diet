import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp için import

class MealModel {
  final String id;
  final String name;
  final String mealType;  
  final double calories;
  final String userId;
  final DateTime createdAt;
  final String details;

  MealModel({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.userId,
    required this.createdAt,
    this.details = '',
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      name: json['name'],
      mealType: json['mealType'],
      calories: json['calories'].toDouble(),
      userId: json['userId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      details: json['details'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType,
      'calories': calories,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'details': details,
    };
  }
}
