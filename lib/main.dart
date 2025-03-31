import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

// I used the uuid package, to install run in terminal:
// flutter pub add uuid
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode =
      prefs.getBool('isDarkMode') ?? ThemeMode.system == ThemeMode.dark;

  await loadTasks();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(isDarkMode),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;
  var title = '';

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        title = 'New Task';
        page = NewTaskPage();
        break;
      case 1:
        title = 'My Tasks';
        page = MyTasksPage();
        break;
      case 2:
        title = 'Completed Tasks';
        page = CompleteTasksPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20),
              child: IconButton(
                onPressed: () {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
                icon:
                    Provider.of<ThemeProvider>(context).themeData == lightMode
                        ? Icon(Icons.light_mode)
                        : Icon(Icons.dark_mode),
              ),
            ),
          ],
        ),
        body: Padding(padding: EdgeInsets.all(30), child: page),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.add), label: 'New Task'),
            NavigationDestination(icon: Icon(Icons.done), label: 'My Tasks'),
            NavigationDestination(
              icon: Icon(Icons.done_all),
              label: 'Completed Tasks',
            ),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
        ),
      ),
    );
  }
}

/// 1- New Tasks Page
class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  @override
  Widget build(BuildContext context) {
    return TaskForm(formType: FormType.create);
  }
}

/// 2- My Tasks Page
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

/// 3- Completed Tasks Page
class CompleteTasksPage extends StatefulWidget {
  const CompleteTasksPage({super.key});

  @override
  State<CompleteTasksPage> createState() => _CompleteTasksPageState();
}

class _CompleteTasksPageState extends State<CompleteTasksPage> {
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
            TaskListView(progress: Progress.completed),
          ],
        ),
      ),
    );
  }
}

/// Task List Builder
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
      shrinkWrap: true,
      itemCount: taskList.length,

      itemBuilder: (context, i) {
        Task task = taskList[i];

        return ListTile(
          title: Text(task.title),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [progressDropDown(task), actionDropDown(task)],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.desc),
              SizedBox(height: 12),
              dateDurationChips(task),
              SizedBox(height: 20),
            ],
          ),
          titleAlignment: ListTileTitleAlignment.top,
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
                    return Center(
                      child: SizedBox(
                        width: maxWidth,
                        child: Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 15,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Update Task',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(Icons.close),
                                    ),
                                  ],
                                ),
                                TaskForm(formType: FormType.update, task: task),
                              ],
                            ),
                          ),
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
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Task'),
                  content: Text(
                    'Are you sure you want to delete "${task.title}"?',
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '"${task.title}" deleted successfully',
                            ),
                          ),
                        );

                        setState(() {
                          deleteTask(task.id);
                          Task.taskList.remove(task);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      child: Text('Delete'),
                    ),
                  ],
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                );
              },
            );
          },
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

/// Add/Update Task Form
enum FormType { create, update }

class TaskForm extends StatefulWidget {
  final FormType formType;
  final Task? task;
  const TaskForm({super.key, required this.formType, this.task});

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

                      Task.taskList.add(task);
                      await saveTask(task);

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

                      await updateTask(widget.task!.id);

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

/// Utils
double maxWidth = 1000;

Widget loadImage(String path) {
  bool imageExists = File(path).existsSync();

  if (imageExists) {
    return Image.asset(path);
  } else {
    return SizedBox.shrink();
  }
}

/// Task Logic
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
  keys.remove('isDarkMode');
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

/// Theme Provider
class ThemeProvider with ChangeNotifier {
  bool initialIsDarkMode = true;
  ThemeData _themeData;

  ThemeData get themeData => _themeData;

  ThemeProvider(bool isDarkMode)
    : _themeData = isDarkMode ? darkMode : lightMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() async {
    bool isDarkMode = (themeData == darkMode);
    themeData = isDarkMode ? lightMode : darkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !isDarkMode);
    notifyListeners();
  }
}

/// Theme Data 
ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),

  textTheme: _textTheme,
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),

  textTheme: _textTheme,
);

TextTheme _textTheme = TextTheme(
  titleSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  titleMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  titleLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
);
