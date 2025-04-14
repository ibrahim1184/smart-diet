import 'package:cloud_firestore/cloud_firestore.dart';

class CalorieNeedsModel {
  String? id;
  String userId;
  double bmr;  
  double tdee;  
  String activityLevel;  
  String goal;  
  double targetCalories; 
  DateTime createdAt;

  CalorieNeedsModel({
    this.id,
    required this.userId,
    required this.bmr,
    required this.tdee,
    required this.activityLevel,
    required this.goal,
    required this.targetCalories,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bmr': bmr,
      'tdee': tdee,
      'activityLevel': activityLevel,
      'goal': goal,
      'targetCalories': targetCalories,
      'createdAt': createdAt,
    };
  }

  factory CalorieNeedsModel.fromJson(Map<String, dynamic> json) {
    return CalorieNeedsModel(
      id: json['id'],
      userId: json['userId'],
      bmr: json['bmr'].toDouble(),
      tdee: json['tdee'].toDouble(),
      activityLevel: json['activityLevel'],
      goal: json['goal'],
      targetCalories: json['targetCalories'].toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
