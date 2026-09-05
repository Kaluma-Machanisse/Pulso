import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';

/// Relatório mensal — por agora só do módulo de Objectivos.
/// (Os relatórios financeiros e de tarefas serão adicionados depois.)
class MonthlyReport {
  final String month; // 'AAAA-MM'
  final DateTime generatedAt;
  final List<ReportGoal> completed; // objectivos arquivados nesse mês
  final List<ReportGoal> active; // objectivos em curso no momento da geração

  MonthlyReport({
    required this.month,
    required this.generatedAt,
    required this.completed,
    required this.active,
  });

  int get completedCount => completed.length;
  int get activeCount => active.length;
  double get avgActiveProgress => active.isEmpty
      ? 0
      : active.map((g) => g.progress).reduce((a, b) => a + b) / active.length;

  Map<String, dynamic> toJson() => {
        'month': month,
        'generated_at': generatedAt.toIso8601String(),
        'completed': completed.map((g) => g.toJson()).toList(),
        'active': active.map((g) => g.toJson()).toList(),
      };

  factory MonthlyReport.fromJson(Map<String, dynamic> j) => MonthlyReport(
        month: j['month'] as String,
        generatedAt: DateTime.parse(j['generated_at'] as String),
        completed: (j['completed'] as List)
            .map((e) => ReportGoal.fromJson(e as Map<String, dynamic>))
            .toList(),
        active: (j['active'] as List)
            .map((e) => ReportGoal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ReportGoal {
  final String title;
  final String category;
  final String importance;
  final String term;
  final int progress;
  final DateTime? targetDate;
  final DateTime? archivedAt;

  ReportGoal({
    required this.title,
    required this.category,
    required this.importance,
    required this.term,
    required this.progress,
    this.targetDate,
    this.archivedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'importance': importance,
        'term': term,
        'progress': progress,
        'target_date': targetDate?.toIso8601String(),
        'archived_at': archivedAt?.toIso8601String(),
      };

  factory ReportGoal.fromJson(Map<String, dynamic> j) => ReportGoal(
        title: j['title'] as String,
        category: j['category'] as String? ?? 'Geral',
        importance: j['importance'] as String? ?? 'Média',
        term: j['term'] as String? ?? 'Curto prazo',
        progress: j['progress'] as int? ?? 0,
        targetDate: j['target_date'] != null
            ? DateTime.tryParse(j['target_date'] as String)
            : null,
        archivedAt: j['archived_at'] != null
            ? DateTime.tryParse(j['archived_at'] as String)
            : null,
      );

  factory ReportGoal.fromGoal(Goal g) => ReportGoal(
        title: g.title,
        category: g.category,
        importance: g.importance,
        term: g.term,
        progress: g.progressPercentage,
        targetDate: g.targetDate,
        archivedAt: g.archivedAt,
      );
}

/// Relatório financeiro mensal.
class FinancialReport {
  final String month;
  final DateTime generatedAt;
  final double receitas;
  final double despesas;
  final int nTransacoes;
  final List<MapEntry<String, double>> despesasPorCategoria; // maior primeiro

  FinancialReport({
    required this.month,
    required this.generatedAt,
    required this.receitas,
    required this.despesas,
    required this.nTransacoes,
    required this.despesasPorCategoria,
  });

  double get saldo => receitas - despesas;

  Map<String, dynamic> toJson() => {
        'month': month,
        'generated_at': generatedAt.toIso8601String(),
        'receitas': receitas,
        'despesas': despesas,
        'n_transacoes': nTransacoes,
        'por_categoria': [
          for (final e in despesasPorCategoria)
            {'categoria': e.key, 'valor': e.value}
        ],
      };

  factory FinancialReport.fromJson(Map<String, dynamic> j) => FinancialReport(
        month: j['month'] as String,
        generatedAt: DateTime.parse(j['generated_at'] as String),
        receitas: (j['receitas'] as num).toDouble(),
        despesas: (j['despesas'] as num).toDouble(),
        nTransacoes: j['n_transacoes'] as int? ?? 0,
        despesasPorCategoria: [
          for (final e in (j['por_categoria'] as List? ?? []))
            MapEntry(e['categoria'] as String, (e['valor'] as num).toDouble())
        ],
      );
}

class ReportService {
  ReportService._();

  static const int _retentionMonths = 12;
  static const kObjectivos = 'objectivos';
  static const kFinanceiro = 'financeiro';

  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static DateTime _monthStart(int year, int month) => DateTime(year, month);

  /// Constrói (sem gravar) o relatório de um mês.
  static Future<MonthlyReport> buildForMonth(
      AppDatabase db, int year, int month) async {
    final start = _monthStart(year, month);
    final end = _monthStart(year, month + 1);
    final all = await db.select(db.goals).get();

    final completed = all
        .where((g) =>
            g.archivedAt != null &&
            !g.archivedAt!.isBefore(start) &&
            g.archivedAt!.isBefore(end))
        .map(ReportGoal.fromGoal)
        .toList();

    final active =
        all.where((g) => g.archivedAt == null).map(ReportGoal.fromGoal).toList();

    return MonthlyReport(
      month: monthKey(start),
      generatedAt: DateTime.now(),
      completed: completed,
      active: active,
    );
  }

  /// Relatório financeiro de um mês (sem gravar).
  static Future<FinancialReport> buildFinancialForMonth(
      AppDatabase db, int year, int month) async {
    final start = _monthStart(year, month);
    final end = _monthStart(year, month + 1);
    final txs = (await db.select(db.transactions).get())
        .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
        .toList();

    double receitas = 0, despesas = 0;
    final Map<String, double> cat = {};
    for (final t in txs) {
      if (t.type == 'receita') {
        receitas += t.amount;
      } else {
        despesas += t.amount;
        cat[t.category] = (cat[t.category] ?? 0) + t.amount;
      }
    }
    final porCat = cat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return FinancialReport(
      month: monthKey(start),
      generatedAt: DateTime.now(),
      receitas: receitas,
      despesas: despesas,
      nTransacoes: txs.length,
      despesasPorCategoria: porCat,
    );
  }

  /// Gera os relatórios (objectivos + financeiro) em falta desde o mês mais
  /// antigo com actividade até ao mês passado. Chamar no arranque da app.
  static Future<void> ensureMonthlyReports(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final currentKey = monthKey(now);

    final existentes = (await db.select(db.reports).get())
        .map((r) => '${r.month}|${r.type}')
        .toSet();

    // Ponto de partida: primeiro mês com objectivos ou transações.
    final goals = await db.select(db.goals).get();
    final txs = await db.select(db.transactions).get();
    final datas = [
      ...goals.map((g) => g.createdAt),
      ...txs.map((t) => t.date),
    ];
    if (datas.isEmpty) return;
    final earliest = datas.reduce((a, b) => a.isBefore(b) ? a : b);
    var cursor = DateTime(earliest.year, earliest.month);

    while (monthKey(cursor) != currentKey) {
      final key = monthKey(cursor);

      if (!existentes.contains('$key|$kObjectivos')) {
        final r = await buildForMonth(db, cursor.year, cursor.month);
        if (r.completed.isNotEmpty || r.active.isNotEmpty) {
          await db.into(db.reports).insert(ReportsCompanion(
                month: Value(key),
                type: const Value(kObjectivos),
                generatedAt: Value(DateTime.now()),
                dataJson: Value(jsonEncode(r.toJson())),
              ));
        }
      }

      if (!existentes.contains('$key|$kFinanceiro')) {
        final r = await buildFinancialForMonth(db, cursor.year, cursor.month);
        if (r.nTransacoes > 0) {
          await db.into(db.reports).insert(ReportsCompanion(
                month: Value(key),
                type: const Value(kFinanceiro),
                generatedAt: Value(DateTime.now()),
                dataJson: Value(jsonEncode(r.toJson())),
              ));
        }
      }

      cursor = DateTime(cursor.year, cursor.month + 1);
    }
  }

  static MonthlyReport parse(Report row) =>
      MonthlyReport.fromJson(jsonDecode(row.dataJson) as Map<String, dynamic>);

  static FinancialReport parseFinancial(Report row) => FinancialReport.fromJson(
      jsonDecode(row.dataJson) as Map<String, dynamic>);

  /// Relatórios com mais de [_retentionMonths] meses.
  static Future<List<Report>> expiredReports(AppDatabase db) async {
    final now = DateTime.now();
    final limite = DateTime(now.year, now.month - _retentionMonths);
    final rows = await db.select(db.reports).get();
    return rows.where((r) {
      final parts = r.month.split('-');
      final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return d.isBefore(limite);
    }).toList();
  }

  static Future<void> deleteReports(AppDatabase db, List<int> ids) async {
    await (db.delete(db.reports)..where((r) => r.id.isIn(ids))).go();
  }
}
