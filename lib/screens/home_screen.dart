import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/add_task_screen.dart';
import '../screens/steps_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  String formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
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
        ],
      ),
      body: Consumer2<TaskProvider, ThemeProvider>(
        builder: (context, taskProvider, themeProvider, child) {
          final tasks = taskProvider.tasks;
          final settings = themeProvider.settings;
          
          // Filter tasks based on settings
          var displayTasks = tasks;
          
          // Filter completed tasks if needed
          if (!settings.showCompletedTasks) {
            displayTasks = displayTasks.where((t) => !t.isCompleted).toList();
          }
          
          // Filter non-today tasks if needed
          if (!settings.showNonTodayTasks) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            displayTasks = displayTasks.where((t) {
              final taskDate = DateTime(t.nextDue.year, t.nextDue.month, t.nextDue.day);
              return taskDate.isAtSameMomentAs(today);
            }).toList();
          }

          if (displayTasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add some tasks to get started!'),
            );
          }

          return ListView.builder(
            itemCount: displayTasks.length,
            itemBuilder: (context, index) {
              final task = displayTasks[index];
              final isTaskOverdue = isOverdue(task.nextDue);
              final isCompleted = task.isCompleted;

              return Dismissible(
                key: Key(task.title + task.nextDue.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  taskProvider.deleteTask(task);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${task.title} deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          taskProvider.addTask(task);
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Card(
                    elevation: isCompleted ? 1 : 2,
                    color: isCompleted ? Colors.grey[100] : task.color,
                    child: ListTile(
                      textColor: isCompleted ? Colors.grey[700] : Colors.white,
                      leading: Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) {
                          taskProvider.toggleTaskCompletion(task);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCompleted 
                                ? 'Completed on: ${DateFormat('yyyy-MM-dd').format(task.lastCompleted)}'
                                : 'Next due: ${formatDueDate(task.nextDue)}',
                          ),
                          if (task.currentStep != null)
                            Text(
                              'Current step: ${task.currentStep!.title}',
                              style: TextStyle(
                                color: isCompleted ? Colors.grey[600] : Colors.white70,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCompleted && isTaskOverdue && themeProvider.settings.showOverdueWarning)
                            const Icon(Icons.warning, color: Colors.red),
                          IconButton(
                            icon: const Icon(Icons.list),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StepsScreen(task: task),
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTaskScreen(taskToEdit: task),
                                  ),
                                );
                              } else if (value == 'delete') {
                                taskProvider.deleteTask(task);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${task.title} deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        taskProvider.addTask(task);
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
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
