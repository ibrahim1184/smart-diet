import 'package:get/get.dart';

import '../controllers/calorie_needs_controller.dart';

class CalorieNeedsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalorieNeedsController>(
      () => CalorieNeedsController(),
    );
  }
}
