import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../Logins/login_page.dart';

class AppController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  var tasks = <TaskModel>[].obs;
  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;
  var currentMonth = DateTime.now().obs;
  
  var newTaskName = ''.obs;
  var newTaskDate = DateTime.now().obs;
  var newTaskTime = TimeOfDay.now().obs;
  var remindMe = true.obs;
  var selectedCategory = 'Study'.obs;
  var categories = ['Study', 'Productive', 'Life', 'Work', 'Health'].obs;
  
  var isEditing = false.obs;
  var editingTaskId = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }
  
  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        tasks.clear();
        return;
      }
      
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: true);
      
      tasks.value = response.map((data) => TaskModel.fromMap(data)).toList();
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> addTask() async {
    if (newTaskName.value.trim().isEmpty) {
      Get.snackbar('Warning', 'Task name cannot be empty');
      return;
    }
    
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      
      final taskDate = DateTime(
        newTaskDate.value.year,
        newTaskDate.value.month,
        newTaskDate.value.day,
        newTaskTime.value.hour,
        newTaskTime.value.minute,
      );
      
      String timeString = '${newTaskTime.value.hour.toString().padLeft(2, '0')}:${newTaskTime.value.minute.toString().padLeft(2, '0')}';
      
      await _supabase.from('tasks').insert({
        'user_id': userId,
        'name': newTaskName.value.trim(),
        'category': selectedCategory.value,
        'date': taskDate.toIso8601String(),
        'start_time': timeString,
        'end_time': '',
        'is_completed': false,
      });
      
      newTaskName.value = '';
      newTaskDate.value = DateTime.now();
      newTaskTime.value = TimeOfDay.now();
      selectedCategory.value = 'Study';
      isEditing.value = false;
      editingTaskId.value = '';
      
      await fetchTasks();
      Get.back();
      Get.snackbar('Success', 'Task added successfully');
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to add task');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateTask() async {
    if (newTaskName.value.trim().isEmpty) {
      Get.snackbar('Warning', 'Task name cannot be empty');
      return;
    }
    
    try {
      isLoading.value = true;
      
      final taskDate = DateTime(
        newTaskDate.value.year,
        newTaskDate.value.month,
        newTaskDate.value.day,
        newTaskTime.value.hour,
        newTaskTime.value.minute,
      );
      
      String timeString = '${newTaskTime.value.hour.toString().padLeft(2, '0')}:${newTaskTime.value.minute.toString().padLeft(2, '0')}';
      
      await _supabase.from('tasks').update({
        'name': newTaskName.value.trim(),
        'category': selectedCategory.value,
        'date': taskDate.toIso8601String(),
        'start_time': timeString,
      }).eq('id', editingTaskId.value);
      
      newTaskName.value = '';
      newTaskDate.value = DateTime.now();
      newTaskTime.value = TimeOfDay.now();
      selectedCategory.value = 'Study';
      isEditing.value = false;
      editingTaskId.value = '';
      
      await fetchTasks();
      Get.back();
      Get.snackbar('Success', 'Task updated successfully');
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to update task');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> toggleTask(TaskModel task) async {
    try {
      await _supabase.from('tasks').update({
        'is_completed': !task.isCompleted
      }).eq('id', task.id);
      
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index].isCompleted = !tasks[index].isCompleted;
        tasks.refresh();
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      await _supabase.from('tasks').delete().eq('id', taskId);
      await fetchTasks();
      Get.snackbar('Success', 'Task deleted successfully');
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      Get.offAll(() => const LoginPage());
    } catch (e) {
      print('Error: $e');
    }
  }
  
  void setEditingTask(TaskModel task) {
    isEditing.value = true;
    editingTaskId.value = task.id;
    newTaskName.value = task.name;
    newTaskDate.value = task.date;
    selectedCategory.value = task.category;
    
    try {
      final timeParts = task.startTime.split(':');
      if (timeParts.length == 2) {
        newTaskTime.value = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    } catch (e) {
      newTaskTime.value = TimeOfDay.now();
    }
  }
  
  List<TaskModel> get filteredTasks => tasks.where((t) => 
    t.date.day == selectedDate.value.day && 
    t.date.month == selectedDate.value.month &&
    t.date.year == selectedDate.value.year).toList();
  
  List<TaskModel> get otherTasks => tasks.where((t) => 
    !(t.date.day == selectedDate.value.day && 
      t.date.month == selectedDate.value.month &&
      t.date.year == selectedDate.value.year)).toList();
  
  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => tasks.where((t) => !t.isCompleted).length;
  double get completionRate => totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  
  List<double> getWeeklyProgress() {
    DateTime now = DateTime.now();
    DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return List.generate(7, (index) {
      DateTime day = firstDayOfWeek.add(Duration(days: index));
      return tasks.where((t) => 
        t.date.day == day.day && 
        t.date.month == day.month && 
        t.date.year == day.year &&
        t.isCompleted == true
      ).length.toDouble();
    });
  }
  
  bool isTaskCompletedOnDate(DateTime date) {
    return tasks.any((t) => 
      t.date.day == date.day && 
      t.date.month == date.month && 
      t.date.year == date.year &&
      t.isCompleted == true
    );
  }
  
  void previousMonth() {
    currentMonth.value = DateTime(currentMonth.value.year, currentMonth.value.month - 1);
  }
  
  void nextMonth() {
    currentMonth.value = DateTime(currentMonth.value.year, currentMonth.value.month + 1);
  }
  
  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
}