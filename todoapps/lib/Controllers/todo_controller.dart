import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoController extends GetxController {
  final supabase = Supabase.instance.client;
  
  // Mengubah Stream menjadi List yang bisa dipantau GetX
  var todos = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToTodos();
  }

  void _listenToTodos() {
    supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('id', ascending: false)
        .listen((data) {
      todos.assignAll(data);
      isLoading.value = false;
    });
  }

  Future<void> addTodo(String task) async {
    await supabase.from('todos').insert({
      'task': task,
      'user_id': supabase.auth.currentUser!.id,
      'is_complete': false,
    });
  }

  Future<void> toggleStatus(int id, bool currentStatus) async {
    await supabase.from('todos').update({'is_complete': !currentStatus}).match({'id': id});
  }

  Future<void> deleteTodo(int id) async {
    await supabase.from('todos').delete().match({'id': id});
  }
}