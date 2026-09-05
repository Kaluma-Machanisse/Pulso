import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ids das tarefas selecionadas no modo de seleção múltipla.
/// Vazio = modo desligado.
final taskSelectionProvider =
    StateNotifierProvider<TaskSelection, Set<int>>((ref) => TaskSelection());

class TaskSelection extends StateNotifier<Set<int>> {
  TaskSelection() : super(const {});

  bool get active => state.isNotEmpty;

  void toggle(int id) {
    final next = {...state};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
  }

  void selectAll(Iterable<int> ids) => state = {...ids};
  void clear() => state = const {};
}
