import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

   
  final isLoading = false.obs;

   
  final userData = Rx<UserModel?>(null);

   
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();

  // Vücut Ölçüleri
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final waistController = TextEditingController();
  final neckController = TextEditingController();
  final hipController = TextEditingController();

  Rx<String?> profileImageUrl = Rx<String?>(null);

   
  String get userEmail => userData.value?.email ?? '';
  String get userName => userData.value?.firstName ?? '';
  String get userSurname => userData.value?.lastName ?? '';
  String get userAge => userData.value?.age.toString() ?? '';
  String get userGender => userData.value?.gender ?? '';
  String get userHeight => userData.value?.height.toString() ?? '';
  String get userWeight => userData.value?.weight.toString() ?? '';
  String get userWaist => userData.value?.waist.toString() ?? '';
  String get userNeck => userData.value?.neck.toString() ?? '';
  String get userHip => userData.value?.hip.toString() ?? '';

  @override
  void onInit() {
    super.onInit();
    userData.value = _authController.userModel.value;
    
    profileImageUrl.value = userData.value?.profileImageUrl;
    loadUserData();

     
    listenToUserData();
  }

  void loadUserData() {
    
    emailController.text = userEmail;
    nameController.text = userName;
    surnameController.text = userSurname;
    ageController.text = userAge;
    genderController.text = userGender;
    heightController.text = userHeight;
    weightController.text = userWeight;
    waistController.text = userWaist;
    neckController.text = userNeck;
    hipController.text = userHip;
  }

  Future<void> updateProfile() async {
    try {
      
      if (nameController.text.isEmpty || surnameController.text.isEmpty) {
        Get.snackbar(
          'Hata',
          'Ad ve soyad alanları boş bırakılamaz',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final age = int.tryParse(ageController.text);
      if (age == null || age <= 0 || age > 120) {
        Get.snackbar(
          'Hata',
          'Geçerli bir yaş giriniz',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final height = double.tryParse(heightController.text);
      if (height == null || height <= 0 || height > 250) {
        Get.snackbar(
          'Hata',
          'Geçerli bir boy giriniz',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final weight = double.tryParse(weightController.text);
      if (weight == null || weight <= 0 || weight > 300) {
        Get.snackbar(
          'Hata',
          'Geçerli bir kilo giriniz',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      
      UserModel updatedUser = UserModel(
        email: emailController.text,
        firstName: nameController.text,
        lastName: surnameController.text,
        age: int.parse(ageController.text),
        gender: genderController.text,
        height: double.parse(heightController.text),
        weight: double.parse(weightController.text),
        waist: double.parse(waistController.text),
        neck: double.parse(neckController.text),
        hip: double.parse(hipController.text),
      );

      
      await _firestore
          .collection('users')
          .doc(_authController.firebaseUser.value?.uid)
          .update(updatedUser.toJson());

      
      userData.value = updatedUser;
      _authController.userModel.value = updatedUser;

     
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[400],
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Düzenleme başarıyla tamamlandı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back();  
      Get.back();  
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bir hata oluştu, lütfen tekrar deneyiniz',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void editProfile() {
    loadUserData();  
    Get.toNamed('/profile/edit');
  }

  void logout() {
    Get.defaultDialog(
      title: 'Çıkış Yap',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Çıkış yapmak istediğinize emin misiniz?',
      textConfirm: 'Evet',
      textCancel: 'Hayır',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.red,
      onConfirm: () async {
        await _authController.logout();
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        print('Resim seçildi: ${image.path}');

         
        final File imageFile = File(image.path);

        
        final fileSize = await imageFile.length();
        print('Dosya boyutu: ${fileSize / 1024} KB');

        
        final String userId = _authController.firebaseUser.value?.uid ?? '';
        if (userId.isEmpty) {
          throw Exception('Kullanıcı ID bulunamadı');
        }

        final Reference storageRef = _storage
            .ref()
            .child('profile_images')
            .child('$userId.jpg'); 

        print('Storage referansı oluşturuldu: ${storageRef.fullPath}');

         
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        );

        
        final uploadTask = storageRef.putFile(imageFile, metadata);

         
        uploadTask.snapshotEvents.listen(
          (TaskSnapshot snapshot) {
            final progress =
                (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            print('Upload progress: $progress%');
          },
          onError: (error) {
            print('Upload error: $error');
            throw error;
          },
        );

        
        final snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
           
          final url = await snapshot.ref.getDownloadURL();
          print('Download URL alındı: $url');

          
          await _firestore
              .collection('users')
              .doc(userId)
              .update({'profileImageUrl': url});

           
          profileImageUrl.value = url;

          
          Get.back();

          Get.snackbar(
            'Başarılı',
            'Profil fotoğrafı güncellendi',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e, stackTrace) {
      print('Hata: $e');
      print('Stack Trace: $stackTrace');

      Get.back();  
      Get.snackbar(
        'Hata',
        'Fotoğraf yüklenirken bir hata oluştu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Fotoğraf Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

   
  void listenToUserData() {
    final userId = _authController.firebaseUser.value?.uid;
    if (userId != null) {
      _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          userData.value = UserModel.fromJson(data);
          profileImageUrl.value = data['profileImageUrl'] as String?;
        }
      });
    }
  }

  @override
  void onClose() {
     
    emailController.dispose();
    nameController.dispose();
    surnameController.dispose();
    ageController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    waistController.dispose();
    neckController.dispose();
    hipController.dispose();
    super.onClose();
  }
}
