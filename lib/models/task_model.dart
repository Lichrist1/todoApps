class TaskModel {
  String id;
  String name;
  String category;
  String startTime;
  String endTime;
  DateTime date;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.isCompleted = false,
  });
  
  static TaskModel fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      category: map['category'] ?? 'Uncategorized',
      isCompleted: map['is_completed'] ?? false,
    );
  }
}