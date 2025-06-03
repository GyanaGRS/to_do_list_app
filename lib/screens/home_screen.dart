
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';
import '../utils/notification_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SortBy { priority, dueDate, createdAt }

TextEditingController _searchController = TextEditingController();
String _searchKeyword = '';


class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  SortBy _sortBy = SortBy.createdAt;

  List<Task> get _sortedTasks {
    List<Task> filtered = tasks.where((task) {
      final query = _searchKeyword.toLowerCase();
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();

    switch (_sortBy) {
      case SortBy.priority:
        filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortBy.dueDate:
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case SortBy.createdAt:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }



  void _addNewTask(Task newTask) {
    final box = Hive.box<Task>('tasksBox');
    setState(() {
      tasks.add(newTask);
      box.put(newTask.id, newTask);
      NotificationHelper.scheduleNotification(newTask);
    });
  }



  Widget _buildTaskItem(Task task) {
    Color getPriorityColor(Priority p) {
      switch (p) {
        case Priority.high:
          return Colors.red.shade300;
        case Priority.medium:
          return Colors.orange.shade300;
        case Priority.low:
          return Colors.green.shade300;
      }
    }


    return Card(
      color: getPriorityColor(task.priority).withOpacity(0.2),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Due: ${DateFormat.yMd().add_jm().format(task.dueDate)}\nPriority: ${task.priority.name.toUpperCase()}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.edit, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                existingTask: task,
                onSave: (updatedTask) {
                  final box = Hive.box<Task>('tasksBox');
                  setState(() {
                    int index = tasks.indexWhere((t) => t.id == updatedTask.id);
                    if (index != -1) {
                      tasks[index] = updatedTask;
                      box.put(updatedTask.id, updatedTask);
                      NotificationHelper.scheduleNotification(updatedTask); // reschedule
                    }
                  });
                },

                onDelete: () {
                  final box = Hive.box<Task>('tasksBox');
                  setState(() {
                    tasks.removeWhere((t) => t.id == task.id);
                    box.delete(task.id);
                    NotificationHelper.cancelNotification(task);
                  });
                },

              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final box = Hive.box<Task>('tasksBox');
    tasks = box.values.toList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ToDo List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search tasks",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<SortBy>(
              decoration: const InputDecoration(labelText: "Sort by"),
              value: _sortBy,
              items: SortBy.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
          ),
          Expanded(
            child: _sortedTasks.isEmpty
                ? const Center(child: Text("No tasks added yet."))
                : ListView.builder(
              itemCount: _sortedTasks.length,
              itemBuilder: (context, index) =>
                  _buildTaskItem(_sortedTasks[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                onSave: _addNewTask,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}
