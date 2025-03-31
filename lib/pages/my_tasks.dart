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

    return Center(
      child: SizedBox(
        width: maxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You can do it!',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      "Only ${incompleteTasks.length} ${incompleteTasks.length == 1 ? 'task' : 'tasks'} left, don't be lazy!",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            TaskListView(progress: Progress.notStarted),
          ],
        ),
      ),
    );
  }
}
