import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ids dos objectivos selecionados no modo de seleção múltipla da lista.
/// Vazio = modo de seleção desligado.
final goalSelectionProvider =
    StateNotifierProvider<GoalSelection, Set<int>>((ref) => GoalSelection());

class GoalSelection extends StateNotifier<Set<int>> {
  GoalSelection() : super(const {});

  bool get active => state.isNotEmpty;

  void toggle(int id) {
    final next = {...state};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
  }

  void selectAll(Iterable<int> ids) => state = {...ids};

  void clear() => state = const {};
}
