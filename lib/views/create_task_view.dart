import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';

class CreateTaskView extends StatelessWidget {
  final AppController c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () {
            c.isEditing.value = false;
            c.newTaskName.value = '';
            Get.back();
          }
        ), 
        title: Obx(() => Text(c.isEditing.value ? "Edit Task" : "Create New Task")), 
        elevation: 0, 
        backgroundColor: Colors.transparent, 
        foregroundColor: Colors.black
      ),
      body: Obx(() => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => c.newTaskName.value = v,
                  controller: TextEditingController(text: c.newTaskName.value),
                  decoration: const InputDecoration(
                    labelText: "Task Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                ),
                const SizedBox(height: 20),
                
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF623EFA)),
                  title: const Text("Date"),
                  subtitle: Obx(() => Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(c.newTaskDate.value),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: c.newTaskDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      c.newTaskDate.value = picked;
                    }
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.access_time, color: Color(0xFF623EFA)),
                  title: const Text("Time"),
                  subtitle: Obx(() => Text(
                    c.newTaskTime.value.format(context),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: c.newTaskTime.value,
                    );
                    if (picked != null) {
                      c.newTaskTime.value = picked;
                    }
                  },
                ),
                
                SwitchListTile(
                  title: const Text("Remind Me"),
                  subtitle: const Text("Get notification 15 minutes before"),
                  value: c.remindMe.value, 
                  onChanged: (v) => c.remindMe.value = v,
                  activeColor: const Color(0xFF623EFA),
                ),
                
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.categories.map((cat) => FilterChip(
                    label: Text(cat),
                    selected: c.selectedCategory.value == cat,
                    onSelected: (s) => c.selectedCategory.value = cat,
                    selectedColor: const Color(0xFF623EFA),
                    labelStyle: TextStyle(
                      color: c.selectedCategory.value == cat ? Colors.white : Colors.black,
                    ),
                  )).toList(),
                )),
                const Spacer(),
                
                Obx(() => ElevatedButton(
                  onPressed: c.isLoading.value 
                      ? null 
                      : () => c.isEditing.value ? c.updateTask() : c.addTask(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF623EFA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: c.isLoading.value
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : Text(
                          c.isEditing.value ? "UPDATE TASK" : "CREATE TASK",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      )),
    );
  }
}