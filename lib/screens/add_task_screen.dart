
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(Task) onSave;
  final Task? existingTask;
  final Function()? onDelete;

  const AddTaskScreen({
    super.key,
    required this.onSave,
    this.existingTask,
    this.onDelete,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Priority _priority = Priority.low;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _titleController.text = task.title;
      _descController.text = task.description;
      _priority = task.priority;
      _dueDate = task.dueDate;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _dueDate != null) {
      final task = Task(
        id: widget.existingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descController.text,
        priority: _priority,
        dueDate: _dueDate!,
        createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
      );

      widget.onSave(task);
      Navigator.pop(context);
    }
  }

  void _pickDueDate() async {
    try {
      final date = await showDatePicker(
        context: context,
        initialDate: _dueDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
        );

        if (time != null) {
          setState(() {
            _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking date/time: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick date/time")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Task" : "Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) =>
                value!.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: "Priority"),
                items: Priority.values.map((Priority p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_dueDate == null
                    ? "Pick Due Date & Time"
                    : "Due: ${DateFormat.yMd().add_jm().format(_dueDate!)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditing ? "Update Task" : "Save Task"),
              ),
              if (isEditing)
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Delete Task", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    widget.onDelete?.call();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

}
