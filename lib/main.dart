import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar.large(
            title: Text("Tasks"),
          ),
          const SliverToBoxAdapter(child: NewTaskTextBox()),
          const SliverToBoxAdapter(child: Divider()),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, i) {
              return ProviderScope(
                overrides: [
                  _currentTask.overrideWithValue(tasks[i]),
                ],
                child: const Column(
                  children: [
                    TaskItem(),
                    Divider(),
                  ],
                ),
              );
            },
            childCount: tasks.length,
          )),
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
    final task = ref.watch(_currentTask);
    return ListTile(
      title: Text(task.description),
      leading: Checkbox(
        value: task.completed,
        onChanged: (value) =>
            ref.read(taskListProvider.notifier).toggle(task.id),
      ),
    );
  }
}

class NewTaskTextBox extends HookConsumerWidget {
  const NewTaskTextBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "New task",
        ),
        onSubmitted: (String value) {
          ref.read(taskListProvider.notifier).add(value);
          controller.clear();
        },
      ),
    );
  }
}
