class Todo {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isReminderActive;
  final String priority; // 'High', 'Medium', 'Low'
  final String category; // 'General', 'Work', 'Personal', etc.

  Todo({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.isReminderActive = false,
    this.priority = 'Medium',
    this.category = 'General',
  });

  // Convert a Todo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isReminderActive': isReminderActive ? 1 : 0,
      'priority': priority,
      'category': category,
    };
  }

  // Implement toString to make it easier to see information about
  // each todo when using the print statement.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title, isCompleted: $isCompleted, priority: $priority}';
  }

  // Extract a Todo object from separate Map object
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isReminderActive: map['isReminderActive'] == 1,
      priority: map['priority'] ?? 'Medium',
      category: map['category'] ?? 'General',
    );
  }

  // Create a copy of Todo with some updated values
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isReminderActive,
    String? priority,
    String? category,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isReminderActive: isReminderActive ?? this.isReminderActive,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }
}
