import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task.dart';
import 'theme/theme_provider.dart';

enum FormType { create, update }

class TaskForm extends StatefulWidget {
  final FormType formType;
  final Task? task;
  final Function() notifyParent;
  const TaskForm({
    super.key,
    required this.formType,
    this.task,
    required this.notifyParent,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  TextEditingController taskTitle = TextEditingController();
  TextEditingController taskDesc = TextEditingController();
  TextEditingController taskDuration = TextEditingController();
  TextEditingController taskDueDate = TextEditingController();
  Progress taskProgress = Progress.notStarted;
  String? errorText;

  @override
  Widget build(BuildContext context) {
    if (widget.task != null && widget.formType == FormType.update) {
      taskTitle.text = widget.task!.title;
      taskDesc.text = widget.task!.desc;
      taskDuration.text =
          timeString(widget.task!.duration!) == "00:00"
              ? ""
              : timeString(widget.task!.duration!);
      taskDueDate.text =
          dateString(widget.task!.dueDate!) == "1970-01-01"
              ? ""
              : dateString(widget.task!.dueDate!);
      taskProgress = widget.task!.progress;
    }
    return Center(
      child: SizedBox(
        width: 1000,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            if (widget.formType == FormType.create)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Let's do this :)",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            TextField(
              controller: taskTitle,
              decoration: InputDecoration(
                label: Text('Title'),
                filled: true,
                prefixIcon: Icon(Icons.title),
                errorText: errorText,
              ),
              onChanged: (value) {
                if (errorText != null) {
                  setState(() {
                    errorText = null;
                  });
                }
              },
            ),
            TextField(
              controller: taskDesc,
              decoration: InputDecoration(
                label: Text('Description'),
                filled: true,
                prefixIcon: Icon(Icons.notes),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            TextField(
              controller: taskDuration,
              decoration: InputDecoration(
                label: Text('Duration'),
                filled: true,
                suffixText: 'hours',
                prefixIcon: Icon(Icons.access_time),
              ),
              onTap: () {
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 1, minute: 0),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: true),
                      child: child ?? Container(),
                    );
                  },
                ).then((pickedTime) {
                  if (pickedTime != null) {
                    var formattedTime = timeString(pickedTime);
                    taskDuration.text = formattedTime;
                  }
                });
              },
            ),
            TextField(
              controller: taskDueDate,
              decoration: InputDecoration(
                label: Text('Due Date'),
                filled: true,
                prefixIcon: Icon(Icons.today),
              ),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                ).then((pickedDate) {
                  if (pickedDate != null) {
                    String formattedDate = dateString(pickedDate);
                    taskDueDate.text = formattedDate;
                  }
                });
              },
            ),
            if (widget.formType == FormType.create)
              Wrap(
                spacing: 1,
                runSpacing: 1,
                children: [
                  customRadioButton(
                    "Not Started",
                    Progress.notStarted.icon,
                    Progress.notStarted,
                  ),
                  customRadioButton(
                    "In Progress",
                    Progress.inProgress.icon,
                    Progress.inProgress,
                  ),
                  customRadioButton(
                    "Completed",
                    Progress.completed.icon,
                    Progress.completed,
                  ),
                ],
              ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () async {
                if (taskTitle.text.isNotEmpty) {
                  // initialize safe types for duration & dueDate
                  taskDuration.text =
                      taskDuration.text == "" ? "00:00" : taskDuration.text;
                  taskDueDate.text =
                      taskDueDate.text == "" ? "1970-01-01" : taskDueDate.text;

                  switch (widget.formType) {
                    // NEW TASK
                    case FormType.create:
                      Task task = Task(
                        title: taskTitle.text,
                        desc: taskDesc.text,
                        duration: stringToTime(taskDuration.text),
                        dueDate: DateTime.parse(taskDueDate.text),
                        progress: taskProgress,
                      );

                      setState(() {
                        Task.taskList.add(task);
                        saveTask(task);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '"${taskTitle.text}" added successfully',
                          ),
                        ),
                      );

                      clearFields();
                      break;

                    // UPDATE TASK
                    case FormType.update:
                      widget.task!.title = taskTitle.text;
                      widget.task!.desc = taskDesc.text;
                      widget.task!.duration = stringToTime(taskDuration.text);
                      widget.task!.dueDate = DateTime.parse(taskDueDate.text);
                      widget.task!.progress = taskProgress;

                      setState(() {
                        updateTask(widget.task!.id);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '"${taskTitle.text}" updated successfully',
                          ),
                        ),
                      );

                      clearFields();
                      Navigator.pop(context);
                      break;
                  }
                } else if (taskTitle.text.isEmpty) {
                  errorText = 'Task title cannot be empty';
                }

                setState(() {});
                widget.notifyParent();
              },
              child:
                  widget.formType == FormType.create
                      ? Text('Add Task')
                      : Text('Update Task'),
            ),
          ],
        ),
      ),
    );
  }

  void clearFields() {
    taskTitle.text = "";
    taskDesc.text = "";
    taskDuration.text = "";
    taskDueDate.text = "";
    taskProgress = Progress.notStarted;
  }

  // function to create custom radio buttons
  Widget customRadioButton(String text, IconData iconData, Progress value) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            taskProgress = value;
          });
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          side: BorderSide(
            color:
                (taskProgress == value)
                    ? Provider.of<ThemeProvider>(
                      context,
                    ).themeData.colorScheme.onSurface
                    : Colors.grey,
          ),
        ),
        child: Row(
          spacing: 4,

          children: [
            Icon(
              iconData,
              color:
                  (taskProgress == value)
                      ? Provider.of<ThemeProvider>(
                        context,
                      ).themeData.colorScheme.onSurface
                      : Colors.grey,
            ),
            Text(
              text,
              style: TextStyle(
                color:
                    (taskProgress == value)
                        ? Provider.of<ThemeProvider>(
                          context,
                        ).themeData.colorScheme.onSurface
                        : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
