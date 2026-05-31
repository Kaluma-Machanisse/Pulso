import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

// Tabela de Objectivos
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get category => text().withDefault(const Constant('Geral'))();
  IntColumn get progressPercentage => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabela de Tarefas
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get priority => text().withDefault(const Constant('Média'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get goalId => integer().nullable().references(Goals, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabela de Transações Financeiras
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();                     // valor (positivo = receita, negativo = despesa)
  TextColumn get type => text()();                       // 'receita' ou 'despesa'
  TextColumn get category => text().withDefault(const Constant('Geral'))();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))(); // 'manual', 'sms', etc.
  TextColumn get smsId => text().nullable()();            // ID da SMS original (futuro)
  IntColumn get goalId => integer().nullable().references(Goals, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Goals, Tasks, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pulso.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}