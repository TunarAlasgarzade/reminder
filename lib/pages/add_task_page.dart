import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:reminder/components/my_button.dart';
import 'package:reminder/components/my_textfield.dart';
import 'package:reminder/models/task.dart';
import 'package:reminder/services/noti_service.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _tasks = Hive.box("tasks");
  final _taskController = TextEditingController();
  final _notiService = NotiService();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Add Task", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
                child: MyTextfield(
                  controller: _taskController, 
                  obscureText: false, 
                  hintText: "Task"
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: TextButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  }, 
                  child: Text(
                    selectedTime != null 
                    ? "${
                      selectedTime!.hour.toString().padLeft(2, "0")
                      }:${
                        selectedTime!.minute.toString().padLeft(2, "0")
                      }"
                    : "Time isn't selected",
                    style: TextStyle(color: Colors.green.shade600),
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context, 
                      firstDate: DateTime.now(), 
                      lastDate: DateTime(6000)
                    );
                
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  }, 
                  child: Text(
                    selectedDate != null 
                    ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" 
                    : "Date isn't selected",
                    style: TextStyle(color: Colors.green.shade600),
                  )
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    onPressed: () => Navigator.pop(context), 
                    text: "Cancel"
                  ),
                  MyButton(
                    onPressed: () async {
                      if (_taskController.text.trim().isNotEmpty && selectedTime != null && selectedDate != null) {
                        final int taskID = DateTime.now().hashCode;
                        final scheduledAt = DateTime(
                          selectedDate!.year, 
                          selectedDate!.month, 
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute
                        );
                        await _notiService.scheduleNotification(
                          id: taskID,
                          title: _taskController.text, 
                          body: "Today, ${
                            selectedTime!.hour.toString().padLeft(2, "0")
                            }:${selectedTime!.minute.toString().padLeft(2, "0")
                          }", 
                          year: selectedDate!.year, 
                          month: selectedDate!.month, 
                          day: selectedDate!.day, 
                          hour: selectedTime!.hour, 
                          minute: selectedTime!.minute
                        );
                        await _tasks.put(
                          taskID,
                          Task(
                            id:  taskID, 
                            task: _taskController.text, 
                            scheduledAt: scheduledAt,
                            isComplete: false,
                          ).toMap()
                        );
                        if (!mounted) return;
                        Navigator.pop(this.context);
                      }
                    }, 
                    text: "Save"
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}