// Task Management Page
import 'package:assign2/task_list_view.dart';
import 'package:flutter/material.dart';
import '../task.dart';

class CompleteTasksPage extends StatefulWidget {
  const CompleteTasksPage({super.key});

  @override
  State<CompleteTasksPage> createState() => _CompleteTasksPageState();
}

class _CompleteTasksPageState extends State<CompleteTasksPage> {
  @override
  Widget build(BuildContext context) {
    if (Task.taskList.isEmpty) {
      return Center(child: Text('No tasks yet'));
    }

    var completeTasks =
        Task.taskList
            .where((task) => task.progress == Progress.completed)
            .toList();
    if (completeTasks.isEmpty) {
      return Center(child: Text('No complete tasks yet'));
    }

    return TaskListView(progress: Progress.completed);
  }
}
