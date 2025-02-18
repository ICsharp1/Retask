import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _frequencyController = TextEditingController();
  bool hasNotification = false;
  DateTime selectedStartDate = DateTime.now();
  Color selectedColor = Colors.blue;
  TimeOfDay? notificationTime;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _frequencyController.text = widget.taskToEdit!.frequencyInDays.toString();
      hasNotification = widget.taskToEdit!.hasNotification;
      selectedStartDate = widget.taskToEdit!.nextDue;
      selectedColor = widget.taskToEdit!.color;
      notificationTime = widget.taskToEdit!.notificationTime;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: notificationTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        notificationTime = picked;
        hasNotification = true;  // Enable notifications when time is selected
      });
    }
  }

  Color getContrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark 
        ? Colors.white 
        : Colors.black;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
              });
            },
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? 'Add New Task' : 'Edit Task'),
        actions: [
          if (widget.taskToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<TaskProvider>().deleteTask(widget.taskToEdit!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedStartDate)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: const Text('Task Color'),
                    subtitle: const Text('Tap the circle to change color'),
                    trailing: GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                          child: Icon(
                          Icons.colorize,
                          color: getContrastColor(selectedColor),
                        ),
                        ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency (days)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    helperText: 'How often should this task repeat?',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _frequencyController.text = '1';
                      return null;
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1) {
                      _frequencyController.text = '1';
                      return null;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: Text(hasNotification && notificationTime != null
                        ? 'Daily at ${_formatTimeOfDay(notificationTime!)}'
                        : 'Get reminded when task is due'),
                      value: hasNotification,
                      onChanged: (value) {
                        setState(() {
                          hasNotification = value;
                          if (value && notificationTime == null) {
                            _selectTime(context);
                          }
                        });
                      },
                    ),
                    if (hasNotification)
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(notificationTime != null 
                          ? _formatTimeOfDay(notificationTime!)
                          : 'Set notification time'),
                        onTap: () => _selectTime(context),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(widget.taskToEdit == null ? Icons.add : Icons.save),
                  label: Text(widget.taskToEdit == null ? 'Add Task' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = Task(
        title: _titleController.text.trim(),
        frequencyInDays: int.parse(_frequencyController.text),
        hasNotification: hasNotification,
        lastCompleted: selectedStartDate.subtract(const Duration(days: 1)),
        nextDue: selectedStartDate,
        color: selectedColor,
        notificationTime: hasNotification ? notificationTime : null,
      );

      final taskProvider = context.read<TaskProvider>();
      if (widget.taskToEdit != null) {
        taskProvider.updateTask(widget.taskToEdit!, task, context: context);
      } else {
        taskProvider.addTask(task, context: context);
      }
      Navigator.pop(context);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}