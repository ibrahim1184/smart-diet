import 'package:get/get.dart';

import '../controllers/body_fat_controller.dart';

class BodyFatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BodyFatController>(
      () => BodyFatController(),
    );
  }
}
