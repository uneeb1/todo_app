class Task {
  int? id;
  String title;
  String description;
  DateTime deadline;
  int? categoryId;
  bool completed;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.categoryId,
    this.completed = false,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    int? categoryId,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      categoryId: categoryId ?? this.categoryId,
      completed: completed ?? this.completed,
    );
  }

  List<Task> categoryTasks = [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'categoryId': categoryId,
      'completed': completed ? 1 : 0,
    };
  }

  static Task empty() {
    return Task(
      id: 0,
      title: '',
      description: '',
      deadline: DateTime.now(),
      categoryId: 0,
    );
  }
}
