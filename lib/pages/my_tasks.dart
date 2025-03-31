// Task Management Page
import 'package:assign2/task_list_view.dart';
import 'package:flutter/material.dart';
import '../task.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  @override
  Widget build(BuildContext context) {
    if (Task.taskList.isEmpty) {
      return const Center(child: Text('No tasks yet'));
    }

    List<Task> incompleteTasks =
        Task.taskList.where((task) => task.progress != Progress.completed).toList();

    if (incompleteTasks.isEmpty) {
      return const Center(child: Text('No tasks yet'));
    }

    return TaskListView(progress: Progress.notStarted);
  }
}
