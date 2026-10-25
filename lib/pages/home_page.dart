import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reminder/pages/add_task_page.dart';
import 'package:reminder/pages/edit_task_page.dart';
import 'package:reminder/services/noti_service.dart';
import 'package:reminder/themes/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tasks = Hive.box("tasks");
  final _notiService = NotiService();

  String formatDateTime(DateTime date) {
    return "${
      date.day.toString().padLeft(2, "0")
    }.${
      date.month.toString().padLeft(2, "0")
    }.${
      date.year
    } ${
      date.hour.toString().padLeft(2, "0")
    }:${
      date.minute.toString().padLeft(2, "0")
    }";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Reminder", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            }, 
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode 
              ? Icons.wb_sunny 
              : Icons.nightlight_round, 
              color: Colors.white
            )
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _buildTaskList()
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(
            builder: (context) => AddTaskPage()
          )
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList() {
    return ValueListenableBuilder(
      valueListenable: _tasks.listenable(),
      builder: (context, box, child) {
        if (box.isEmpty) {
          return Text(
            "No tasks yet.", style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
            )
          );
        }
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final data = box.getAt(index);
            return ListTile(
              title: Text(
                data["task"], 
                style: TextStyle(
                  decoration: (data["isComplete"] ?? false) 
                  ? TextDecoration.lineThrough
                  : null,
                  decorationColor: Theme.of(context).colorScheme.onSurface,
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ),
              subtitle: Text(
                formatDateTime(data["scheduledAt"]),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              leading: Checkbox(
                value: data["isComplete"] ?? false, 
                onChanged: (value) {
                  data["isComplete"] = value;
                  box.putAt(index, data);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  if (value == "delete") {
                    showDialog(
                      context: context, 
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        title: Text(
                          "Delete Task?", 
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
                        ),
                        content: Text(
                          "Are you sure you want to delete this task?",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Theme.of(context).colorScheme.primary)
                            )
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              box.deleteAt(index);
                              await _notiService.cancelNotification(data["id"]);
                            }, 
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Theme.of(context).colorScheme.primary)
                            )
                          ),
                        ],
                      ),
                    );
                  }
                  if (value == "edit") {
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => EditTaskPage(
                          taskName: data["task"], 
                          date: data["scheduledAt"], 
                          time: TimeOfDay.fromDateTime(data["scheduledAt"]), 
                          id: data["id"],
                        ),
                      )
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: "edit",
                      child: Text(
                        "Edit Task", style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                        )
                      ),
                    ),
                    const PopupMenuItem(
                      value: "delete",
                      child: Text("Delete Task", style: TextStyle(color: Colors.red)),
                    ),
                  ];
                },
                iconColor: Theme.of(context).colorScheme.onSurface,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onTap: () {
                showDialog(
                  context: context, 
                  builder: (context) => AlertDialog(
                    title: SelectableText(
                      data["task"], 
                      style: TextStyle(
                        decoration: (data["isComplete"] ?? false) 
                        ? TextDecoration.lineThrough 
                        : null,
                        color: Theme.of(context).colorScheme.onSurface,
                        decorationColor: Theme.of(context).colorScheme.onSurface,
                      )
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                );
              },
            );
          },
        );
      }
    );
  }
}