import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _key = 'tasks';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<List<Task>> loadTasks() async {
    final String? tasksJson = _prefs.getString(_key);
    if (tasksJson == null) return [];
    
    final List<dynamic> tasksList = json.decode(tasksJson);
    return tasksList.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final String tasksJson = json.encode(
      tasks.map((task) => task.toJson()).toList(),
    );
    await _prefs.setString(_key, tasksJson);
  }
}