import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFilter {
  final String priority; // 'todas' | 'Alta' | 'Média' | 'Baixa'
  final int? goalId; // null = todos os objectivos
  final bool showCompleted;

  const TaskFilter({
    this.priority = 'todas',
    this.goalId,
    this.showCompleted = false,
  });

  bool get active =>
      priority != 'todas' || goalId != null || showCompleted;

  TaskFilter copyWith({
    String? priority,
    Object? goalId = _sentinel,
    bool? showCompleted,
  }) {
    return TaskFilter(
      priority: priority ?? this.priority,
      goalId: goalId == _sentinel ? this.goalId : goalId as int?,
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }

  static const _sentinel = Object();
}

final taskFilterProvider =
    StateNotifierProvider<TaskFilterNotifier, TaskFilter>(
        (ref) => TaskFilterNotifier());

class TaskFilterNotifier extends StateNotifier<TaskFilter> {
  TaskFilterNotifier() : super(const TaskFilter());

  void setPriority(String p) => state = state.copyWith(priority: p);
  void setGoal(int? id) => state = state.copyWith(goalId: id);
  void toggleCompleted(bool v) => state = state.copyWith(showCompleted: v);
  void reset() => state = const TaskFilter();
}
