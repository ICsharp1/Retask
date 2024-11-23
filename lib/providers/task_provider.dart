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
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
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
    try {
      await _notifications.scheduleNotification(task);
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
  notifyListeners();
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

  Future<void> updateTask(Task oldTask, Task newTask) async {
    final index = _tasks.indexOf(oldTask);
    if (index != -1) {
      if (newTask.color == Colors.blue) {
        newTask.color = oldTask.color;
      }
      _tasks[index] = newTask;
      await _storage.saveTasks(_tasks);
      if (newTask.hasNotification) {
        await _notifications.scheduleNotification(newTask);
      }
      notifyListeners();
    }
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
  task.isCompleted = !task.isCompleted;
  if (task.isCompleted) {
    final now = DateTime.now();
    task.lastCompleted = now;
    task.nextDue = now.add(Duration(days: task.frequencyInDays));
  }
  _storage.saveTasks(_tasks);
  notifyListeners();
}

void updateTaskColor(Task task, Color newColor) {
  task.color = newColor;
  _storage.saveTasks(_tasks);  // Changed from _saveTasks()
    notifyListeners();
  } 
}
