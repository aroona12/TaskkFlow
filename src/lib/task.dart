import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskScreen extends StatefulWidget {
  final int? taskIndex;
  final Map<String, String>? task;

  const TaskScreen({super.key, this.taskIndex, this.task});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();
  String? selectedAvailability;
  final List<String> availabilityOptions = ["High", "Medium", "Low"];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      name.text = widget.task!['title'] ?? "";
      date.text = widget.task!['date'] ?? "";
      selectedAvailability = widget.task!['availability'];
      if (date.text.isNotEmpty) {
        var parts = date.text.split('-');
        selectedDate = DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        date.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    name.dispose();
    date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding:
              const EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 30),
          child: Column(
            children: [
              TextFormField(
                controller: name,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: date,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  await _pickDate();
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedAvailability,
                decoration: InputDecoration(
                  labelText: "Availability",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                items: availabilityOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedAvailability = newValue;
                  });
                },
              ),
              SizedBox(height: 30),

              // Add Button
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: InkWell(
                  onTap: () async {
                    if (name.text.isEmpty ||
                        selectedDate == null ||
                        selectedAvailability == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    SharedPreferences sp =
                        await SharedPreferences.getInstance();

                    List<String> titles = sp.getStringList('titles') ?? [];
                    List<String> dates = sp.getStringList('dates') ?? [];
                    List<String> availabilities =
                        sp.getStringList('availabilities') ?? [];
                    List<String> completed =
                        sp.getStringList('completed') ?? [];

                    // Add new task
                    titles.add(name.text);
                    dates.add(
                        "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}");
                    availabilities.add(selectedAvailability!);
                    completed.add("false");

                    await sp.setStringList('titles', titles);
                    await sp.setStringList('dates', dates);
                    await sp.setStringList('availabilities', availabilities);
                    await sp.setStringList('completed', completed);

                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      'Add',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Update Button
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: InkWell(
                  onTap: () async {
                    if (widget.taskIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Select a task to update")),
                      );
                      return;
                    }

                    if (name.text.isEmpty ||
                        selectedDate == null ||
                        selectedAvailability == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    SharedPreferences sp =
                        await SharedPreferences.getInstance();

                    List<String> titles = sp.getStringList('titles') ?? [];
                    List<String> dates = sp.getStringList('dates') ?? [];
                    List<String> availabilities =
                        sp.getStringList('availabilities') ?? [];

                    // Update existing task
                    titles[widget.taskIndex!] = name.text;
                    dates[widget.taskIndex!] =
                        "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}";
                    availabilities[widget.taskIndex!] = selectedAvailability!;

                    await sp.setStringList('titles', titles);
                    await sp.setStringList('dates', dates);
                    await sp.setStringList('availabilities', availabilities);

                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      'Update',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
