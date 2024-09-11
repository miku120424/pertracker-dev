// TaskView.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';

class TaskView extends StatefulWidget {
  const TaskView({
    super.key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    required this.userId,
    this.task,
  });

  final TextEditingController taskControllerForTitle;
  final TextEditingController taskControllerForSubtitle;
  final String userId;
  final Task? task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late String title;
  late String subtitle;
  DateTime? time;
  DateTime? date;
  late String userId;

  @override
  void initState() {
    super.initState();
    title = widget.task?.title ?? '';
    subtitle = widget.task?.subtitle ?? '';
    time = widget.task?.createdAtTime;
    date = widget.task?.createdAtDate;
    userId = widget.task?.userId ?? widget.userId;

    widget.taskControllerForTitle.text = title;
    widget.taskControllerForSubtitle.text = subtitle;
  }

  String showTime(DateTime? time) {
    return DateFormat('hh:mm a').format(time ?? DateTime.now()).toString();
  }

  DateTime showTimeAsDateTime(DateTime? time) {
    return time ?? DateTime.now();
  }

  String showDate(DateTime? date) {
    return DateFormat.yMMMEd().format(date ?? DateTime.now()).toString();
  }

  DateTime showDateAsDateTime(DateTime? date) {
    return date ?? DateTime.now();
  }

  bool isTaskAlreadyExistBool() {
    return widget.task != null;
  }

  void isTaskAlreadyExistUpdateTask() {
    if (title.isNotEmpty && subtitle.isNotEmpty) {
      if (isTaskAlreadyExistBool()) {
        widget.task!.title = title;
        widget.task!.subtitle = subtitle;
        widget.task!.createdAtDate = date!;
        widget.task!.createdAtTime = time!;
        widget.task!.userId = userId;
        widget.task!.save();
      } else {
        var task = Task.create(
          title: title,
          createdAtTime: time,
          createdAtDate: date,
          subtitle: subtitle,
          userId: userId,
        );

        BaseWidget.of(context).dataStore.addTask(task: task);
      }
      Navigator.of(context).pop();
    } else {
      emptyFieldsWarning(context);
    }
  }

  void deleteTask() {
    widget.task?.delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MyAppBar(isTaskAlreadyExistBool: isTaskAlreadyExistBool),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildMiddleTextFieldsANDTimeAndDateSelection(
                      context, textTheme),
                  const SizedBox(
                    height: 50,
                  ),
                  _buildBottomButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isTaskAlreadyExistBool()
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        children: [
          if (isTaskAlreadyExistBool())
            Container(
              width: 150,
              height: 55,
              decoration: BoxDecoration(
                  border: Border.all(color: MyColors.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(15)),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minWidth: 150,
                height: 55,
                onPressed: deleteTask,
                color: Colors.white,
                child: const Row(
                  children: [
                    Icon(
                      Icons.close,
                      color: MyColors.primaryColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      MyString.deleteTask,
                      style: TextStyle(
                        color: MyColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            minWidth: 150,
            height: 55,
            onPressed: isTaskAlreadyExistUpdateTask,
            color: MyColors.primaryColor,
            child: Text(
              isTaskAlreadyExistBool()
                  ? MyString.updateTaskString
                  : MyString.addTaskString,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildMiddleTextFieldsANDTimeAndDateSelection(
      BuildContext context, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 535,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: TextFormField(
                controller: widget.taskControllerForTitle,
                cursorHeight: 30,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "What task are you planning😇?",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onFieldSubmitted: (value) {
                  setState(() {
                    title = value;
                  });
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: TextFormField(
                controller: widget.taskControllerForSubtitle,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  counter: Container(),
                  hintText: MyString.addNote,
                ),
                onFieldSubmitted: (value) {
                  setState(() {
                    subtitle = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    subtitle = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text("Set Due Date"),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(showTimeAsDateTime(time)),
              );
              if (selectedTime != null) {
                setState(() {
                  time = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                });
              }
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    color: MyColors.primaryColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    showTime(time),
                    style: const TextStyle(color: MyColors.primaryColor),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: showDateAsDateTime(date),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (selectedDate != null) {
                setState(() {
                  date = selectedDate;
                });
              }
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: MyColors.primaryColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    showDate(date),
                    style: const TextStyle(color: MyColors.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool Function() isTaskAlreadyExistBool;

  const MyAppBar({super.key, required this.isTaskAlreadyExistBool});

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
            Expanded(
              child: Text(
                isTaskAlreadyExistBool()
                    ? MyString.updateTaskString
                    : MyString.addTaskString,
                style: const TextStyle(fontSize: 24, color: Colors.black),
                textAlign: TextAlign.center,
              ),
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
