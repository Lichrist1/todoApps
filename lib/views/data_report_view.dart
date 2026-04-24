import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';

class DataReportView extends StatelessWidget {
  final AppController c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => c.fetchTasks(),
        child: Obx(() => c.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                children: [
                  const Text("Data Report", 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _cardReport("Total Tasks", "${c.totalTasks}", 
                          Colors.white, Colors.black, Icons.task_alt),
                      _cardReport("Completed", "${c.completedTasks}", 
                          const Color(0xFF623EFA), Colors.white, Icons.check_circle),
                      _cardReport("Pending", "${c.pendingTasks}", 
                          const Color(0xFF8B6BFA), Colors.white, Icons.pending_actions),
                      _cardReport("Completion", "${c.completionRate.toStringAsFixed(0)}%", 
                          Colors.white, Colors.black, Icons.analytics),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF623EFA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Weekly Activity", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("Week ${DateTime.now().weekday}", 
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildWeeklyChart(c),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("By Category", 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        ..._buildCategoryStats(),
                      ],
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _cardReport(String title, String val, Color bg, Color txt, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: txt.withOpacity(0.7), size: 24),
          const Spacer(),
          Text(val, 
              style: TextStyle(color: txt, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, 
              style: TextStyle(color: txt.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AppController c) {
  final weeklyData = c.getWeeklyProgress();
  final maxVal = weeklyData.reduce((a, b) => a > b ? a : b);
  final weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  
  return SizedBox(
    height: 180,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final rawHeight = maxVal > 0 ? (weeklyData[index] / maxVal) * 120 : 0.0;
        final height = rawHeight.toDouble();
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("${weeklyData[index].toInt()}", 
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              width: 30,
              height: height > 0 ? height : 4.0,
              decoration: BoxDecoration(
                color: weeklyData[index] > 0 ? Colors.white : Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(weekDays[index], 
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        );
      }),
    ),
  );
}
  
  List<Widget> _buildCategoryStats() {
    final Map<String, int> categoryCount = {};
    final Map<String, int> categoryCompleted = {};
    
    for (var task in c.tasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
      if (task.isCompleted) {
        categoryCompleted[task.category] = (categoryCompleted[task.category] ?? 0) + 1;
      }
    }
    
    return categoryCount.entries.map((entry) {
      final total = entry.value;
      final completed = categoryCompleted[entry.key] ?? 0;
      final percentage = total > 0 ? (completed / total) * 100 : 0;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text("$completed/$total", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF623EFA),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}