import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/calorie_needs_model.dart';
import '../../../data/models/user_model.dart';
import '../../../modules/auth/controllers/auth_controller.dart';

class CalorieNeedsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController = Get.find<AuthController>();

  final activityLevel = 'sedentary'.obs;
  final goal = 'maintain'.obs;
  final calculatedCalories = 0.0.obs;
  final isLoading = false.obs;
  final bmr = 0.0.obs;
  final tdee = 0.0.obs;

  final Map<String, double> activityMultipliers = {
    'sedentary': 1.2, // Hareketsiz yaşam
    'light': 1.375, // Hafif aktivite
    'moderate': 1.55, // Orta aktivite
    'active': 1.725, // Aktif
    'very_active': 1.9, // Çok aktif
  };

  final Map<String, double> goalMultipliers = {
    'lose': -500,  
    'maintain': 0,  
    'gain': 500,  
  };

  double calculateBMR(UserModel user) {
   
    double bmr;
    if (user.gender?.toLowerCase() == 'erkek') {
      bmr = (10 * (user.weight ?? 0)) +
          (6.25 * (user.height ?? 0)) -
          (5 * (user.age ?? 0)) +
          5;
    } else {
      bmr = (10 * (user.weight ?? 0)) +
          (6.25 * (user.height ?? 0)) -
          (5 * (user.age ?? 0)) -
          161;
    }
    return bmr;
  }

  double calculateTDEE(double bmr) {
    return bmr * activityMultipliers[activityLevel.value]!;
  }

  double calculateTargetCalories(double tdee) {
    return tdee + goalMultipliers[goal.value]!;
  }

  void setActivityLevel(String level) {
    activityLevel.value = level;
    calculateCalories();
  }

  void setGoal(String newGoal) {
    goal.value = newGoal;
    calculateCalories();
  }

  Future<void> calculateCalories() async {
    UserModel? user = _authController.userModel.value;
    if (user != null) {
      bmr.value = calculateBMR(user);
      tdee.value = calculateTDEE(bmr.value);
      calculatedCalories.value = calculateTargetCalories(tdee.value);
    }
  }

  Future<void> saveCalorieNeeds() async {
    try {
      isLoading.value = true;
      UserModel? user = _authController.userModel.value;
      if (user != null) {
        double bmr = calculateBMR(user);
        double tdee = calculateTDEE(bmr);
        double targetCalories = calculateTargetCalories(tdee);

        String userId = _auth.currentUser?.uid ?? '';
        CalorieNeedsModel calorieNeeds = CalorieNeedsModel(
          userId: userId,
          bmr: bmr,
          tdee: tdee,
          activityLevel: activityLevel.value,
          goal: goal.value,
          targetCalories: targetCalories,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('calorie_needs')
            .doc(userId)
            .set(calorieNeeds.toJson());

        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade600,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Başarıyla Kaydedildi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kalori hedefiniz güncellendi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();  
                        Get.back();  
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tamam',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Hata Oluştu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kalori hedefi kaydedilirken bir hata oluştu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tamam',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    calculateCalories();
  }
}
