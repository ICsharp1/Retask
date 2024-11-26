import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../providers/theme_provider.dart';

class TaskProvider with ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;
  final ThemeProvider _themeProvider;
  List<Task> _tasks = [];

  TaskProvider(this._storage, this._notifications, this._themeProvider) {
    _loadTasks();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> _loadTasks() async {
    _tasks = await _storage.loadTasks();
    // Sort tasks: active tasks by due date, completed tasks by completion date
    _tasks.sort((a, b) {
      if (a.isCompleted && b.isCompleted) {
        return b.lastCompleted.compareTo(a.lastCompleted); // Most recent first
      } else if (!a.isCompleted && !b.isCompleted) {
        return a.nextDue.compareTo(b.nextDue); // Earliest due first
      } else {
        return a.isCompleted ? 1 : -1; // Active tasks before completed tasks
      }
    });
    notifyListeners();
  }

  Future<void> addTask(Task task, {BuildContext? context}) async {
    // Set default color based on due date if no color was chosen
    if (task.color == Colors.blue) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(task.nextDue.year, task.nextDue.month, task.nextDue.day);
      
      if (taskDate.isBefore(today)) {
        task.color = _themeProvider.settings.taskOverdueColor;
      } else if (taskDate.isAtSameMomentAs(today)) {
        task.color = _themeProvider.settings.taskDueTodayColor;
      } else {
        task.color = _themeProvider.settings.taskFutureColor;
      }
    }
    
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    if (task.hasNotification) {
      final success = await _notifications.scheduleNotification(task, context: context);
      if (!success) {
        print('Failed to schedule notification for task: ${task.title}');
      }
    }
    await _loadTasks(); // Reload to ensure proper sorting
  }

  Future<void> completeTask(int index) async {
    final task = _tasks[index];
    final now = DateTime.now();
    task.lastCompleted = now;
    task.nextDue = now.add(Duration(days: task.frequencyInDays));
    task.isCompleted = true;
    
    // Move completed task to end of list
    _tasks.removeAt(index);
    _tasks.add(task);
    
    await _storage.saveTasks(_tasks);
    if (task.hasNotification) {
      await _notifications.scheduleNotification(task);
    }
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    _tasks.remove(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task oldTask, Task newTask, {BuildContext? context}) async {
    final index = _tasks.indexOf(oldTask);
    if (index != -1) {
      // Preserve steps when updating task
      if (oldTask.steps.isNotEmpty) {
        newTask.steps = oldTask.steps;
      }
      _tasks[index] = newTask;
      await _storage.saveTasks(_tasks);
      if (newTask.hasNotification) {
        final success = await _notifications.scheduleNotification(newTask, context: context);
        if (!success) {
          print('Failed to schedule notification for task: ${newTask.title}');
        }
      }
      await _loadTasks(); // Reload to ensure proper sorting
    }
  }

  Future<void> saveTask(Task task) async {
    // Always save tasks when this method is called
    await _storage.saveTasks(_tasks);
    // No need to reload since we're just updating steps
    notifyListeners();
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      final now = DateTime.now();
      task.lastCompleted = now;
      task.nextDue = now.add(Duration(days: task.frequencyInDays));
    }
    await _storage.saveTasks(_tasks);
    await _loadTasks(); // Reload to ensure proper sorting
  }

  void updateTaskColor(Task task, Color newColor) {
    task.color = newColor;
    _storage.saveTasks(_tasks);  // Changed from _saveTasks()
    notifyListeners();
  } 
}
