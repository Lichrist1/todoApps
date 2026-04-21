import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todo_model.dart';

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

class TodoController2 extends GetxController {
  var todos = <Todo>[].obs;
  int idCounter = 0;

  void addTodo(String title) {
    todos.add(Todo(id: idCounter++, title: title));
  }

  void deleteTodo(int id) {
    todos.removeWhere((todo) => todo.id == id);
  }

  void toggleStatus(int id) {
    var todo = todos.firstWhere((t) => t.id == id);
    todo.isDone = !todo.isDone;
    todos.refresh();
  }

  void editTodo(int id, String newTitle) {
    var todo = todos.firstWhere((t) => t.id == id);
    todo.title = newTitle;
    todos.refresh();
  }
  
  List<Todo> get pending =>
      todos.where((t) => !t.isDone).toList();

  List<Todo> get completed =>
      todos.where((t) => t.isDone).toList();
}