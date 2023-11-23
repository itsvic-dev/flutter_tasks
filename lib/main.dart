import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'task.dart';

void main() {
  runApp(const ProviderScope(child: TasksApp()));
}

class TasksApp extends StatelessWidget {
  const TasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: ((lightDynamic, darkDynamic) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: lightDynamic,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkDynamic,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        title: 'Tasks',
        home: const TasksView(),
      );
    }));
  }
}

final taskListProvider = NotifierProvider<TaskList, List<Task>>(TaskList.new);

class TasksView extends HookConsumerWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 40,
        ),
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            ProviderScope(
              overrides: [_currentTask.overrideWithValue(tasks[i])],
              child: const TaskItem(),
            ),
          ],
        ],
      ),
    );
  }
}

final _currentTask = Provider<Task>((ref) => throw UnimplementedError());

class TaskItem extends HookConsumerWidget {
  const TaskItem({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
