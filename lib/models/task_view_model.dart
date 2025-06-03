import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../screens/home_screen.dart';
import '../utils/notification_helper.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  String _searchKeyword = '';
  SortBy _sortBy = SortBy.createdAt;

  String get searchKeyword => _searchKeyword;
  SortBy get sortBy => _sortBy;

  void fetchTasks() {
    final box = Hive.box<Task>('tasksBox');
    _tasks = box.values.toList();
    notifyListeners();
  }

  void addTask(Task newTask) {
    final box = Hive.box<Task>('tasksBox');
    try {
      _tasks.add(newTask);
      box.put(newTask.id, newTask);
      NotificationHelper.scheduleNotification(newTask);
      notifyListeners();
    } catch (e) {
      debugPrint("AddTask error: $e");
    }
  }

  void updateTask(Task updatedTask) {
    final box = Hive.box<Task>('tasksBox');
    try {
      int index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        box.put(updatedTask.id, updatedTask);
        NotificationHelper.scheduleNotification(updatedTask);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("UpdateTask error: $e");
    }
  }

  void deleteTask(Task task) {
    final box = Hive.box<Task>('tasksBox');
    try {
      _tasks.removeWhere((t) => t.id == task.id);
      box.delete(task.id);
      NotificationHelper.cancelNotification(task);
      notifyListeners();
    } catch (e) {
      debugPrint("DeleteTask error: $e");
    }
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setSortBy(SortBy sort) {
    _sortBy = sort;
    notifyListeners();
  }

  List<Task> get sortedTasks {
    List<Task> filtered = _tasks.where((task) {
      final query = _searchKeyword.toLowerCase();
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();

    switch (_sortBy) {
      case SortBy.priority:
        filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortBy.dueDate:
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case SortBy.createdAt:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }
}
