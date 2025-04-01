// Task Management Page
import 'package:assign2/task_list_view.dart';
import 'package:assign2/utils.dart';
import 'package:flutter/material.dart';
import '../task.dart';

class CompleteTasksPage extends StatefulWidget {
  const CompleteTasksPage({super.key});

  @override
  State<CompleteTasksPage> createState() => _CompleteTasksPageState();
}

class _CompleteTasksPageState extends State<CompleteTasksPage> {
    refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Task> completeTasks = [];

    if (Task.taskList.isNotEmpty) {
      completeTasks =
          Task.taskList
              .where((task) => task.progress == Progress.completed)
              .toList();
    }

    if (Task.taskList.isEmpty || completeTasks.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          loadImage('assets/no_tasks.png'),
          Center(
            child: Text(
              'No completed tasks yet',
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
                      'Keep up the good work!',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'So far, you have completed ${completeTasks.length} ${completeTasks.length == 1 ? 'task' : 'tasks'}.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            TaskListView(progress: Progress.completed, notifyParent: refresh,),
          ],
        ),
      ),
    );
  }
}
