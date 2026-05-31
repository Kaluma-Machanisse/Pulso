import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../services/backup_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          // Tema
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Tema'),
            subtitle: Text(
              settings.themeMode == ThemeMode.system
                  ? 'Sistema'
                  : settings.themeMode == ThemeMode.dark
                      ? 'Escuro'
                      : 'Claro',
            ),
            onTap: () => _showThemeDialog(context, ref, settings),
          ),
          const Divider(),

          // Moeda
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Moeda'),
            subtitle: Text(settings.currency),
            onTap: () => _showCurrencyDialog(context, ref, settings),
          ),
          const Divider(),

          // Backup
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup local (JSON)'),
            subtitle: const Text('Exportar dados para um ficheiro'),
            onTap: () async {
              await BackupService.exportToJson(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup criado com sucesso')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar backup local'),
            subtitle: const Text('Importar dados de um ficheiro'),
            onTap: () async {
              await BackupService.importFromJson(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados restaurados do backup')),
                );
              }
            },
          ),
          const Divider(),

          // Notificações
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notificações'),
            subtitle: const Text('Lembretes de tarefas e objectivos'),
            value: settings.notificationsEnabled,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setNotificationsEnabled(val);
            },
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Escolher tema'),
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Sistema'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setThemeMode(val!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Claro'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setThemeMode(val!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Escuro'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setThemeMode(val!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Escolher moeda'),
        children: [
          RadioListTile<String>(
            title: const Text('MZN - Metical'),
            value: 'MZN',
            groupValue: settings.currency,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setCurrency(val!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('USD - Dólar'),
            value: 'USD',
            groupValue: settings.currency,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setCurrency(val!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('EUR - Euro'),
            value: 'EUR',
            groupValue: settings.currency,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).setCurrency(val!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}