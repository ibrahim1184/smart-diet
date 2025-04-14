import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // Tema renkleri ve stiller
  static final _primary = Colors.blue.shade600;
  static final _secondary = Colors.blue.shade100;
  static final _background = Colors.grey.shade50;
  static const _cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 10,
      offset: Offset(0, 4),
    )
  ];

  // Yazı stilleri
  static final _titleStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
  );

  static final _labelStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.grey.shade600,
  );

  static final _valueStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade800,
  );

  static final _buttonStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final _measurementValueStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
  );

  static final _measurementLabelStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.grey.shade500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Profil', style: _titleStyle),
        centerTitle: true,
        toolbarHeight: 48,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800, size: 22),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red.shade600),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil Resmi ve Düzenleme Butonu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: _cardShadow,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      AvatarGlow(
                        glowColor: _primary,
                        animate: true,
                        glowRadiusFactor: 0.2,
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.fastOutSlowIn,
                        glowShape: BoxShape.circle,
                        child: Material(
                          elevation: 8.0,
                          shape: const CircleBorder(),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _secondary,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: Obx(
                                () => controller.profileImageUrl.value != null
                                    ? ClipOval(
                                        child: Image.network(
                                          controller.profileImageUrl.value!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: _primary,
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 60,
                                        color: _primary,
                                      )),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            onPressed: () => controller.showImageSourceDialog(),
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/profile/edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Profili Düzenle', style: _buttonStyle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kişisel Bilgiler
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _cardShadow,
              ),
              child: Obx(() => Column(
                    children: [
                      _buildInfoTile('Ad Soyad',
                          '${controller.userName} ${controller.userSurname}'),
                      _buildDivider(),
                      _buildInfoTile('E-posta', controller.userEmail),
                      _buildDivider(),
                      _buildInfoTile('Yaş', controller.userAge),
                      _buildDivider(),
                      _buildInfoTile('Cinsiyet', controller.userGender),
                    ],
                  )),
            ),
            const SizedBox(height: 16),

            // Vücut Ölçüleri
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Vücut Ölçüleri',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Obx(() => GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildMeasurementCard(
                            label: 'Kilo',
                            value: controller.userWeight,
                            unit: 'kg',
                            icon: Icons.monitor_weight_outlined,
                          ),
                          _buildMeasurementCard(
                            label: 'Boy',
                            value: controller.userHeight,
                            unit: 'cm',
                            icon: Icons.height,
                          ),
                          _buildMeasurementCard(
                            label: 'Bel Çevresi',
                            value: controller.userWaist,
                            unit: 'cm',
                            icon: Icons.straighten,
                          ),
                          _buildMeasurementCard(
                            label: 'Boyun Çevresi',
                            value: controller.userNeck,
                            unit: 'cm',
                            icon: Icons.accessibility_new,
                          ),
                          _buildMeasurementCard(
                            label: 'Kalça Çevresi',
                            value: controller.userHip,
                            unit: 'cm',
                            icon: Icons.straighten,
                            isLast: true,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // İstatistikler
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _cardShadow,
              ),
              child: Column(
                children: [
                  _buildStatButton(
                    'Vücut Kitle İndeksi',
                    Icons.monitor_weight_outlined,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildStatButton(
                    'Vücut Yağ Oranı',
                    Icons.pie_chart_outline,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatButton(
                    'Kalori İhtiyacı',
                    Icons.local_fire_department_outlined,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _labelStyle),
          Text(value, style: _valueStyle),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }

  Widget _buildMeasurementCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              icon,
              color: _primary.withOpacity(0.2),
              size: 24,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: _measurementLabelStyle,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: _measurementValueStyle,
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        unit,
                        style: _measurementLabelStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton(String label, IconData icon, Color color) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          switch (label) {
            case 'Vücut Kitle İndeksi':
              Get.toNamed(Routes.BMI);
              break;
            case 'Vücut Yağ Oranı':
              Get.toNamed(Routes.BODY_FAT);
              break;
            case 'Kalori İhtiyacı':
              Get.toNamed(Routes.CALORIE_NEEDS);
              break;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
