import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../providers/database_provider.dart';

/// Sincronização entre a base de dados local (Drift) e o Supabase.
///
/// ESTRATÉGIA (app de utilizador único): "mirror". Cada `push` substitui
/// integralmente o conteúdo remoto pelo local; cada `pull` substitui o
/// local pelo remoto. Não há resolução de conflitos.
///
/// Todos os métodos devolvem `true` em sucesso e `false` se algo falhar,
/// para o ecrã poder mostrar o resultado real ao utilizador.
///
/// LIMITAÇÃO CONHECIDA: sem uma chave estável partilhada (ex.: uuid) por
/// linha, não é possível uma sincronização incremental verdadeira. Ver
/// docs/ARQUITECTURA.md › "Sincronização" para o plano de evolução.
class SyncService {
  static final _supabase = Supabase.instance.client;

  // ============ PUSH (local -> Supabase) ============

  static Future<bool> pushTransactions(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final rows = await db.select(db.transactions).get();

      await _supabase.from('transactions').delete().neq('id', -1);
      if (rows.isNotEmpty) {
        await _supabase.from('transactions').insert([
          for (final tx in rows)
            {
              'amount': tx.amount,
              'type': tx.type,
              'category': tx.category,
              'description': tx.description,
              'date': tx.date.toIso8601String(),
              'source': tx.source,
              'sms_id': tx.smsId,
            }
        ]);
      }
      return true;
    } catch (e) {
      debugPrint('pushTransactions falhou: $e');
      return false;
    }
  }

  static Future<bool> pushGoals(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final rows = await db.select(db.goals).get();

      await _supabase.from('goals').delete().neq('id', -1);
      if (rows.isNotEmpty) {
        await _supabase.from('goals').insert([
          for (final g in rows)
            {
              'title': g.title,
              'description': g.description,
              'target_date': g.targetDate?.toIso8601String(),
              'category': g.category,
              'progress_percentage': g.progressPercentage,
              'is_completed': g.isCompleted,
              'importance': g.importance,
              'term': g.term,
            }
        ]);
      }
      return true;
    } catch (e) {
      debugPrint('pushGoals falhou: $e');
      return false;
    }
  }

  static Future<bool> pushTasks(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final rows = await db.select(db.tasks).get();

      await _supabase.from('tasks').delete().neq('id', -1);
      if (rows.isNotEmpty) {
        await _supabase.from('tasks').insert([
          for (final t in rows)
            {
              'title': t.title,
              'description': t.description,
              'due_date': t.dueDate?.toIso8601String(),
              'priority': t.priority,
              'is_completed': t.isCompleted,
              'goal_id': t.goalId,
            }
        ]);
      }
      return true;
    } catch (e) {
      debugPrint('pushTasks falhou: $e');
      return false;
    }
  }

  static Future<bool> pushAll(WidgetRef ref) async {
    final r1 = await pushGoals(ref);
    final r2 = await pushTasks(ref);
    final r3 = await pushTransactions(ref);
    return r1 && r2 && r3;
  }

  // ============ PULL (Supabase -> local) ============

  static Future<bool> pullGoals(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final remote = await _supabase.from('goals').select();

      // Só toca no local depois de ter os dados remotos em memória, e faz
      // tudo dentro de uma transação (atómico: ou entra tudo, ou nada).
      await db.transaction(() async {
        await db.delete(db.goals).go();
        for (final row in remote) {
          await db.into(db.goals).insert(GoalsCompanion(
                title: Value(row['title'] as String),
                description: Value(row['description'] as String?),
                targetDate: row['target_date'] != null
                    ? Value(DateTime.tryParse(row['target_date'] as String))
                    : const Value.absent(),
                category: Value((row['category'] as String?) ?? 'Geral'),
                progressPercentage:
                    Value((row['progress_percentage'] as int?) ?? 0),
                isCompleted: Value((row['is_completed'] as bool?) ?? false),
                importance: Value((row['importance'] as String?) ?? 'Média'),
                term: Value((row['term'] as String?) ?? 'Curto prazo'),
              ));
        }
      });
      return true;
    } catch (e) {
      debugPrint('pullGoals falhou: $e');
      return false;
    }
  }

  static Future<bool> pullTasks(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final remote = await _supabase.from('tasks').select();

      await db.transaction(() async {
        await db.delete(db.tasks).go();
        for (final row in remote) {
          await db.into(db.tasks).insert(TasksCompanion(
                title: Value(row['title'] as String),
                description: Value(row['description'] as String?),
                dueDate: row['due_date'] != null
                    ? Value(DateTime.tryParse(row['due_date'] as String))
                    : const Value.absent(),
                priority: Value((row['priority'] as String?) ?? 'Média'),
                isCompleted: Value((row['is_completed'] as bool?) ?? false),
                goalId: row['goal_id'] != null
                    ? Value(row['goal_id'] as int)
                    : const Value.absent(),
              ));
        }
      });
      return true;
    } catch (e) {
      debugPrint('pullTasks falhou: $e');
      return false;
    }
  }

  static Future<bool> pullTransactions(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final remote = await _supabase.from('transactions').select();

      await db.transaction(() async {
        await db.delete(db.transactions).go();
        for (final row in remote) {
          await db.into(db.transactions).insert(TransactionsCompanion(
                amount: Value((row['amount'] as num).toDouble()),
                type: Value(row['type'] as String),
                category: Value((row['category'] as String?) ?? 'Geral'),
                description: Value(row['description'] as String?),
                date: Value(DateTime.parse(row['date'] as String)),
                source: Value((row['source'] as String?) ?? 'manual'),
                smsId: row['sms_id'] != null
                    ? Value(row['sms_id'] as String)
                    : const Value.absent(),
              ));
        }
      });
      return true;
    } catch (e) {
      debugPrint('pullTransactions falhou: $e');
      return false;
    }
  }

  static Future<bool> pullAll(WidgetRef ref) async {
    final r1 = await pullGoals(ref);
    final r2 = await pullTasks(ref);
    final r3 = await pullTransactions(ref);
    return r1 && r2 && r3;
  }
}
