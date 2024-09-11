// HomeView.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/main.dart';
import 'package:flutter_hive_tdo/models/task.dart';
import 'package:flutter_hive_tdo/models/users.dart';
import 'package:flutter_hive_tdo/view/home/dashboard.dart';
import 'package:flutter_hive_tdo/view/home/login.dart';
import 'package:flutter_hive_tdo/view/home/user_management.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../view/home/widgets/task_widget.dart';
import '../../view/tasks/task_view.dart';
import '../../utils/strings.dart';

class HomeView extends StatefulWidget {
  final User user;

  const HomeView({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> dKey = GlobalKey<SliderDrawerState>();

  int checkDoneTask(List<Task> task) {
    int i = 0;
    for (Task doneTasks in task) {
      if (doneTasks.isCompleted) {
        i++;
      }
    }
    return i;
  }

  double valueOfTheIndicator(List<Task> task) {
    return task.isNotEmpty ? task.length.toDouble() : 3.0;
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    var textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToTasks(),
      builder: (ctx, Box<Task> box, Widget? child) {
        var tasks =
            box.values.where((task) => task.userId == widget.user.id).toList();

        tasks.sort(((a, b) => a.createdAtDate.compareTo(b.createdAtDate)));

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FAB(userId: widget.user.id),
          body: SliderDrawer(
            isDraggable: false,
            key: dKey,
            animationDuration: 1000,
            appBar: MyAppBar(
              drawerKey: dKey,
            ),
            slider: MySlider(user: widget.user),
            child: _buildBody(
              tasks,
              base,
              textTheme,
            ),
          ),
        );
      },
    );
  }

  SizedBox _buildBody(
    List<Task> tasks,
    BaseWidget base,
    TextTheme textTheme,
  ) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              width: double.infinity,
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor:
                          const AlwaysStoppedAnimation(MyColors.primaryColor),
                      backgroundColor: Colors.grey,
                      value: tasks.isEmpty
                          ? 0.0
                          : checkDoneTask(tasks) / valueOfTheIndicator(tasks),
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.user.username}'s Tasks",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 38,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.visible,
                        maxLines: 5,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                            "${checkDoneTask(tasks)} of ${tasks.length} tasks",
                            style: textTheme.titleMedium),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Divider(
                thickness: 2,
                indent: 100,
              ),
            ),
            // Using Expanded here will help with flexibility
            tasks.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      var task = tasks[index];

                      return Dismissible(
                        direction: DismissDirection.horizontal,
                        background: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(MyString.deletedTask,
                                style: TextStyle(
                                  color: Colors.grey,
                                ))
                          ],
                        ),
                        onDismissed: (direction) {
                          base.dataStore.deleteTask(task: task);
                        },
                        key: Key(task.id),
                        child: TaskWidget(
                          task: tasks[index],
                        ),
                      );
                    },
                    shrinkWrap:
                        true, // Use shrinkWrap to size ListView to its children
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeIn(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset(
                            lottieURL,
                            animate: tasks.isNotEmpty ? false : true,
                          ),
                        ),
                      ),
                      FadeInUp(
                        from: 30,
                        child: const Text(MyString.doneAllTask),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MySlider extends StatelessWidget {
  final User user;
  late String title;
  late String subtitle;

  MySlider({super.key, required this.user});

  final List<IconData> icons = [
    CupertinoIcons.check_mark,
    CupertinoIcons.list_bullet,
    CupertinoIcons.paperclip,
    CupertinoIcons.person,
    CupertinoIcons.power,
  ];

  final List<String> texts = [
    "Tasks",
    "Dashboard",
    "Reports",
    "User Management",
    "Sign Out",
  ];

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 90),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: MyColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.5))),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    user.username,
                    style: textTheme.displayMedium,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ListView.builder(
            itemCount: icons.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (ctx, i) {
              return InkWell(
                onTap: () {
                  if (texts[i] == "Tasks") {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => HomeView(
                          user: user,
                        ),
                      ),
                    );
                  } else if (texts[i] == "Dashboard") {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const TaskDashboard(),
                      ),
                    );
                  } else if (texts[i] == "Reports") {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => HomeView(
                          user: user,
                        ),
                      ),
                    );
                  } else if (texts[i] == "User Management") {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const UserManagementPage(),
                      ),
                    );
                  } else if (texts[i] == "Sign Out") {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: ListTile(
                    leading: Icon(
                      icons[i],
                      color: Colors.white,
                      size: 30,
                    ),
                    title: Text(
                      texts[i],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.drawerKey,
  });

  final GlobalKey<SliderDrawerState> drawerKey;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _MyAppBarState extends State<MyAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        controller.forward();
        widget.drawerKey.currentState!.openSlider();
      } else {
        controller.reverse();
        widget.drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 132,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: controller,
                  size: 40,
                ),
                onPressed: toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAB extends StatelessWidget {
  final String userId;

  const FAB({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => TaskView(
              userId: userId,
              taskControllerForSubtitle: TextEditingController(),
              taskControllerForTitle: TextEditingController(),
              task: null,
            ),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
