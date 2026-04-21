import 'package:flutter/material.dart';

class Todo {
  int id;
  String title;
  bool isDone;
  String category;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
     required this.category,
  });
}
Color getCategoryColor(String category) {
  switch (category) {
    case 'Kuliah':
      return Colors.blue;
    case 'Pribadi':
      return Colors.green;
    case 'Kerja':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const TodoTile({
    required this.todo,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      todo.isDone ? "Completed" : "Pending",
      style: TextStyle(
        color: todo.isDone ? Colors.green : Colors.orange,
      ),
    ),

    SizedBox(height: 4),

    Text(
  todo.category,
  style: TextStyle(
    fontSize: 12,
    color: getCategoryColor(todo.category), // 🔥 pakai di sini
  ),
),
  ],
),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
            IconButton(
              icon: Icon(
                todo.isDone
                    ? Icons.undo
                    : Icons.check,
                color: Colors.green,
              ),
              onPressed: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}