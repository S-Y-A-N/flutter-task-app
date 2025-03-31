import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum Progress {
  notStarted('Not Started', Icons.do_not_disturb_on),
  inProgress('In Progress', Icons.pending),
  completed('Completed', Icons.check_circle);

  const Progress(this.label, this.icon);

  final String label;
  final IconData icon;
}

Progress getProgressValue(String label) {
  switch (label) {
    case 'Not Started':
      return Progress.notStarted;
    case 'In Progress':
      return Progress.inProgress;
    case 'Completed':
      return Progress.completed;
    default:
      throw UnimplementedError(
        'Progress value for label "$label" not implemented',
      );
  }
}

class Task {
  String? id;
  String title;
  String desc;
  TimeOfDay? duration;
  DateTime? dueDate;
  Progress progress;

  Task({
    this.id,
    required this.title,
    this.desc = '',
    this.duration,
    this.dueDate,
    this.progress = Progress.notStarted,
  }) {
    id = id ?? Uuid().v1();
  }

  static List<Task> taskList = [];
}

Task getTaskById(id) {
  return Task.taskList.where((task) => task.id == id).toList()[0];
}

Future<void> saveTask(Task task) async {
  final prefs = await SharedPreferences.getInstance();
  // object not encoding to json!
  Map<String, dynamic> taskMap = {
    'id': task.id,
    'title': task.title,
    'desc': task.desc,
    'duration': timeString(task.duration!),
    'dueDate': dateString(task.dueDate!),
    'progress': task.progress.label,
  };
  final json = jsonEncode(taskMap);
  await prefs.setString(task.id!, json);
}

Future<void> loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final prefsMap = <String, dynamic>{};

  for (String key in keys) {
    prefsMap[key] = prefs.get(key);
    final taskMap = jsonDecode(prefsMap[key]);

    Task task = Task(
      id: taskMap['id'],
      title: taskMap['title'],
      desc: taskMap['desc'],
      duration: stringToTime(taskMap['duration']),
      dueDate: DateTime.parse(taskMap['dueDate']),
      progress: getProgressValue(taskMap['progress']),
    );

    Task.taskList.add(task);
  }
}

Future<void> deleteAllTasks() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  return;
}

Future<void> deleteTask(id) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(id);
  return;
}

Future<void> updateTask(id) async {
  deleteTask(id);
  saveTask(getTaskById(id));
  return;
}

String timeString(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

String dateString(DateTime date) {
  return '${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

TimeOfDay stringToTime(String time) {
  return TimeOfDay(
    hour: int.parse(time.split(":")[0]),
    minute: int.parse(time.split(":")[1]),
  );
}
