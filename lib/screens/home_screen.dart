import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../services/sms_service.dart';
import '../services/bank_notification_service.dart';
import '../services/reminder_service.dart';
import '../services/goal_reminder_service.dart';
import '../services/goal_archive_service.dart';
import '../services/goal_progress_service.dart';
import '../services/goal_term_service.dart';
import '../services/task_reminder_service.dart';
import '../services/habit_service.dart';
import '../services/report_service.dart';
import '../providers/database_provider.dart';
import 'goals_screen.dart';
import 'tasks_screen.dart';
import 'finance_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';  // <-- adicionado

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TasksScreen(),
    GoalsScreen(),
    FinanceScreen(),
    StatsScreen(),
    SettingsScreen(),  // <-- adicionado
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // A leitura de SMS só existe no Android (o plugin `telephony` e o
      // `permission_handler` não têm implementação para desktop/web).
      if (!kIsWeb && Platform.isAndroid) {
        await SmsService.initialize(ref);
        await BankNotificationService.start(ref);
      }
      await ReminderService.checkAndNotify(ref);

      // Fecha sozinhos os hábitos cujo período já terminou.
      await HabitService.sweepClose(ref);
      // O prazo dos objectivos "amadurece" sozinho com a proximidade da data.
      await GoalTermService.recomputeAll(ref);
      // Progresso dos objectivos com tarefas ligadas = % de tarefas concluídas.
      await GoalProgressService.recomputeAll(ref);
      // Objectivos a 100% são arquivados (não apagados).
      await GoalArchiveService.sweep(ref);
      // Mantém os lembretes agendados alinhados com o estado actual da BD.
      await GoalReminderService.rescheduleAll(ref);
      await TaskReminderService.rescheduleAll(ref);
      // Gera os relatórios mensais em falta (do mês anterior para trás).
      await ReportService.ensureMonthlyReports(ref);
      // Retenção: pergunta antes de apagar relatórios com mais de 1 ano.
      await _perguntarRetencao();
    });
  }

  Future<void> _perguntarRetencao() async {
    final db = ref.read(databaseProvider);
    final antigos = await ReportService.expiredReports(db);
    if (antigos.isEmpty || !mounted) return;

    final apagar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Relatórios antigos'),
        content: Text(
            'Há ${antigos.length} relatório(s) com mais de 1 ano. Eliminar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (apagar == true) {
      await ReportService.deleteReports(db, antigos.map((r) => r.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // importante para 5 itens
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Objectivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finanças',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config.',
          ),
        ],
      ),
    );
  }
}