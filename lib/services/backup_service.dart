import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';

class BackupService {
  static Future<void> exportToJson(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final goals = await db.select(db.goals).get();
    final tasks = await db.select(db.tasks).get();
    final transactions = await db.select(db.transactions).get();

    final data = {
      'goals': goals
          .map((g) => {
                'title': g.title,
                'description': g.description,
                'target_date': g.targetDate?.toIso8601String(),
                'category': g.category,
                'progress_percentage': g.progressPercentage,
                'is_completed': g.isCompleted,
              })
          .toList(),
      'tasks': tasks
          .map((t) => {
                'title': t.title,
                'description': t.description,
                'due_date': t.dueDate?.toIso8601String(),
                'priority': t.priority,
                'is_completed': t.isCompleted,
                'goal_id': t.goalId,
              })
          .toList(),
      'transactions': transactions
          .map((tx) => {
                'amount': tx.amount,
                'type': tx.type,
                'category': tx.category,
                'description': tx.description,
                'date': tx.date.toIso8601String(),
                'source': tx.source,
                'sms_id': tx.smsId,
              })
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pulso_backup.json');
    await file.writeAsString(jsonString);
  }

  static Future<void> importFromJson(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pulso_backup.json');

    if (!await file.exists()) return;

    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    await db.delete(db.goals).go();
    await db.delete(db.tasks).go();
    await db.delete(db.transactions).go();

    for (final g in data['goals']) {
      await db.into(db.goals).insert(GoalsCompanion(
        title: Value(g['title']),
        description: Value(g['description']),
        targetDate: g['target_date'] != null
            ? Value(DateTime.tryParse(g['target_date']))
            : const Value.absent(),
        category: Value(g['category'] ?? 'Geral'),
        progressPercentage: Value(g['progress_percentage'] ?? 0),
        isCompleted: Value(g['is_completed'] ?? false),
      ));
    }

    for (final t in data['tasks']) {
      await db.into(db.tasks).insert(TasksCompanion(
        title: Value(t['title']),
        description: Value(t['description']),
        dueDate: t['due_date'] != null
            ? Value(DateTime.tryParse(t['due_date']))
            : const Value.absent(),
        priority: Value(t['priority'] ?? 'Média'),
        isCompleted: Value(t['is_completed'] ?? false),
        goalId: t['goal_id'] != null ? Value(t['goal_id']) : const Value.absent(),
      ));
    }

    for (final tx in data['transactions']) {
      await db.into(db.transactions).insert(TransactionsCompanion(
        amount: Value((tx['amount'] as num).toDouble()),
        type: Value(tx['type']),
        category: Value(tx['category'] ?? 'Geral'),
        description: Value(tx['description']),
        date: Value(DateTime.parse(tx['date'])),
        source: Value(tx['source'] ?? 'manual'),
        smsId: tx['sms_id'] != null ? Value(tx['sms_id']) : const Value.absent(),
      ));
    }
  }
}