import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';

class HabitDetailView extends StatelessWidget {
  const HabitDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = Get.find<AppController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Get.isRegistered<AppController>()) {
              c.currentIndex.value = 0;
            }
          },
        ),
        title: const Text("Habit Detail",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("My Weekly Progress",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              "Updated: ${DateFormat('d MMMM yyyy').format(DateTime.now())}",
              style: const TextStyle(color: Color(0xFF8B6BFA), fontSize: 14),
            ),
            const SizedBox(height: 25),
            _buildWeeklyChartCard(c),
            const SizedBox(height: 20),
            _buildCalendarCard(c),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChartCard(AppController c) {
    List<String> weekDays = ["M", "T", "W", "T", "F", "S", "S"];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Week to Date Progress",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 25),
          Obx(() {
            List<double> dailyCounts = c.getWeeklyProgress();
            double maxVal = dailyCounts.isEmpty ? 1 : dailyCounts.reduce((a, b) => a > b ? a : b);
            if (maxVal == 0) maxVal = 1;

            return SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  double barHeight = (dailyCounts[index] / maxVal) * 100;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (dailyCounts[index] > 0)
                        Text("${dailyCounts[index].toInt()}",
                            style: const TextStyle(color: Colors.white, fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        width: 25,
                        height: dailyCounts[index] > 0 ? barHeight : 5,
                        decoration: BoxDecoration(
                          color: dailyCounts[index] > 0 ? const Color(0xFF623EFA) : Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(weekDays[index],
                          style: TextStyle(
                            color: dailyCounts[index] > 0 ? Colors.white : Colors.white38,
                            fontSize: 12,
                          )),
                    ],
                  );
                }),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildCalendarCard(AppController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => c.previousMonth(),
              ),
              Obx(() => Text(
                DateFormat('MMMM yyyy', 'id_ID').format(c.currentMonth.value),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              )),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => c.nextMonth(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54, fontSize: 12))))
                .toList(),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final firstDayOfMonth = DateTime(c.currentMonth.value.year, c.currentMonth.value.month, 1);
            final firstWeekday = firstDayOfMonth.weekday % 7;
            final daysInMonth = c.getDaysInMonth(c.currentMonth.value);
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayNumber = index - firstWeekday + 1;
                final isInMonth = dayNumber >= 1 && dayNumber <= daysInMonth;
                
                if (!isInMonth) {
                  return Container();
                }
                
                final dateCheck = DateTime(c.currentMonth.value.year, c.currentMonth.value.month, dayNumber);
                final isSuccess = c.isTaskCompletedOnDate(dateCheck);
                final isToday = dateCheck.day == DateTime.now().day &&
                               dateCheck.month == DateTime.now().month &&
                               dateCheck.year == DateTime.now().year;
                
                return Container(
                  decoration: BoxDecoration(
                    color: isSuccess ? const Color(0xFF623EFA) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSuccess 
                        ? Border.all(color: const Color(0xFF623EFA), width: 2)
                        : isSuccess ? null : Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(
                      "$dayNumber",
                      style: TextStyle(
                        color: isSuccess || isToday ? Colors.white : Colors.white54,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFF623EFA), "Completed"),
              const SizedBox(width: 20),
              _buildLegend(Colors.transparent, "No Task"),
              const SizedBox(width: 20),
              _buildLegend(Colors.white24, "Today"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color == Colors.transparent ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: color == Colors.transparent ? Border.all(color: Colors.white24) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}