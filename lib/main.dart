
import 'package:assign2/theme/theme.dart';
import 'package:assign2/theme/theme_provider.dart';
import 'package:assign2/task.dart';
import 'package:assign2/pages/new_task.dart';
import 'package:assign2/pages/my_tasks.dart';
import 'pages/completed_tasks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  await loadTasks();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
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
