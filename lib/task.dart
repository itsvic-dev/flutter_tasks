import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class Task {
  const Task({
    required this.id,
    required this.description,
    this.completed = false,
  });

  final String id;
  final String description;
  final bool completed;
}

class TaskList extends Notifier<List<Task>> {
  @override
  List<Task> build() => [
        const Task(id: 'task-1', description: 'hii'),
        const Task(id: 'task-2', description: 'all my homies hate vercel'),
      ];

  void add(String description) {
    state = [
      ...state,
      Task(
        id: _uuid.v4(),
        description: description,
      ),
    ];
  }

  void toggle(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          Task(
            id: task.id,
            description: task.description,
            completed: !task.completed,
          )
        else
          task,
    ];
  }
}
