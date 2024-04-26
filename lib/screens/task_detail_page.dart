import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/utils/database_helper.dart';
import 'package:todo_app/models/category.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  TaskDetailPage({required this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late Category _selectedCategory;
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  bool _isTitleFocused = false;
  bool _isDescriptionFocused = false;
  bool _isCompleted = false;

  final List<Category> _predefinedCategories = [
    Category(id: 1, name: 'Work'),
    Category(id: 2, name: 'Home'),
    Category(id: 3, name: 'Personal'),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _isCompleted = widget.task.completed;
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.deadline;
    _selectedCategory = _predefinedCategories
        .firstWhere((category) => category.id == widget.task.categoryId);
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _titleFocusNode.addListener(_onTitleFocusChange);
    _descriptionFocusNode.addListener(_onDescriptionFocusChange);
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_onTitleFocusChange);
    _descriptionFocusNode.removeListener(_onDescriptionFocusChange);
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _onTitleFocusChange() {
    setState(() {
      _isTitleFocused = _titleFocusNode.hasFocus;
    });
  }

  void _onDescriptionFocusChange() {
    setState(() {
      _isDescriptionFocused = _descriptionFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                        'Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // No, do not delete
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Yes, delete
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                await DatabaseHelper().deleteTask(widget.task.id!);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              enabled: !_isCompleted,
              focusNode: _titleFocusNode,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _isTitleFocused ? Colors.blue : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              enabled: !_isCompleted,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _isDescriptionFocused ? Colors.blue : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              enabled: !_isCompleted,
              title: const Text('Deadline'),
              subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              items: _predefinedCategories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  enabled: !_isCompleted,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
                 onPressed:!_isCompleted  ? () async {
                final updatedTask = Task(
                  id: widget.task.id,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  deadline: _selectedDate,
                  categoryId: _selectedCategory.id,
                );
                await DatabaseHelper().updateTask(updatedTask);
                Navigator.pop(context);
              }:null,
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.blue,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 3.0,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
