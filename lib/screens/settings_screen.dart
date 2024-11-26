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

  Widget _buildColorTile(String title, Color color, String type, BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onTap: () {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        Color initialColor = color;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Choose $title'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: initialColor,
                    onColorChanged: (color) {
                      switch (type) {
                        case 'dueToday':
                          themeProvider.setTaskDueTodayColor(color);
                          break;
                        case 'overdue':
                          themeProvider.setTaskOverdueColor(color);
                          break;
                        case 'future':
                          themeProvider.setTaskFutureColor(color);
                          break;
                        case 'notesBackground':
                          themeProvider.setNotesBackgroundColor(color);
                          break;
                        case 'notesBorder':
                          themeProvider.setNotesCardBorderColor(color);
                          break;
                        case 'notesText':
                          themeProvider.setNotesTextColor(color);
                          break;
                        case 'stepBorder':
                          themeProvider.setStepCardBorderColor(color);
                          break;
                      }
                    },
                    pickerAreaHeightPercent: 0.7,
                    displayThumbColor: true,
                    enableAlpha: true,
                    showLabel: true,
                    portraitOnly: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorSection(String title, String subtitle, List<Widget> colorTiles) {
    return ExpansionTile(
      title: Text(title),
      subtitle: Text(subtitle),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(children: colorTiles),
        ),
      ],
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
              const Divider(),
              // Task visibility settings
              const ListTile(
                title: Text('Task Visibility'),
                subtitle: Text('Control which tasks are visible'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Show Completed Tasks'),
                      value: settings.showCompletedTasks,
                      onChanged: (value) => themeProvider.toggleShowCompletedTasks(value),
                    ),
                    SwitchListTile(
                      title: const Text('Show Tasks Not Due Today'),
                      value: settings.showNonTodayTasks,
                      onChanged: (value) => themeProvider.toggleShowNonTodayTasks(value),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Task warning settings
              const ListTile(
                title: Text('Task Warnings'),
                subtitle: Text('Control warning indicators'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SwitchListTile(
                  title: const Text('Show Warning for Overdue Tasks'),
                  value: settings.showOverdueWarning,
                  onChanged: (value) => themeProvider.toggleShowOverdueWarning(value),
                ),
              ),
              const Divider(),
              // Colors sections
              _buildColorSection(
                'Task Colors',
                'Customize task appearance',
                [
                  _buildColorTile('Due Today Color', settings.taskDueTodayColor, 'dueToday', context),
                  _buildColorTile('Overdue Task Color', settings.taskOverdueColor, 'overdue', context),
                  _buildColorTile('Future Task Color', settings.taskFutureColor, 'future', context),
                ],
              ),
              _buildColorSection(
                'Notes & Steps Colors',
                'Customize notes and steps appearance',
                [
                  _buildColorTile('Background Color', settings.notesBackgroundColor, 'notesBackground', context),
                  _buildColorTile('Border Color', settings.notesCardBorderColor, 'notesBorder', context),
                  _buildColorTile('Text Color', settings.notesTextColor, 'notesText', context),
                  _buildColorTile('Step Border Color', settings.stepCardBorderColor, 'stepBorder', context),
                ],
              ),
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