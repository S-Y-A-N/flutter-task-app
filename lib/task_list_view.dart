import 'package:assign2/task_form.dart';
import 'package:flutter/material.dart';
import 'task.dart';

class TaskListView extends StatefulWidget {
  final Progress progress;
  const TaskListView({super.key, required this.progress});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    late List<Task> taskList;

    switch (widget.progress) {
      case Progress.notStarted || Progress.inProgress:
        taskList =
            Task.taskList
                .where((task) => task.progress != Progress.completed)
                .toList();
        break;
      case Progress.completed:
        taskList =
            Task.taskList
                .where((task) => task.progress == Progress.completed)
                .toList();
        break;
    }

    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, i) {
        Task task = taskList[i];

        return ListTile(
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [progressDropDown(task), actionDropDown(task)],
          ),
          titleAlignment: ListTileTitleAlignment.top,
          title: Text(task.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.desc),
              SizedBox(height: 12),
              dateDurationChips(task),
              SizedBox(height: 20),
            ],
          ),
          titleTextStyle: Theme.of(context).textTheme.titleSmall,
          subtitleTextStyle: Theme.of(context).textTheme.bodyLarge,
        );
      },
    );
  }

  Widget dateDurationChips(Task task) {
    return Wrap(
      spacing: 1,
      runSpacing: 1,
      children: [
        if (dateString(task.dueDate!) != "1970-01-01")
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                dateString(task.dueDate!),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        if (timeString(task.duration!) != "00:00")
          Card(
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                '${timeString(task.duration!)} hours',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget progressDropDown(Task task) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Progress.notStarted.icon),
          child: Text(Progress.notStarted.label),
          onPressed:
              () => setState(() {
                task.progress = Progress.notStarted;
                updateTask(task.id);
              }),
        ),
        MenuItemButton(
          leadingIcon: Icon(Progress.inProgress.icon),
          child: Text(Progress.inProgress.label),
          onPressed:
              () => setState(() {
                task.progress = Progress.inProgress;
                updateTask(task.id);
              }),
        ),
        MenuItemButton(
          leadingIcon: Icon(Progress.completed.icon),
          child: Text(Progress.completed.label),
          onPressed:
              () => setState(() {
                task.progress = Progress.completed;
                updateTask(task.id);
              }),
        ),
      ],
      builder: (context, controller, child) {
        return ElevatedButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [Icon(task.progress.icon), Text(task.progress.label)],
          ),
        );
      },
    );
  }

  Widget actionDropDown(Task task) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Icons.edit),
          child: Text('Edit'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 15,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Update Task',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                ),
                              ],
                            ),
                            TaskForm(
                              formType: FormType.update,
                              task: task,
                              setState: setState,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.delete),
          child: Text('Delete'),
          onPressed:
              () => setState(() {
                deleteTask(task.id);
                Task.taskList.remove(task);
              }),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(Icons.more_vert),
        );
      },
    );
  }
}
