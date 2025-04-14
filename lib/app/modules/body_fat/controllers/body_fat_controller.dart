import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../modules/auth/controllers/auth_controller.dart';

class BodyFatController extends GetxController {
  final _bodyFat = 0.0.obs;
  double get bodyFat => _bodyFat.value;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    calculateBodyFat();
  }

  void calculateBodyFat() {
    final user = _authController.userModel.value;
    if (user != null) {
      double height = user.height ?? 0;
      double neck = user.neck ?? 0;
      double waist = user.waist ?? 0;

      _bodyFat.value = 86.010 * log(waist - neck) / ln10 -
          70.041 * log(height) / ln10 +
          36.76;
    }
  }

  String getBodyFatStatus() {
    if (bodyFat < 6) {
      return 'Temel Yağ';
    } else if (bodyFat < 14) {
      return 'Sporcu';
    } else if (bodyFat < 18) {
      return 'Fit';
    } else if (bodyFat < 25) {
      return 'Ortalama';
    } else {
      return 'Yüksek';
    }
  }

  Color getBodyFatColor() {
    if (bodyFat < 6) {
      return Colors.blue;
    } else if (bodyFat < 14) {
      return Colors.green;
    } else if (bodyFat < 18) {
      return Colors.teal;
    } else if (bodyFat < 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
