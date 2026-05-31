import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado dos filtros
class FinanceFilter {
  final String type; // 'todas', 'receita', 'despesa'
  final String category; // 'Todas' ou uma categoria específica
  final int? month; // 1-12, null para todos
  final int? year; // 2024, 2025, null para todos

  const FinanceFilter({
    this.type = 'todas',
    this.category = 'Todas',
    this.month,
    this.year,
  });

  FinanceFilter copyWith({
    String? type,
    String? category,
    int? month,
    int? year,
  }) {
    return FinanceFilter(
      type: type ?? this.type,
      category: category ?? this.category,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

// Provider dos filtros
final financeFilterProvider =
    StateNotifierProvider<FinanceFilterNotifier, FinanceFilter>((ref) {
  return FinanceFilterNotifier();
});

class FinanceFilterNotifier extends StateNotifier<FinanceFilter> {
  FinanceFilterNotifier() : super(const FinanceFilter());

  void updateType(String type) => state = state.copyWith(type: type);
  void updateCategory(String category) =>
      state = state.copyWith(category: category);
  void updateMonth(int? month) => state = state.copyWith(month: month);
  void updateYear(int? year) => state = state.copyWith(year: year);
  void reset() => state = const FinanceFilter();
}