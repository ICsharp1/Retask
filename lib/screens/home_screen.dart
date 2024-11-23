import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../screens/add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today) || date.isAtSameMomentAs(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('reTask'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Tasks'),
                  content: const Text('Are you sure you want to delete all tasks? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<TaskProvider>().clearAllTasks();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks.toList();
          final activeTasks = tasks.where((t) => !t.isCompleted).toList()
            ..sort((a, b) {
              final aOverdue = isOverdue(a.nextDue);
              final bOverdue = isOverdue(b.nextDue);
              if (aOverdue != bOverdue) return aOverdue ? -1 : 1;
              return a.nextDue.compareTo(b.nextDue);
            });

          final completedTasks = tasks.where((t) => t.isCompleted).toList();
          final overdueTasksCount = activeTasks.where((t) => isOverdue(t.nextDue)).length;

          return ListView.builder(
            itemCount: tasks.isEmpty ? 0 : activeTasks.length + completedTasks.length + 1,
            itemBuilder: (context, index) {
              if (index == activeTasks.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey,
                    indent: 16,
                    endIndent: 16,
                  ),
                );
              }

              if (index < activeTasks.length) {
                final task = activeTasks[index];
                final isTaskOverdue = isOverdue(task.nextDue);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Card(
                    elevation: 2,
                    color: task.color,
                    child: ListTile(
                      textColor: Colors.white,
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          taskProvider.toggleTaskCompletion(task);
                        },
                      ),
                      title: Text(task.title),
                      subtitle: Text(
                        'Next due: ${DateFormat('yyyy-MM-dd').format(task.nextDue)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isTaskOverdue)
                            const Icon(Icons.warning, color: Colors.red),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskScreen(taskToEdit: task),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                final completedTask = completedTasks[index - activeTasks.length - 1];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Card(
                    elevation: 1,
                    color: Colors.grey[100],
                    child: ListTile(
                      leading: const Checkbox(
                        value: true,
                        onChanged: null,
                      ),
                      title: Text(
                        completedTask.title,
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(
                        'Next due: ${DateFormat('yyyy-MM-dd').format(completedTask.nextDue)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
