import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/data/hive_data_store.dart';
import 'package:flutter_hive_tdo/models/task.dart';
import 'package:flutter_hive_tdo/utils/colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TaskDashboardTest extends StatefulWidget {
  const TaskDashboardTest({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskDashboardTestState createState() => _TaskDashboardTestState();
}

class _TaskDashboardTestState extends State<TaskDashboardTest> {
  final HiveDataStore _dataStore = HiveDataStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: _dataStore.listenToTasks(),
        builder: (context, box, _) {
          final tasks = box.values.toList();

          final completedTasks = tasks.where((task) => task.isCompleted).length;

          final incompleteTasks = tasks.length - completedTasks;

          final tasksPerDate = <String, int>{};
          for (var task in tasks) {
            final dateKey = DateFormat.yMd().format(task.createdAtDate);
            tasksPerDate[dateKey] = (tasksPerDate[dateKey] ?? 0) + 1;
          }

          final tasksPerEmployee = <String, int>{};
          for (var task in tasks) {
            final employeeName = task.userId;
            tasksPerEmployee[employeeName] =
                (tasksPerEmployee[employeeName] ?? 0) + 1;
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Total Tasks Waru',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCircularSummaryCard(
                                  'Completed', completedTasks, tasks.length),
                              _buildCircularSummaryCard(
                                  'Incomplete', incompleteTasks, tasks.length),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tasks Per Due Date',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tasksPerDate.length,
                                itemBuilder: (context, index) {
                                  final date =
                                      tasksPerDate.keys.elementAt(index);
                                  final count = tasksPerDate[date]!;
                                  return ListTile(
                                    title: Text(date),
                                    trailing: Text('$count tasks'),
                                  );
                                },
                              ),
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tasks By Employee',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tasksPerEmployee.length,
                              itemBuilder: (context, index) {
                                final employee =
                                    tasksPerEmployee.keys.elementAt(index);
                                final count = tasksPerEmployee[employee]!;
                                return ListTile(
                                  title: Text(employee),
                                  trailing: Text('$count tasks'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircularSummaryCard(String title, int count, int total) {
    final double percentage = total == 0 ? 0 : count / total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 10,
                backgroundColor: MyColors.primaryColor.withOpacity(0.2),
                color: MyColors.primaryColor,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 30,
                ),
              ),
            ),
            const Text(
              "Task Dashboard",
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(150);
}
