import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final email = ''.obs;
  final name = ''.obs;
  final surname = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final age = ''.obs;
  final height = ''.obs;
  final weight = ''.obs;
  final waist = ''.obs;
  final neck = ''.obs;
  final hip = ''.obs;
  final gender = ''.obs;

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final waistController = TextEditingController();
  final neckController = TextEditingController();
  final hipController = TextEditingController();
  final genderController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Controller değişikliklerini dinle
    emailController.addListener(() => email.value = emailController.text);
    nameController.addListener(() => name.value = nameController.text);
    surnameController.addListener(() => surname.value = surnameController.text);
    passwordController
        .addListener(() => password.value = passwordController.text);
    confirmPasswordController.addListener(
        () => confirmPassword.value = confirmPasswordController.text);
    ageController.addListener(() => age.value = ageController.text);
    heightController.addListener(() => height.value = heightController.text);
    weightController.addListener(() => weight.value = weightController.text);
    waistController.addListener(() => waist.value = waistController.text);
    neckController.addListener(() => neck.value = neckController.text);
    hipController.addListener(() => hip.value = hipController.text);
    genderController.addListener(() => gender.value = genderController.text);
  }

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    surnameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    waistController.dispose();
    neckController.dispose();
    hipController.dispose();
    genderController.dispose();
    super.onClose();
  }

  Future<void> registerUser(UserModel userModel, String password) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      // Form verilerini kaydet
      final formData = {
        'email': emailController.text,
        'firstName': nameController.text,
        'lastName': surnameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'height': double.tryParse(heightController.text) ?? 0.0,
        'weight': double.tryParse(weightController.text) ?? 0.0,
        'waist': double.tryParse(waistController.text) ?? 0.0,
        'neck': double.tryParse(neckController.text) ?? 0.0,
        'hip': double.tryParse(hipController.text) ?? 0.0,
        'gender': genderController.text,
      };

      // Önce Authentication'a kaydet
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: formData['email'] as String,
        password: password,
      );

      // Kullanıcı ID'sini al
      String uid = userCredential.user!.uid;

      // Firestore'a kaydet
      await _firestore.collection('users').doc(uid).set({
        ...formData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Başarılı',
        'Kayıt işlemi tamamlandı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Kısa bir gecikme ekle
      await Future.delayed(const Duration(milliseconds: 500));

      // Controller'ları temizle
      _clearControllers();

      // Login sayfasına yönlendir
      await Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu email zaten kullanımda';
          break;
        default:
          errorMessage = 'Bir hata oluştu: ${e.message}';
      }

      Get.snackbar(
        'Hata',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beklenmeyen bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearControllers() {
    emailController.clear();
    nameController.clear();
    surnameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    ageController.clear();
    heightController.clear();
    weightController.clear();
    waistController.clear();
    neckController.clear();
    hipController.clear();
    genderController.clear();
  }
}
