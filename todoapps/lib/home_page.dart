
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'Controllers/todo_controller.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Logins/login_page.dart';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

import 'models/todo_model.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final supabase = Supabase.instance.client.auth.currentUser;

  final TodoController controller = Get.put(TodoController());
  // final _taskController = TextEditingController();

  final TodoController2 controller2 = Get.put(TodoController2());
  final TextEditingController input = TextEditingController();
  var filter = 'all'.obs;

  void showEditDialog(BuildContext context, int id, String oldTitle) {
    TextEditingController edit = TextEditingController(text: oldTitle);

    Get.defaultDialog(
      title: "Edit To Do",
      content: TextField(controller: edit),
      textConfirm: "Save",
      onConfirm: () {
        controller2.editTodo(id, edit.text);
        Get.back();
      },  
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
      backgroundColor: Colors.blueAccent,
      items: [
        CurvedNavigationBarItem(
          child: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.chat_bubble_outline),
          label: 'Tasks',
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.calendar_month_outlined),
          label: 'Calender',  
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.perm_identity),
          label: 'Personal',
        ),
      ],
      onTap: (index) {
        // Handle button tap
      },
    ),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("My Tasks", 
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        //     onPressed: () => controller.supabase.auth.signOut(),
        //   )
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.todos.isEmpty) {
          return Center(
            child: Column(
                    children: [
                      // Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () => filter.value = 'all',
                              child: Text("All")),
                          ElevatedButton(
                              onPressed: () => filter.value = 'done',
                              child: Text("Done")),
                          ElevatedButton(
                              onPressed: () => filter.value = 'undone',
                              child: Text("Pending")),
                        ],
                      ),

                      // List
                      Expanded(
                        child: Obx(() {
                          var list = controller2.todos;

                          if (filter.value == 'done') {
                            list = controller2.completed.obs;
                          } else if (filter.value == 'undone') {
                            list = controller2.pending.obs;
                          }

                          return ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final todo = list[index];
                              return TodoTile(
                                todo: todo,
                                onDelete: () => controller2.deleteTodo(todo.id),
                                onToggle: () => controller2.toggleStatus(todo.id),
                                onEdit: () => showEditDialog(
                                    context, todo.id, todo.title),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),

                  
            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     // Tambahkan file JSON Lottie di folder assets kamu
            //     Lottie.network(
            //       'https://assets10.lottiefiles.com/packages/lf20_dmw3t0vg.json', // Karakter santai
            //       height: 250,
            //     ),
            //     Text("Hore! Tidak ada tugas hari ini", 
            //       style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
            //   ],
            // ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.todos.length,
          itemBuilder: (context, index) {
            final todo = controller.todos[index];
            return _buildTaskCard(todo);
          },
        );
      }),
      //drawwer setting
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.cyan,
              ),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.grey),
                accountName: Text(
                  supabase?.userMetadata?['name'] ?? 
                  'No Name',
                  style: const TextStyle(fontSize: 18),
                ),
                accountEmail: Text(
                  supabase?.email ?? 'No Email',
                  ),
                currentAccountPictureSize: const Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 165, 255, 137),
                  child: Text(
                    (supabase?.email != null)
                    ? supabase!.email![0].toUpperCase()
                    : 'A',
                    style: const TextStyle(fontSize: 30.0, color: Colors.blue),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(' My Profile '),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu),
              title: const Text(' Kategori '),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LogOut'),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                // Tutup drawer
                Get.back();
                // Pindah ke login & hapus semua halaman sebelumnya
                Get.offAll(() => LoginPage());
              },
            ),
          ],
        ),
      ),

    

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tugas Baru", style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [       
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => controller.deleteTodo(todo['id']),
              backgroundColor: Colors.redAccent,
              icon: Icons.delete_outline,
              label: 'Hapus',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            ),
          ],
        ),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          title: Text(todo['task'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                decoration: todo['is_complete'] ? TextDecoration.lineThrough : null,
                color: todo['is_complete'] ? Colors.grey : Colors.black87,
              )),
          value: todo['is_complete'],
          onChanged: (val) => controller.toggleStatus(todo['id'], todo['is_complete']),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.blueAccent,
          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }
  void _showAddDialog(BuildContext context) {
  final TextEditingController input = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 25,
          right: 25,
          top: 25,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: input,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Masukkan tugas...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (input.text.trim().isNotEmpty) {
                  controller2.addTodo(input.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            )
          ],
        ),
      );
    },
  );
}

  // void _showAddDialog(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
  //     builder: (context) => Padding(
  //       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text("Tugas Apa Selanjutnya?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
  //           const SizedBox(height: 15),
  //           TextField(
  //             controller: _taskController,
  //             autofocus: true,
  //             decoration: InputDecoration(
  //               filled: true,
  //               fillColor: Colors.grey[100],
  //               hintText: "Contoh: Belajar Akuntansi...",
  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: () {
  //               controller.addTodo(_taskController.text);
  //               _taskController.clear();
  //               Get.back();
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.blueAccent,
  //               minimumSize: const Size(double.infinity, 55),
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //             ),
  //             child: const Text("Simpan ke Daftar", style: TextStyle(color: Colors.white, fontSize: 16)),
  //           ),
  //           const SizedBox(height: 30),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}