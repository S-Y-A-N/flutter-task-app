// Task Management Page
import 'package:assign2/task_list_view.dart';
import 'package:assign2/utils.dart';
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
    List<Task> incompleteTasks = [];

    if (Task.taskList.isNotEmpty) {
      incompleteTasks =
          Task.taskList
              .where((task) => task.progress != Progress.completed)
              .toList();
    }

    if (Task.taskList.isEmpty || incompleteTasks.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          loadImage('assets/no_tasks.png'),
          Center(
            child: Text(
              'No tasks yet',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }

    return TaskListView(progress: Progress.notStarted);
  }
}
