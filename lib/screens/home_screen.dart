
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/task_view_model.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';
import '../utils/notification_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SortBy { priority, dueDate, createdAt }


class _HomeScreenState extends State<HomeScreen> {

  TextEditingController _searchController = TextEditingController();



  void _addNewTask(Task newTask) {
    try {
      Provider.of<TaskViewModel>(context, listen: false).addTask(newTask);
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
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
                  Provider.of<TaskViewModel>(context, listen: false).updateTask(updatedTask);
                },
                onDelete: () {
                  Provider.of<TaskViewModel>(context, listen: false).deleteTask(task);
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
                Provider.of<TaskViewModel>(context, listen: false).setSearchKeyword(value);
              },

            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<SortBy>(
              decoration: const InputDecoration(labelText: "Sort by"),
              value: context.watch<TaskViewModel>().sortBy,
              items: SortBy.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                Provider.of<TaskViewModel>(context, listen: false).setSortBy(value!);
              },

            ),
          ),
          Expanded(
            child: Consumer<TaskViewModel>(
              builder: (context, taskVM, child) {
                final tasks = taskVM.sortedTasks;
                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks added yet."));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
                );
              },
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

}
