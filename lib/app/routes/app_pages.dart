import 'package:get/get.dart';

import '../modules/add_meal/bindings/add_meal_binding.dart';
import '../modules/add_meal/views/add_meal_view.dart';
import '../modules/bmi/bindings/bmi_binding.dart';
import '../modules/bmi/views/bmi_view.dart';
import '../modules/body_fat/bindings/body_fat_binding.dart';
import '../modules/body_fat/views/body_fat_view.dart';
import '../modules/calorie_needs/bindings/calorie_needs_binding.dart';
import '../modules/calorie_needs/views/calorie_needs_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      children: [
        GetPage(
          name: '/edit',
          page: () => const EditProfileView(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.BMI,
      page: () => const BmiView(),
      binding: BmiBinding(),
    ),
    GetPage(
      name: _Paths.BODY_FAT,
      page: () => const BodyFatView(),
      binding: BodyFatBinding(),
    ),
    GetPage(
      name: _Paths.CALORIE_NEEDS,
      page: () => const CalorieNeedsView(),
      binding: CalorieNeedsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_MEAL,
      page: () => const AddMealView(),
      binding: AddMealBinding(),
    ),
    GetPage(
      name: '/profile/edit',
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
