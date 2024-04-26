
import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/task_detail_page.dart';
import 'package:todo_app/screens/add_task_page.dart';
import 'package:todo_app/utils/database_helper.dart';
import 'package:intl/intl.dart';
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<List<Task>> _tasksFuture;
  String _sortCriteria = 'Deadline';

  @override
  void initState() {
    super.initState();
    _refreshTaskList();
  }

  Future<void> _refreshTaskList() async {
    setState(() {
      _tasksFuture = DatabaseHelper().getTasks();
    });
  }

  void _sortTasks(List<Task> tasks) {
    switch (_sortCriteria) {
      case 'Deadline':
        tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'Category':
        tasks.sort((a, b) {
          int categoryIdA = a.categoryId ?? 0;
          int categoryIdB = b.categoryId ?? 0;
          return categoryIdA.compareTo(categoryIdB);
        });
        break;
      case 'Custom':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Task List',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
            labelColor: Color.fromRGBO(233, 234, 235, 1),
            indicatorColor: Color.fromARGB(255, 233, 234, 235),
          ),
          actions: [
            PopupMenuButton<String>(
              initialValue: _sortCriteria,
              onSelected: (value) {
                setState(() {
                  _sortCriteria = value!;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Deadline', child: Text('Sort by Deadline')),
                const PopupMenuItem(value: 'Category', child: Text('Sort by Category')),
                const PopupMenuItem(value: 'Custom', child: Text('Custom Order')),
              ],
            ),
          ],
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
        body: TabBarView(
          children: [
            _buildTabView("In Progress", false),
            _buildTabView("Completed", true),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskPage()),
            );
            _refreshTaskList();
          },
          child: const Icon(Icons.add,color: Colors.white,),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTabView(String title, bool completed) {
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Task> tasks = snapshot.data!;
          _sortTasks(tasks);
          List<Task> sectionTasks =
              completed ? tasks.where((task) => task.completed).toList() : tasks.where((task) => !task.completed).toList();
          return _buildTaskSection(title, sectionTasks);
        }
      },
    );
  }

  Widget _buildTaskSection(String title, List<Task> sectionTasks) {
    if (sectionTasks.isEmpty) {
      return const Center(child: Text('No tasks found'));
    }

    Map<int, List<Task>> categoryTasks = {};
    sectionTasks.forEach((task) {
      int categoryId = task.categoryId ?? 0;
      if (!categoryTasks.containsKey(categoryId)) {
        categoryTasks[categoryId] = [];
      }
      categoryTasks[categoryId]!.add(task);
    });

    return ListView(
    children: categoryTasks.entries.map((entry) {
      int categoryId = entry.key;
      String categoryName = getCategoryName(categoryId);
      List<Task> tasks = entry.value;
      Color sectionColor = getCategoryColor(categoryId);
      return Container(
        margin: const EdgeInsets.all(0), // Set margin to zero to remove the border between sections
        child: _buildCategorySection(categoryName, tasks, sectionColor),
      );
    }).toList(),

    );
  }

  Widget _buildCategorySection(String categoryName, List<Task> categoryTasks, Color sectionColor) {
    return ExpansionTile(
      key: UniqueKey(),
      title: Text(
        categoryName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: categoryTasks.map((task) {
        return Card(
  elevation: 3,
  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  color: sectionColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  child: ListTile(
    title: Text(
      task.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.description,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 4), // Add some spacing between description and date
        Text(
          DateFormat('yyyy-MM-dd').format(task.deadline), // Display the task date
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    ),
    trailing: Checkbox(
      value: task.completed,
      onChanged: (value) async {
        setState(() {
          task.completed = value!;
        });
        await DatabaseHelper().updateTask(task);
      },
    ),
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
      );
      _refreshTaskList();
    },
  ),
);


      }).toList(),
    );
  }

  String getCategoryName(int categoryId) {
    Map<int, String> categoryMap = {
      1: 'Work',
	  2: 'Home',
      3: 'Personal',
      4: 'Other',
    };

    return categoryMap[categoryId] ?? 'Unknown Category';
  }

  Color getCategoryColor(int categoryId) {
    Map<int, Color> categoryColors = {
      1: Colors.blue,
      2: Colors.green,
      3: Colors.orange,
      4: Colors.purple,
    };

    return categoryColors[categoryId] ?? Colors.grey;
  }
}
