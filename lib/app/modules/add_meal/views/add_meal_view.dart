import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/add_meal_controller.dart';

class AddMealView extends GetView<AddMealController> {
  const AddMealView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Yemek Ekle',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 48,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.close, color: Colors.grey.shade800, size: 22),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.saveMeal(),
            child: Text(
              'Kaydet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Öğün',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMealTypeChip('Kahvaltı', Icons.wb_sunny_outlined),
                        const SizedBox(width: 8),
                        _buildMealTypeChip('Öğle', Icons.sunny),
                        const SizedBox(width: 8),
                        _buildMealTypeChip('Akşam', Icons.nights_stay_outlined),
                        const SizedBox(width: 8),
                        _buildMealTypeChip(
                            'Atıştırmalık', Icons.restaurant_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yemek Ara',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.searchFood(value),
                    enabled: controller.selectedFood.value == null,
                    decoration: InputDecoration(
                      hintText: 'Yemek ara...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final food = controller.searchResults[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            food['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${food['calories']} kcal / ${food['serving_size']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onTap: () {
                            controller.selectFood(food);
                          },
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

             
            Obx(() {
              if (controller.selectedFood.value != null) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seçilen Yemek',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.selectedFood.value!['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (controller.selectedFood.value!['brand']
                                      .toString()
                                      .isNotEmpty)
                                    Text(
                                      controller.selectedFood.value!['brand'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.selectedFood.value = null;
                                controller.updateNutrients();
                              },
                              icon: Icon(Icons.close,
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            
            Obx(() {
              if (controller.selectedFood.value == null) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Porsiyon (gram)',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          controller.decreaseServing(),
                                      icon: Icon(Icons.remove,
                                          color: Colors.grey.shade600),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: TextField(
                                          controller: controller.gramController,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade800,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            suffixText: 'g',
                                            suffixStyle: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              controller.updateServingSize(
                                                  double.tryParse(value) ?? 0);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          controller.increaseServing(),
                                      icon: Icon(Icons.add,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kalori',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${controller.caloriesPerServing.value.toStringAsFixed(0)} kcal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            
            Obx(() {
              if (controller.selectedFood.value == null) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Besin Değerleri',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildNutrientInfo(
                          'Protein',
                          '${controller.proteinPerServing.value.toStringAsFixed(1)}g',
                          Colors.red.shade400,
                        ),
                        _buildNutrientInfo(
                          'Karbonhidrat',
                          '${controller.carbsPerServing.value.toStringAsFixed(1)}g',
                          Colors.blue.shade400,
                        ),
                        _buildNutrientInfo(
                          'Yağ',
                          '${controller.fatPerServing.value.toStringAsFixed(1)}g',
                          Colors.orange.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeChip(String label, IconData icon) {
    return Obx(() => ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: controller.selectedMealType.value == label
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: controller.selectedMealType.value == label
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          selected: controller.selectedMealType.value == label,
          onSelected: (selected) {
            if (selected) {
              controller.selectedMealType.value = label;
            }
          },
          selectedColor: Colors.blue.shade600,
          backgroundColor: Colors.grey.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0),
          visualDensity: VisualDensity.compact,
        ));
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
