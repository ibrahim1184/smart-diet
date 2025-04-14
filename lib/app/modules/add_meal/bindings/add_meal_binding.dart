import 'package:get/get.dart';

import '../controllers/add_meal_controller.dart';

class AddMealBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMealController>(
      () => AddMealController(),
    );
  }
}
