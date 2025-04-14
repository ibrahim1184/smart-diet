import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    print('AuthController başlatılıyor...');
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    try {
      if (user != null) {
        print('Oturum açmış kullanıcı bulundu. ID: ${user.uid}');
        UserModel? userData = await getUser(user.uid);
        if (userData != null) {
          userModel.value = userData;
          if (Get.currentRoute != '/home') {
            await Get.offAllNamed('/home');
          }
        } else {
          print('Kullanıcı verileri bulunamadı');
          await _handleLogout();
        }
      } else {
        print('Oturum açmış kullanıcı yok');
        await _handleLogout();
      }
    } catch (e) {
      print('Hata: $e');
      await _handleLogout();
    }
  }

  Future<void> _handleLogout() async {
    userModel.value = null;
    if (Get.currentRoute != '/login') {
      await Get.offAllNamed('/login');
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      UserModel? user = await getUser(uid);
      if (user != null) {
        userModel.value = user;
        await Get.offAllNamed('/home');
      } else {
        print('Kullanıcı bulunamadı');
        await Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Hata: $e');
      await Get.offAllNamed('/login');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        print('Kullanıcı bulunamadı');
        return null;
      }
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }

  Future<void> addUser(UserModel user, String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        ...user.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Kullanıcı başarıyla eklendi');
    } catch (e) {
      print('Hata: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required double waist,
    required double neck,
    required double hip,
  }) async {
    try {
      // Firebase Auth ile kullanıcı oluştur
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // UserModel oluştur
        UserModel newUser = UserModel(
          email: email,
          firstName: firstName,
          lastName: lastName,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          waist: waist,
          neck: neck,
          hip: hip,
        );

        // Firestore'a kaydet
        await addUser(newUser, uid);
        userModel.value = newUser;

        Get.snackbar(
          'Başarılı',
          'Kayıt işlemi tamamlandı',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'weak-password':
          message = 'Şifre çok zayıf';
          break;
        case 'email-already-in-use':
          message = 'Bu e-posta adresi zaten kullanımda';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta adresi';
          break;
        default:
          message = e.message ?? 'Bir hata oluştu';
      }
      Get.snackbar('Hata', message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      print('Hata: $e');
      Get.snackbar('Hata', 'Beklenmeyen bir hata oluştu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        UserModel? user = await getUser(userCredential.user!.uid);
        if (user != null) {
          userModel.value = user;
          if (Get.currentRoute != '/home') {
            await Get.offAllNamed('/home');
          }
        } else {
          throw 'Kullanıcı bilgileri bulunamadı';
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'Kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          message = 'Hatalı şifre';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta adresi';
          break;
        default:
          message = e.message ?? 'Bir hata oluştu';
      }
      await Future.delayed(const Duration(milliseconds: 100));
      Get.snackbar(
        'Hata',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Hata: $e');
      await Future.delayed(const Duration(milliseconds: 100));
      Get.snackbar(
        'Hata',
        'Giriş yapılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _handleLogout();
    } catch (e) {
      print('Çıkış yapılırken hata: $e');
      await Future.delayed(const Duration(milliseconds: 100));
      Get.snackbar(
        'Hata',
        'Çıkış yapılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Başarılı', 'Şifre sıfırlama bağlantısı gönderildi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Hata', e.message ?? 'Bir hata oluştu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(firebaseUser.value?.uid)
          .update(user.toJson());
      userModel.value = user;
    } catch (e) {
      rethrow;
    }
  }
}
