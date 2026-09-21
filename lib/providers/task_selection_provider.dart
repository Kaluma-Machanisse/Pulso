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

/// Se o histórico (grelha de check-ins) de um hábito está expandido —
/// escondido por omissão para não sobrecarregar visualmente a lista.
final habitHistoryExpandedProvider =
    StateProvider.family<bool, int>((ref, taskId) => false);
