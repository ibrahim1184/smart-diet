import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/meal_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/controllers/home_controller.dart';

class AddMealController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final selectedMeal = ''.obs;
  final selectedMealType = ''.obs;
  final isLoading = false.obs;

  final searchController = TextEditingController();
  final gramController = TextEditingController();
  final servingSize = RxDouble(1.0);
  final searchResults = RxList<Map<String, dynamic>>([]);
  final searchQuery = RxString('');

   
  final selectedFood = Rxn<Map<String, dynamic>>();
  final caloriesPerServing = RxDouble(0.0);
  final proteinPerServing = RxDouble(0.0);
  final carbsPerServing = RxDouble(0.0);
  final fatPerServing = RxDouble(0.0);

   
  final Map<String, String> foodTranslations = {
    
    'elma': 'apple',
    'muz': 'banana',
    'portakal': 'orange',
    'üzüm': 'grape',
    'çilek': 'strawberry',
    'karpuz': 'watermelon',
    'kavun': 'melon',
    'armut': 'pear',
    'kiraz': 'cherry',
    'şeftali': 'peach',
    'kayısı': 'apricot',
    'erik': 'plum',
    'incir': 'fig',
    'nar': 'pomegranate',
    'mandalina': 'tangerine',
    'ananas': 'pineapple',

     
    'domates': 'tomato',
    'salatalık': 'cucumber',
    'havuç': 'carrot',
    'patates': 'potato',
    'biber': 'pepper',
    'patlıcan': 'eggplant',
    'kabak': 'zucchini',
    'marul': 'lettuce',
    'ıspanak': 'spinach',
    'brokoli': 'broccoli',
    'karnabahar': 'cauliflower',
    'bezelye': 'peas',
    'mısır': 'corn',
    'fasulye': 'beans',

     
    'süt': 'milk',
    'yoğurt': 'yogurt',
    'peynir': 'cheese',
    'ayran': 'ayran',
    'tereyağı': 'butter',
    'kaymak': 'cream',
    'dondurma': 'ice cream',

     
    'tavuk': 'chicken',
    'et': 'meat',
    'balık': 'fish',
    'köfte': 'meatball',
    'sucuk': 'sausage',
    'sosis': 'sausage',
    'pastırma': 'pastrami',
    'hindi': 'turkey',
    'kuzu eti': 'lamb',
    'dana eti': 'beef',

     
    'ekmek': 'bread',
    'pirinç': 'rice',
    'makarna': 'pasta',
    'bulgur': 'bulgur',
    'yulaf': 'oats',
    'börek': 'pastry',
    'poğaça': 'pogaca',
    'simit': 'simit',
    'kraker': 'cracker',
    'kurabiye': 'cookie',

    
    'yumurta': 'egg',
    'zeytin': 'olive',
    'bal': 'honey',
    'reçel': 'jam',
    'tahin': 'tahini',
    'pekmez': 'molasses',

     
    'kek': 'cake',
    'çikolata': 'chocolate',
    'baklava': 'baklava',
    'künefe': 'kunefe',
    'sütlaç': 'rice pudding',
    'kazandibi': 'kazandibi',
    'profiterol': 'profiterole',
    'muhallebi': 'pudding',

    
    'çay': 'tea',
    'kahve': 'coffee',
    'su': 'water',
    'meyve suyu': 'fruit juice',
    'kola': 'cola',
    
    'limonata': 'lemonade',

    
    'cips': 'chips',
    'fındık': 'hazelnut',
    'fıstık': 'peanut',
    'badem': 'almond',
    'ceviz': 'walnut',
    'kuru üzüm': 'raisin',
    'kuruyemiş': 'nuts'
  };

  void selectFood(Map<String, dynamic> food) {
    selectedFood.value = food;
    searchController.clear();
    searchResults.clear();
    gramController.text = '100';  
    servingSize.value = 1.0;
    updateNutrients();
    // Klavyeyi gizle
    Get.focusScope?.unfocus();
  }

  void updateNutrients() {
    if (selectedFood.value != null) {
      // 100g için olan değerleri porsiyon miktarına göre hesapla
      final calories = double.tryParse(selectedFood.value!['calories']) ?? 0;
      final protein =
          double.tryParse(selectedFood.value!['nutrients']['protein']) ?? 0;
      final carbs =
          double.tryParse(selectedFood.value!['nutrients']['carbs']) ?? 0;
      final fat = double.tryParse(selectedFood.value!['nutrients']['fat']) ?? 0;

      caloriesPerServing.value = calories * servingSize.value;
      proteinPerServing.value = protein * servingSize.value;
      carbsPerServing.value = carbs * servingSize.value;
      fatPerServing.value = fat * servingSize.value;
    }
    update();
  }

  void updateServingSize(double grams) {
    servingSize.value = grams / 100;
    updateNutrients();
  }

  void increaseServing() {
    final newGrams = (servingSize.value * 100 + 10).toStringAsFixed(0);
    gramController.text = newGrams;
    servingSize.value += 0.1;
    updateNutrients();
  }

  void decreaseServing() {
    if (servingSize.value > 0.1) {
      final newGrams = (servingSize.value * 100 - 10).toStringAsFixed(0);
      gramController.text = newGrams;
      servingSize.value -= 0.1;
      updateNutrients();
    }
  }

  Future<void> searchFood(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      isLoading.value = false;
      return;
    }

    
    isLoading.value = true;
    searchResults.clear();  
    searchQuery.value = query;

    
    await Future.delayed(const Duration(seconds: 2));

    
    if (query != searchController.text || searchController.text.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      
      String englishQuery = query.toLowerCase();
      foodTranslations.forEach((turkish, english) {
        if (query.toLowerCase().contains(turkish)) {
          englishQuery = english;
        }
      });

      final response = await http.get(
        Uri.parse(
            'https://api.calorieninjas.com/v1/nutrition?query=${Uri.encodeComponent(englishQuery)}'),
        headers: {
          'X-Api-Key': 'DkWmP5IqZyKHeCKx3w8OjQ==o2Pz6zOIkp0xGD7O',
        },
      );

      // Son bir kontrol daha yap
      if (query != searchController.text || searchController.text.isEmpty) {
        isLoading.value = false;
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        // API'den gelen sonuçları işle
        final results = items.map((item) {
          String turkishName = item['name'] ?? 'İsimsiz Ürün';
          foodTranslations.forEach((turkish, english) {
            if (item['name'].toString().toLowerCase().contains(english)) {
              turkishName = turkish;
            }
          });

          return {
            'name': turkishName.substring(0, 1).toUpperCase() +
                turkishName.substring(1),
            'brand': '',
            'calories': item['calories']?.toStringAsFixed(0) ?? '0',
            'serving_size': '${item['serving_size_g']}g',
            'nutrients': {
              'protein': item['protein_g']?.toStringAsFixed(1) ?? '0',
              'carbs': item['carbohydrates_total_g']?.toStringAsFixed(1) ?? '0',
              'fat': item['fat_total_g']?.toStringAsFixed(1) ?? '0',
            }
          };
        }).toList();

        searchResults.value = results;
      }
    } catch (e) {
      print('Error searching food: $e');
    } finally {
      if (query == searchController.text) {
        isLoading.value = false;
      }
    }
  }

  Future<void> addMeal() async {
    if (selectedMeal.isEmpty || selectedMealType.isEmpty) {
      Get.snackbar(
        'Hata',
        'Lütfen yemek ve öğün seçiniz',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      
      final meal = MealModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: selectedMeal.value,
        mealType: selectedMealType.value,
        calories: 0, // API'den alınacak kalori değeri
        userId: _authController.firebaseUser.value!.uid,
        createdAt: DateTime.now(),
      );

     
      await _firestore.collection('meals').doc(meal.id).set(meal.toJson());

      Get.back();  
      Get.snackbar(
        'Başarılı',
        'Yemek başarıyla eklendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Yemek eklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMeal() async {
    if (selectedFood.value == null && selectedMealType.value.isEmpty) {
      Get.snackbar(
        'Uyarı',
        'Lütfen yemek ve öğün seçin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (selectedFood.value == null) {
      Get.snackbar(
        'Uyarı',
        'Lütfen bir yemek seçin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (selectedMealType.value.isEmpty) {
      Get.snackbar(
        'Uyarı',
        'Lütfen bir öğün seçin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isLoading.value = true;

      final homeController = Get.find<HomeController>();
      final selectedDate = homeController.selectedDay.value;

       
      String mealType = '';
      switch (selectedMealType.value) {
        case 'Kahvaltı':
          mealType = 'Kahvaltı';
          break;
        case 'Öğle':
          mealType = 'Öğle Yemeği';
          break;
        case 'Akşam':
          mealType = 'Akşam Yemeği';
          break;
        case 'Atıştırmalık':
          mealType = 'Ara Öğün';
          break;
      }

      final now = DateTime.now();
      final mealDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        now.hour,
        now.minute,
      );

      final meal = MealModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: selectedFood.value!['name'],
        mealType: mealType,  
        calories: caloriesPerServing.value,
        userId: _authController.firebaseUser.value!.uid,
        createdAt: mealDateTime,
        details: '${gramController.text}g',
      );

      await _firestore.collection('meals').doc(meal.id).set(meal.toJson());
      
       
      homeController.listenToMeals();

      Get.back();

      Get.snackbar(
        'Başarılı',
        'Yemek başarıyla eklendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      print('Error saving meal: $e');
      Get.snackbar('Hata', 'Yemek eklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchFood(searchController.text);
    });
    gramController.text = '100';  
  }

  @override
  void onClose() {
    searchController.dispose();
    gramController.dispose();
    super.onClose();
  }
}
