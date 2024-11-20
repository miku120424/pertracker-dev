import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fendhaaroo/data/hive_data_store.dart';
import 'package:fendhaaroo/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class EmployeeReport extends StatefulWidget {
  const EmployeeReport({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmployeeReportState createState() => _EmployeeReportState();
}

class _EmployeeReportState extends State<EmployeeReport> {
  final HiveDataStore _dataStore = HiveDataStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Employee Task Report',
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: _generateCSVReport,
            ),
          ]),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: _dataStore.listenToTasks(),
        builder: (context, box, _) {
          final tasks = box.values.toList();

          final tasksPerEmployee = <String, List<Task>>{};
          for (var task in tasks) {
            final employeeName = task.userId;
            tasksPerEmployee[employeeName] =
                (tasksPerEmployee[employeeName] ?? [])..add(task);
          }

          if (tasksPerEmployee.isEmpty) {
            return const Center(child: Text('No tasks available'));
          }

          return ListView.builder(
            itemCount: tasksPerEmployee.length,
            itemBuilder: (context, index) {
              final employee = tasksPerEmployee.keys.elementAt(index);
              final employeeTasks = tasksPerEmployee[employee]!;

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee: $employee',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Tasks: ${employeeTasks.length}'),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: employeeTasks.length,
                        itemBuilder: (context, taskIndex) {
                          final task = employeeTasks[taskIndex];
                          return ListTile(
                            title: Text(task.title),
                            subtitle: Text(
                              'Created on: ${DateFormat.yMd().format(task.createdAtDate)} | Status: ${task.isCompleted ? "Completed" : "Incomplete"}',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _generateCSVReport() async {
    final tasks = _dataStore.box.values.toList();

    final tasksPerEmployee = <String, List<Task>>{};
    for (var task in tasks) {
      final employeeName = task.userId;
      tasksPerEmployee[employeeName] = (tasksPerEmployee[employeeName] ?? [])
        ..add(task);
    }

    List<List<String>> csvData = [
      ['Employee', 'Task Title', 'Due Date', 'Status']
    ];

    for (var entry in tasksPerEmployee.entries) {
      for (var task in entry.value) {
        csvData.add([
          entry.key,
          task.title,
          DateFormat.yMd().format(task.createdAtDate),
          task.isCompleted ? 'Completed' : 'Incomplete'
        ]);
      }
    }

    final String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/employee_task_report.csv';

    final file = File(path);
    await file.writeAsString(csv);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report saved at $path'),
      ),
    );
  }
}
