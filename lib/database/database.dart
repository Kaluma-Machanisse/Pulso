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

  // v2 — controlam a frequência e organização dos lembretes.
  // importance: 'Baixa' | 'Média' | 'Alta' | 'Crítica'  (nº de lembretes/semana)
  TextColumn get importance => text().withDefault(const Constant('Média'))();
  // term: 'Curto prazo' | 'Longo prazo'
  TextColumn get term => text().withDefault(const Constant('Curto prazo'))();

  // v3 — objectivos 100% concluídos são arquivados (não apagados).
  // Se != null, o objectivo sai da lista principal.
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

// Tabela de Relatórios mensais (v3)
class Reports extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Mês a que o relatório diz respeito, no formato 'AAAA-MM'.
  TextColumn get month => text()();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();
  // Conteúdo do relatório serializado em JSON (ver ReportService).
  TextColumn get dataJson => text()();
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

@DriftDatabase(tables: [Goals, Tasks, Transactions, Reports])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1 -> v2: campos de importância e prazo nos objectivos.
          if (from < 2) {
            await m.addColumn(goals, goals.importance);
            await m.addColumn(goals, goals.term);
          }
          // v2 -> v3: arquivo de objectivos + tabela de relatórios.
          if (from < 3) {
            await m.addColumn(goals, goals.archivedAt);
            await m.createTable(reports);
          }
        },
        // NOTA: `PRAGMA foreign_keys = ON` NÃO é activado de propósito.
        // A sincronização actual (mirror, sem uuid) recria linhas com novos
        // ids, o que quebraria referências goalId. Activar apenas quando a
        // sync passar a usar chaves estáveis. Ver docs/ARQUITECTURA.md.
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pulso.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}