import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  List<Map<String, String>> completedTasks = [];

  @override
  void initState() {
    super.initState();
    getCompletedTasks();
  }

  Future<void> getCompletedTasks() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> titles = sp.getStringList('titles') ?? [];
    List<String> dates = sp.getStringList('dates') ?? [];
    List<String> availabilities = sp.getStringList('availabilities') ?? [];
    List<String> completed = sp.getStringList('completed') ?? [];

    completedTasks.clear();

    for (int i = 0; i < titles.length; i++) {
      if (i < completed.length && completed[i] == "true") {
        completedTasks.add({
          'title': titles[i],
          'date': dates[i],
          'availability': availabilities[i],
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Completed Tasks"),
      centerTitle: true,
      backgroundColor: Colors.orange,),
      body: completedTasks.isEmpty
          ? Center(child: Text("No completed tasks"))
          : ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      task['title'] ?? "",
                      style: TextStyle(decoration: TextDecoration.lineThrough),
                    ),
                    subtitle: Text(
                        "Date: ${task['date']}\nAvailability: ${task['availability']}"),
                  ),
                );
              },
            ),
    );
  }
}
