import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/task.dart';
import 'package:task_manager/CompletedTasksScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, String>> taskList = [];

  @override
  void initState() {
    super.initState();
    getdata();
  }

//getting data
  Future<void> getdata() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    List<String> titles = sp.getStringList('titles') ?? [];
    List<String> dates = sp.getStringList('dates') ?? [];
    List<String> availabilities = sp.getStringList('availabilities') ?? [];
    List<String> completed = sp.getStringList('completed') ?? [];

    taskList.clear();

    for (int i = 0; i < titles.length; i++) {
      taskList.add({
        'title': titles[i],
        'date': dates[i],
        'availability': availabilities[i],
        'completed': (i < completed.length) ? completed[i] : "false",
      });
    }

    setState(() {});
  }

  Future<void> toggleCompleted(int index, bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> completed = sp.getStringList('completed') ?? [];

    if (index < completed.length) {
      completed[index] = value.toString();
    } else {
      completed.add(value.toString());
    }

    await sp.setStringList('completed', completed);
    getdata();
  }

  Future<void> deleteTask(int index) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> titles = sp.getStringList('titles') ?? [];
    List<String> dates = sp.getStringList('dates') ?? [];
    List<String> availabilities = sp.getStringList('availabilities') ?? [];
    List<String> completed = sp.getStringList('completed') ?? [];

    titles.removeAt(index);
    dates.removeAt(index);
    availabilities.removeAt(index);
    if (index < completed.length) completed.removeAt(index);

    await sp.setStringList('titles', titles);
    await sp.setStringList('dates', dates);
    await sp.setStringList('availabilities', availabilities);
    await sp.setStringList('completed', completed);

    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.orange,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "My Tasks",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Text(
                  "${taskList.length} ${taskList.length == 1 ? "task" : "tasks"}",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check_circle_outline, size: 28),
              tooltip: "Completed Tasks",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompletedTasksScreen()),
                );
              },
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
      body: taskList.isEmpty
          ? Center(
              child: Text(
              "No tasks available",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ))
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];
                bool isCompleted = task['completed'] == "true";
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      task['title'] ?? "",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                        "Date: ${task['date']}\nAvailability: ${task['availability']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isCompleted,
                          onChanged: (bool? value) {
                            toggleCompleted(index, value ?? false);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Delete Task"),
                                content: Text(
                                    "Are you sure you want to delete this task?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text("Cancel")),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text("Delete")),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              deleteTask(index);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskScreen(taskIndex: index, task: task),
                        ),
                      ).then((_) {
                        getdata();
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskScreen()),
          ).then((_) {
            getdata();
          });
        },
      ),
    );
  }
}
