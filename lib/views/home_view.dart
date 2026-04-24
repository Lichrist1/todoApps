import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../models/task_model.dart';
import 'create_task_view.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late AppController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<AppController>();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => c.fetchTasks(),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() => c.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (c.filteredTasks.isNotEmpty) ...[
                        Text("Today's Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        ...c.filteredTasks.map((t) => _buildTaskItem(t)),
                      ],
                      if (c.filteredTasks.isEmpty)
                        Container(
                          padding: EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                              SizedBox(height: 10),
                              Text("No tasks for today", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                      if (c.otherTasks.isNotEmpty) ...[
                        Text("Other Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        ...c.otherTasks.map((t) => _buildTaskItem(t)),
                      ],
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: Color(0xFF623EFA),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE', 'id_ID').format(c.selectedDate.value),
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy').format(c.selectedDate.value),
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
              Icon(Icons.calendar_month, color: Colors.white, size: 30),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (ctx, i) {
                DateTime date = DateTime.now().add(Duration(days: i - 7));
                return GestureDetector(
                  onTap: () => c.selectedDate.value = date,
                  child: Obx(() => Container(
                    width: 55,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: c.selectedDate.value.day == date.day && 
                             c.selectedDate.value.month == date.month
                          ? Colors.white 
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE', 'id_ID').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: c.selectedDate.value.day == date.day && 
                                   c.selectedDate.value.month == date.month
                                ? Colors.blue 
                                : Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: c.selectedDate.value.day == date.day && 
                                   c.selectedDate.value.month == date.month
                                ? Colors.blue 
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel t) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.isCompleted ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: t.isCompleted,
            onChanged: (_) => c.toggleTask(t),
            activeColor: Color(0xFF623EFA),
            checkColor: Colors.white,
          ),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                    color: t.isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF623EFA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        t.category,
                        style: TextStyle(fontSize: 11, color: Color(0xFF623EFA)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      t.startTime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) async {
              if (value == 'edit') {
                c.setEditingTask(t);
                await Get.to(() => CreateTaskView());
              } else if (value == 'delete') {
                _confirmDelete(t);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _confirmDelete(TaskModel task) {
    Get.defaultDialog(
      title: 'Delete Task',
      middleText: 'Are you sure you want to delete "${task.name}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await c.deleteTask(task.id);
      },
    );
  }
}