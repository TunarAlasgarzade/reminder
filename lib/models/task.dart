class Task {
  final int id;
  final String task;
  final DateTime scheduledAt;
  final bool isComplete;

  Task({
    required this.id,
    required this.task,
    required this.scheduledAt,
    required this.isComplete,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "task": task,
      "scheduledAt": scheduledAt,
      "isComplete": isComplete,
    };
  }

  Task.fromMap(Map<String, dynamic> map)
    : id = map["id"] as int,
      task = map["task"] as String,
      scheduledAt = map["scheduledAt"] as DateTime,
      isComplete = map["isComplete"] as bool? ?? false;
}