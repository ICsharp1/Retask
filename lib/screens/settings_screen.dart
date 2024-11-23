import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showTimePicker(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final settings = themeProvider.settings;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.defaultReminderTime ~/ 60,
        minute: settings.defaultReminderTime % 60
      ),
    );
    
    if (picked != null) {
      final minutes = picked.hour * 60 + picked.minute;
      themeProvider.setDefaultReminderTime(minutes);
    }
  }

  void _showColorPicker(BuildContext context, String colorType) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Color initialColor;
    
    // Get initial color based on type
    switch (colorType) {
      case 'dueToday':
        initialColor = themeProvider.settings.taskDueTodayColor;
        break;
      case 'overdue':
        initialColor = themeProvider.settings.taskOverdueColor;
        break;
      case 'future':
        initialColor = themeProvider.settings.taskFutureColor;
        break;
      default:
        initialColor = Colors.grey; // Default fallback color
    }
    
    Color pickerColor = initialColor;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            portraitOnly: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (colorType == 'dueToday') {
                themeProvider.setTaskDueTodayColor(pickerColor);
              } else if (colorType == 'overdue') {
                themeProvider.setTaskOverdueColor(pickerColor);
              } else if (colorType == 'future') {
                themeProvider.setTaskFutureColor(pickerColor);
              }
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTile(String title, Color color, String colorType, BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context, colorType),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final settings = themeProvider.settings;
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: settings.enableDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
              SwitchListTile(
                title: const Text('Show Completed Tasks'),
                value: settings.showCompletedTasks,
                onChanged: (value) => themeProvider.toggleShowCompletedTasks(value),
              ),
              const Divider(),
              _buildColorTile('Due Today Color', settings.taskDueTodayColor, 'dueToday', context),
              _buildColorTile('Overdue Task Color', settings.taskOverdueColor, 'overdue', context),
              _buildColorTile('Future Task Color', settings.taskFutureColor, 'future', context),
              const Divider(),
              ListTile(
                title: const Text('Default Reminder Time'),
                subtitle: Text(_formatTimeOfDay(TimeOfDay(
                  hour: settings.defaultReminderTime ~/ 60,
                  minute: settings.defaultReminderTime % 60,
                ))),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _showTimePicker(context),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Reset Colors'),
                subtitle: const Text('Restore default color settings'),
                trailing: IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Colors'),
                        content: const Text('Are you sure you want to reset all colors to their default values?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              themeProvider.resetColors();
                              Navigator.pop(context);
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Settings'),
                        content: const Text('This will reset all colors and notification times to their default values. Continue?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              themeProvider.resetSettings();
                              Navigator.pop(context);
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset Settings'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 