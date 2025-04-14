import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../modules/auth/controllers/auth_controller.dart';

class BmiController extends GetxController {
  final _bmi = 0.0.obs;
  double get bmi => _bmi.value;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    calculateBmi();
  }

  void calculateBmi() {
    final user = _authController.userModel.value;
    if (user != null) {
      double height = (user.height ?? 0) / 100;
      double weight = user.weight ?? 0;
      _bmi.value = weight / (height * height);
    }
  }

  String getBmiStatus() {
    if (bmi < 18.5) {
      return 'Zayıf';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Fazla Kilolu';
    } else {
      return 'Obez';
    }
  }

  Color getBmiColor() {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
