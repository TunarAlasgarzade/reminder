import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:reminder/components/my_button.dart';
import 'package:reminder/components/my_textfield.dart';
import 'package:reminder/models/task.dart';
import 'package:reminder/services/noti_service.dart';

class EditTaskPage extends StatefulWidget {
  final String taskName;
  final int id;
  final DateTime? date;
  final TimeOfDay? time;
  const EditTaskPage({
    super.key,
    required this.taskName,
    required this.date,
    required this.time,
    required this.id,
  });

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _tasks = Hive.box("tasks");
  final _taskController = TextEditingController();
  final _notiService = NotiService();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
    selectedTime = widget.time;
    _taskController.text = widget.taskName;
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text("Edit Task", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
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
                        final scheduledAt = DateTime(
                          selectedDate!.year, 
                          selectedDate!.month, 
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute
                        );
                        await _notiService.scheduleNotification(
                          id: widget.id,
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
                          widget.id,
                          Task(
                            id:  widget.id, 
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