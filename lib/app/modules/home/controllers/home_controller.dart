import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/meal_model.dart';
import '../../auth/controllers/auth_controller.dart';

class Meal {
  final String name;
  final String details;
  final int calories;
  final String type;

  Meal({
    required this.name,
    required this.details,
    required this.calories,
    required this.type,
  });
}

class HomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final breakfastMeals = <MealModel>[].obs;
  final lunchMeals = <MealModel>[].obs;
  final dinnerMeals = <MealModel>[].obs;
  final snackMeals = <MealModel>[].obs;

  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;

  final totalCalories = 0.obs;
  final targetCalories = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
     
    final now = DateTime.now();
    selectedDay.value = DateTime(now.year, now.month, now.day);
    focusedDay.value = selectedDay.value;

    
    ever(selectedDay, (_) => listenToMeals());

     
    listenToMeals();
    calculateTotalCalories();
    listenToCalorieNeeds();
  }

  void listenToCalorieNeeds() {
    final userId = _authController.firebaseUser.value?.uid;
    if (userId != null) {
      _firestore.collection('calorie_needs').doc(userId).snapshots().listen(
          (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          targetCalories.value = data['targetCalories'] != null
              ? (data['targetCalories'] as num).toDouble()
              : 0.0;
        } else {
          targetCalories.value = 0.0;
        }
      }, onError: (error) {
        print('Error listening to calorie needs: $error');
        targetCalories.value = 0.0;
      });
    }
  }

  void listenToMeals() {
    final userId = _authController.firebaseUser.value?.uid;
    if (userId != null) {
      final startOfDay = DateTime(
        selectedDay.value.year,
        selectedDay.value.month,
        selectedDay.value.day,
      );
      final endOfDay = DateTime(
        selectedDay.value.year,
        selectedDay.value.month,
        selectedDay.value.day,
        23,
        59,
        59,
      );

      print(
          'Fetching meals for date: ${startOfDay.toString()} to ${endOfDay.toString()}');

      _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThanOrEqualTo: endOfDay)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          print('Received ${snapshot.docs.length} meals from Firestore');

          final meals = snapshot.docs.map((doc) {
            final data = doc.data();
            print('Meal data: $data');
            return MealModel.fromJson(data);
          }).toList();

          breakfastMeals.value =
              meals.where((m) => m.mealType == 'Kahvaltı').toList();
          lunchMeals.value =
              meals.where((m) => m.mealType == 'Öğle Yemeği').toList();
          dinnerMeals.value =
              meals.where((m) => m.mealType == 'Akşam Yemeği').toList();
          snackMeals.value =
              meals.where((m) => m.mealType == 'Ara Öğün').toList();

          print(
              'Breakfast: ${breakfastMeals.length}, Lunch: ${lunchMeals.length}, Dinner: ${dinnerMeals.length}, Snack: ${snackMeals.length}');

          calculateTotalCalories();
          update();
        },
        onError: (error) => print('Error listening to meals: $error'),
      );
    }
  }

  void addMeal() {
   
    Get.toNamed('/add-meal');
  }

  void onDaySelected(DateTime selected, DateTime focused) {
     
    selectedDay.value = DateTime(selected.year, selected.month, selected.day);
    focusedDay.value = focused;
     
    listenToMeals();
  }

  void calculateTotalCalories() {
    totalCalories.value = (breakfastMeals.fold(
                0, (sum, meal) => sum + meal.calories.toInt()) +
            lunchMeals.fold(0, (sum, meal) => sum + meal.calories.toInt()) +
            dinnerMeals.fold(0, (sum, meal) => sum + meal.calories.toInt()) +
            snackMeals.fold(0, (sum, meal) => sum + meal.calories.toInt()))
        .toInt();
  }

  List<MealModel> get meals {
    return [...breakfastMeals, ...lunchMeals, ...dinnerMeals, ...snackMeals];
  }

  Future<void> deleteMealsByType(String mealType) async {
    try {
      final userId = Get.find<AuthController>().firebaseUser.value?.uid;
      print('Deleting meals - UserId: $userId, MealType: $mealType');
      
      if (userId != null) {
        // Daha basit bir sorgu kullanıyoruz
        final snapshot = await FirebaseFirestore.instance
            .collection('meals')
            .where('userId', isEqualTo: userId)
            .where('mealType', isEqualTo: mealType)
            .get();

        print('Found ${snapshot.docs.length} meals to delete');

         
        for (var doc in snapshot.docs) {
          print('Deleting meal: ${doc.id}');
          await doc.reference.delete();
        }

        
        listenToMeals();

        // Başarılı mesajı göster
        Get.snackbar(
          'Başarılı',
          '$mealType öğününe ait tüm yemekler silindi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Silme hatası detayı: $e');
      Get.snackbar(
        'Hata',
        'Öğün silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  
  void updateTotalCalories() {
    int total = 0;
    total += breakfastMeals.fold(0, (sum, meal) => sum + meal.calories.round());
    total += lunchMeals.fold(0, (sum, meal) => sum + meal.calories.round());
    total += snackMeals.fold(0, (sum, meal) => sum + meal.calories.round());
    total += dinnerMeals.fold(0, (sum, meal) => sum + meal.calories.round());
    totalCalories.value = total;
  }
}
