import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/todo_model.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationHelper _notificationHelper = NotificationHelper();

  List<Todo> _todos = [];
  String _filter = 'All'; // 'All', 'Active', 'Done'
  bool _isWeb = kIsWeb;

  List<Todo> get todos {
    if (_filter == 'Active') {
      return _todos.where((todo) => !todo.isCompleted).toList();
    } else if (_filter == 'Done') {
      return _todos.where((todo) => todo.isCompleted).toList();
    }
    return _todos;
  }

  TodoProvider() {
    if (!_isWeb) {
      _notificationHelper.init(); // Initialize notifications only on mobile
    }
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      if (_isWeb) {
        // Web: Use in-memory storage (data will be lost on refresh)
        // In future, could use local storage or IndexedDB
        debugPrint('Running on Web - Using in-memory storage');
        return;
      }
      
      _todos = await _dbHelper.getTodos();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      if (_isWeb) {
        // Web: Add to in-memory list
        final newTodo = todo.copyWith(
          id: DateTime.now().millisecondsSinceEpoch, // Generate ID
        );
        _todos.add(newTodo);
        notifyListeners();
        return;
      }
      
      int id = await _dbHelper.insertTodo(todo);
      // If there is a due date and reminder is active, schedule notification
      if (todo.dueDate != null && todo.isReminderActive) {
        final prefs = await SharedPreferences.getInstance();
        final soundPath = prefs.getString('alarmSoundPath');
        
        await _notificationHelper.scheduleNotification(
          id,
          'Pengingat: ${todo.title}',
          todo.description.isNotEmpty ? todo.description : 'Waktunya mengerjakan tugas Anda!',
          todo.dueDate!,
          soundPath: soundPath,
        );
      }
      await loadTodos();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      if (_isWeb) {
        // Web: Update in-memory list
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = todo;
          notifyListeners();
        }
        return;
      }
      
      await _dbHelper.updateTodo(todo);
      
      // Update notification
      if (todo.dueDate != null && todo.isReminderActive) {
        // Cancel old one just in case and schedule new
        await _notificationHelper.cancelNotification(todo.id!);
         
        final prefs = await SharedPreferences.getInstance();
        final soundPath = prefs.getString('alarmSoundPath');
         
        await _notificationHelper.scheduleNotification(
          todo.id!,
          'Pengingat: ${todo.title}',
          todo.description.isNotEmpty ? todo.description : 'Waktunya mengerjakan tugas Anda!',
          todo.dueDate!,
          soundPath: soundPath,
        );
      } else {
        // If reminder turned off, cancel it
        await _notificationHelper.cancelNotification(todo.id!);
      }

      await loadTodos();
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      if (_isWeb) {
        // Web: Remove from in-memory list
        _todos.removeWhere((t) => t.id == id);
        notifyListeners();
        return;
      }
      
      await _dbHelper.deleteTodo(id);
      await _notificationHelper.cancelNotification(id);
      await loadTodos();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    final newTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    await updateTodo(newTodo);
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }
}
