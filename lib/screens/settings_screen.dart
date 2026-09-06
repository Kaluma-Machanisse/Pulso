import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../services/backup_service.dart';
import '../services/bank_notification_service.dart';

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
              final r = await BackupService.exportToJson(ref);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(r == BackupResult.sucesso
                    ? 'Backup criado com sucesso'
                    : 'Erro ao criar o backup'),
                backgroundColor:
                    r == BackupResult.sucesso ? null : Colors.red,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar backup local'),
            subtitle: const Text('Substitui TODOS os dados actuais'),
            onTap: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Restaurar backup?'),
                  content: const Text(
                      'Isto apaga os dados actuais e substitui pelos do ficheiro de backup. Continuar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Restaurar'),
                    ),
                  ],
                ),
              );
              if (confirmar != true) return;

              final r = await BackupService.importFromJson(ref);
              if (!context.mounted) return;
              final msg = switch (r) {
                BackupResult.sucesso => 'Dados restaurados do backup',
                BackupResult.semFicheiro => 'Não existe nenhum backup local',
                BackupResult.erro => 'Erro ao restaurar o backup',
              };
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg),
                backgroundColor:
                    r == BackupResult.sucesso ? null : Colors.red,
              ));
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
          const Divider(),

          // Leitura de notificações bancárias (Android)
          const _BankNotifTile(),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => _ThemeDialog(settings: settings, ref: ref),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (_) => _CurrencyDialog(settings: settings, ref: ref),
    );
  }
}

// ---------- Diálogo de Tema ----------
class _ThemeDialog extends StatefulWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _ThemeDialog({required this.settings, required this.ref});

  @override
  State<_ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<_ThemeDialog> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.settings.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Escolher tema'),
      children: [
        _buildOption(
          title: 'Sistema',
          value: ThemeMode.system,
          icon: Icons.settings_suggest, // ícone para sistema
        ),
        _buildOption(
          title: 'Claro',
          value: ThemeMode.light,
          icon: Icons.light_mode,
        ),
        _buildOption(
          title: 'Escuro',
          value: ThemeMode.dark,
          icon: Icons.dark_mode,
        ),
        TextButton(
          onPressed: () {
            widget.ref.read(settingsProvider.notifier).setThemeMode(_selected);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String title,
    required ThemeMode value,
    required IconData icon,
  }) {
    final isSelected = _selected == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : null,
      ),
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : const Icon(Icons.circle_outlined),
      onTap: () => setState(() => _selected = value),
    );
  }
}

// ---------- Diálogo de Moeda ----------
class _CurrencyDialog extends StatefulWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _CurrencyDialog({required this.settings, required this.ref});

  @override
  State<_CurrencyDialog> createState() => _CurrencyDialogState();
}

class _CurrencyDialogState extends State<_CurrencyDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.settings.currency;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Escolher moeda'),
      children: [
        _buildOption(
          title: 'MZN - Metical',
          value: 'MZN',
        ),
        _buildOption(
          title: 'USD - Dólar',
          value: 'USD',
        ),
        _buildOption(
          title: 'EUR - Euro',
          value: 'EUR',
        ),
        TextButton(
          onPressed: () {
            widget.ref.read(settingsProvider.notifier).setCurrency(_selected);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildOption({required String title, required String value}) {
    final isSelected = _selected == value;
    return ListTile(
      leading: Icon(
        Icons.attach_money,
        color: isSelected ? Colors.blue : null,
      ),
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : const Icon(Icons.circle_outlined),
      onTap: () => setState(() => _selected = value),
    );
  }
}
// ---------- Leitura de notificações bancárias ----------
class _BankNotifTile extends ConsumerStatefulWidget {
  const _BankNotifTile();

  @override
  ConsumerState<_BankNotifTile> createState() => _BankNotifTileState();
}

class _BankNotifTileState extends ConsumerState<_BankNotifTile> {
  bool _ativo = false;
  bool _carregado = false;

  bool get _android => !kIsWeb && Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  Future<void> _atualizar() async {
    final v = await BankNotificationService.isEnabled();
    if (!mounted) return;
    setState(() {
      _ativo = v;
      _carregado = true;
    });
  }

  Future<void> _abrir() async {
    await BankNotificationService.requestPermission();
    await BankNotificationService.start(ref);
    await _atualizar();
  }

  @override
  Widget build(BuildContext context) {
    if (!_android) {
      return const ListTile(
        leading: Icon(Icons.notifications_active_outlined),
        title: Text('Ler notificações bancárias'),
        subtitle: Text('Disponível apenas no Android'),
        enabled: false,
      );
    }
    return ListTile(
      leading: const Icon(Icons.notifications_active_outlined),
      title: const Text('Ler notificações bancárias'),
      subtitle: Text(!_carregado
          ? 'A verificar…'
          : _ativo
              ? 'Activo — notificações de apps de banco/carteira viram transações'
              : 'Desligado — toca para dar acesso nas Definições do Android'),
      trailing: _ativo
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.chevron_right),
      onTap: _abrir,
    );
  }
}
