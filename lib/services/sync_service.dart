import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../providers/database_provider.dart';

class SyncService {
  static final _supabase = Supabase.instance.client;

  // ============ PUSH (enviar para o Supabase) ============

  static Future<void> pushTransactions(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final localTxs = await db.select(db.transactions).get();

    for (final tx in localTxs) {
      try {
        await _supabase.from('transactions').upsert({
          'amount': tx.amount,
          'type': tx.type,
          'category': tx.category,
          'description': tx.description,
          'date': tx.date.toIso8601String(),
          'source': tx.source,
          'sms_id': tx.smsId,
        });
      } catch (e) {
        debugPrint('Erro ao sincronizar transação $tx: $e');
      }
    }
  }

  static Future<void> pushGoals(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final localGoals = await db.select(db.goals).get();

    for (final goal in localGoals) {
      try {
        await _supabase.from('goals').upsert({
          'title': goal.title,
          'description': goal.description,
          'target_date': goal.targetDate?.toIso8601String(),
          'category': goal.category,
          'progress_percentage': goal.progressPercentage,
          'is_completed': goal.isCompleted,
        });
      } catch (e) {
        debugPrint('Erro ao sincronizar objectivo $goal: $e');
      }
    }
  }

  static Future<void> pushTasks(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final localTasks = await db.select(db.tasks).get();

    for (final task in localTasks) {
      try {
        await _supabase.from('tasks').upsert({
          'title': task.title,
          'description': task.description,
          'due_date': task.dueDate?.toIso8601String(),
          'priority': task.priority,
          'is_completed': task.isCompleted,
          'goal_id': task.goalId,
        });
      } catch (e) {
        debugPrint('Erro ao sincronizar tarefa $task: $e');
      }
    }
  }

  static Future<void> pushAll(WidgetRef ref) async {
    await pushTransactions(ref);
    await pushGoals(ref);
    await pushTasks(ref);
  }

  // ============ PULL (baixar do Supabase) ============

  /// Baixa objectivos do Supabase e substitui os locais.
  static Future<void> pullGoals(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    try {
      final remoteData = await _supabase.from('goals').select();
      // Apaga todos os objectivos locais
      await db.delete(db.goals).go();
      for (final row in remoteData) {
        await db.into(db.goals).insert(GoalsCompanion(
          title: Value(row['title']),
          description: Value(row['description']),
          targetDate: row['target_date'] != null
              ? Value(DateTime.tryParse(row['target_date']))
              : const Value.absent(),
          category: Value(row['category'] ?? 'Geral'),
          progressPercentage: Value(row['progress_percentage'] ?? 0),
          isCompleted: Value(row['is_completed'] ?? false),
        ));
      }
    } catch (e) {
      debugPrint('Erro ao puxar objectivos: $e');
    }
  }

  /// Baixa tarefas do Supabase e substitui as locais.
  static Future<void> pullTasks(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    try {
      final remoteData = await _supabase.from('tasks').select();
      await db.delete(db.tasks).go();
      for (final row in remoteData) {
        await db.into(db.tasks).insert(TasksCompanion(
          title: Value(row['title']),
          description: Value(row['description']),
          dueDate: row['due_date'] != null
              ? Value(DateTime.tryParse(row['due_date']))
              : const Value.absent(),
          priority: Value(row['priority'] ?? 'Média'),
          isCompleted: Value(row['is_completed'] ?? false),
          goalId: row['goal_id'] != null ? Value(row['goal_id']) : const Value.absent(),
        ));
      }
    } catch (e) {
      debugPrint('Erro ao puxar tarefas: $e');
    }
  }

  /// Baixa transações do Supabase e substitui as locais.
  static Future<void> pullTransactions(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    try {
      final remoteData = await _supabase.from('transactions').select();
      await db.delete(db.transactions).go();
      for (final row in remoteData) {
        await db.into(db.transactions).insert(TransactionsCompanion(
          amount: Value((row['amount'] as num).toDouble()),
          type: Value(row['type']),
          category: Value(row['category'] ?? 'Geral'),
          description: Value(row['description']),
          date: Value(DateTime.parse(row['date'])),
          source: Value(row['source'] ?? 'manual'),
          smsId: row['sms_id'] != null ? Value(row['sms_id']) : const Value.absent(),
        ));
      }
    } catch (e) {
      debugPrint('Erro ao puxar transações: $e');
    }
  }

  /// Pull completo (todas as tabelas).
  static Future<void> pullAll(WidgetRef ref) async {
    await pullGoals(ref);
    await pullTasks(ref);
    await pullTransactions(ref);
  }
}