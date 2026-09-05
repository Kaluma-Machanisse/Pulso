import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../services/sms_service.dart';
import '../services/reminder_service.dart';
import '../services/goal_reminder_service.dart';
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
    GoalsScreen(),
    TasksScreen(),
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
      }
      await ReminderService.checkAndNotify(ref);
      // Mantém os lembretes agendados alinhados com o estado actual da BD.
      await GoalReminderService.rescheduleAll(ref);
    });
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
            icon: Icon(Icons.flag),
            label: 'Objectivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tarefas',
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