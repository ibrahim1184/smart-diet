import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/models/meal_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Tema renkleri ve stiller
  static final _primary = Colors.blue.shade600;
  static final _accent = Colors.orange.shade600;
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
    color: _primary,
  );

  static final _headingStyle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
  );

  static final _subheadingStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.grey.shade600,
  );

  static final _calorieStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: _accent,
  );

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr_TR', null);

    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCalendar(),
              _buildTotalCalories(),
              _buildMealsList(),
            ],
          ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: FloatingActionButton(
              onPressed: () => Get.toNamed(Routes.ADD_MEAL),
              backgroundColor: Colors.blue.shade600,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Ana Sayfa', style: _titleStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: _primary),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red.shade600),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: _cardShadow,
      ),
      child: Obx(() => TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: controller.focusedDay.value,
            selectedDayPredicate: (day) =>
                isSameDay(controller.selectedDay.value, day),
            onDaySelected: controller.onDaySelected,
            calendarFormat: CalendarFormat.week,
            locale: 'tr_TR',
            daysOfWeekHeight: 40,
            availableCalendarFormats: const {
              CalendarFormat.week: 'Hafta',
              CalendarFormat.month: 'Ay',
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: GoogleFonts.poppins(
                color: _primary.withOpacity(0.7),
              ),
              defaultTextStyle: GoogleFonts.poppins(),
              weekNumberTextStyle: GoogleFonts.poppins(),
              outsideTextStyle: GoogleFonts.poppins(),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: _headingStyle,
              leftChevronIcon: Icon(Icons.chevron_left, color: _primary),
              rightChevronIcon: Icon(Icons.chevron_right, color: _primary),
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM(locale).format(date).capitalize!,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.poppins(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: GoogleFonts.poppins(
                color: _primary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
    );
  }

  Widget _buildTotalCalories() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withOpacity(0.1),
              border: Border.all(color: _accent, width: 2),
            ),
            child: Obx(() {
              final total = controller.totalCalories.value;
              final target = controller.targetCalories.value;
              final progress = target > 0 ? total / target : 0.0;
              final color = progress > 1.0
                  ? Colors.red
                  : progress > 0.8
                      ? Colors.orange
                      : _accent;
              return Text(
                '$total',
                style: _calorieStyle.copyWith(color: color),
              );
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Toplam Kalori', style: _headingStyle),
                Obx(() => Text(
                      'Günlük hedefiniz: ${controller.targetCalories.value.toStringAsFixed(0)} kcal',
                      style: _subheadingStyle,
                    )),
              ],
            ),
          ),
          Obx(() {
            final total = controller.totalCalories.value;
            final target = controller.targetCalories.value;
            final progress = target > 0 ? total / target : 0.0;
            final color = progress > 1.0
                ? Colors.red
                : progress > 0.8
                    ? Colors.orange
                    : Colors.green;
            return SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 8,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).padding.bottom + 80,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildMealCard(
                'Kahvaltı',
                controller.breakfastMeals,
                Icons.breakfast_dining,
                const Color(0xFFFFF5E6),
                const Color(0xFFFF9800),
              ),
              _buildMealCard(
                'Öğle Yemeği',
                controller.lunchMeals,
                Icons.lunch_dining,
                const Color(0xFFFFF5E6),
                const Color(0xFFFF9800),
              ),
              _buildMealCard(
                'Ara Öğün',
                controller.snackMeals,
                Icons.restaurant,
                const Color(0xFFFFF5E6),
                const Color(0xFFFF9800),
              ),
              _buildMealCard(
                'Akşam Yemeği',
                controller.dinnerMeals,
                Icons.dinner_dining,
                const Color(0xFFFFF5E6),
                const Color(0xFFFF9800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String title, RxList<MealModel> meals, IconData icon,
      Color bgColor, Color iconColor) {
    final cardOffset = ValueNotifier<double>(0);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        cardOffset.value += details.delta.dx;
        // Sınırlamalar
        if (cardOffset.value > 0) {
          cardOffset.value = 0;
        } else if (cardOffset.value < -120) {
          cardOffset.value = -120;
        }
      },
      onHorizontalDragEnd: (details) {
        if (cardOffset.value > -60) {
          cardOffset.value = 0;
        } else {
          cardOffset.value = -120;
        }
      },
      child: ValueListenableBuilder<double>(
        valueListenable: cardOffset,
        builder: (context, offset, child) {
          return Stack(
            children: [
              // Düzenle ve Sil butonları
              Positioned(
                right: 0,
                top: 8,
                bottom: 8,
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.blue.shade600),
                          const SizedBox(height: 4),
                          Text(
                            'Düzenle',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(16)),
                      ),
                      child: GestureDetector(
                        onTap: () =>
                            _showDeleteDialog(title, controller, cardOffset),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.red.shade600),
                            const SizedBox(height: 4),
                            Text(
                              'Sil',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Ana kart içeriği
              Transform.translate(
                offset: Offset(offset, 0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  meals.isEmpty
                                      ? '0 kcal'
                                      : '${meals.fold(0, (sum, meal) => sum + meal.calories.round())} kcal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: iconColor,
                                  ),
                                ),
                              )),
                        ],
                      ),
                      Obx(() {
                        if (meals.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              meals
                                  .map((meal) =>
                                      '${meal.name} (${meal.details})')
                                  .join(', '),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(String title, HomeController controller,
      ValueNotifier<double> cardOffset) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade600, size: 48),
              const SizedBox(height: 16),
              Text(
                'Emin misiniz?',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu öğündeki tüm yemekler silinecek.',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      cardOffset.value = 0;
                    },
                    child: Text('Vazgeç',
                        style:
                            GoogleFonts.poppins(color: Colors.grey.shade600)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.deleteMealsByType(title);
                      Get.back();
                      cardOffset.value = 0;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Sil',
                        style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Çıkış Yap',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Çıkış yapmak istediğinize emin misiniz?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Çıkış Yap',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
