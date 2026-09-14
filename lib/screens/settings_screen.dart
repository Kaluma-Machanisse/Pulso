import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../services/bank_notification_service.dart';
import 'login_screen.dart';
import '../theme/semantic_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingsSection(
            title: 'Conta',
            children: [
              ListTile(
                leading: Icon(
                    user != null ? Icons.account_circle_rounded : Icons.no_accounts_rounded),
                title: Text(
                    user != null ? (user.email ?? 'Sessão activa') : 'Sem sessão'),
                subtitle: Text(user != null
                    ? 'Ligado ao Supabase — a sincronização está disponível'
                    : 'Sem conta ligada — a app funciona só localmente'),
                trailing: user != null
                    ? TextButton(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Sair da conta?'),
                              content: const Text(
                                  'Os dados locais mantêm-se; deixas de sincronizar com o Supabase.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Sair')),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          await AuthService.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text('Sair'),
                      )
                    : TextButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen())),
                        child: const Text('Entrar'),
                      ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Aparência',
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_rounded),
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
              ListTile(
                leading: const Icon(Icons.attach_money_rounded),
                title: const Text('Moeda'),
                subtitle: Text(settings.currency),
                onTap: () => _showCurrencyDialog(context, ref, settings),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Dados',
            children: [
              ListTile(
                leading: const Icon(Icons.backup_rounded),
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
                        r == BackupResult.sucesso
                            ? null
                            : Theme.of(context).colorScheme.error,
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore_rounded),
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
                    BackupResult.semFicheiro =>
                      'Não existe nenhum backup local',
                    BackupResult.erro => 'Erro ao restaurar o backup',
                  };
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(msg),
                    backgroundColor:
                        r == BackupResult.sucesso
                            ? null
                            : Theme.of(context).colorScheme.error,
                  ));
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'Notificações',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_rounded),
                title: const Text('Notificações'),
                subtitle: const Text('Lembretes de tarefas e objectivos'),
                value: settings.notificationsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(val);
                },
              ),
              const _BankNotifTile(),
            ],
          ),
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

// ---------- Secção agrupada ----------
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
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
          icon: Icons.settings_suggest_rounded, // ícone para sistema
        ),
        _buildOption(
          title: 'Claro',
          value: ThemeMode.light,
          icon: Icons.light_mode_rounded,
        ),
        _buildOption(
          title: 'Escuro',
          value: ThemeMode.dark,
          icon: Icons.dark_mode_rounded,
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
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.circle_rounded),
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
        Icons.attach_money_rounded,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.circle_rounded),
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
        leading: Icon(Icons.notifications_active_rounded),
        title: Text('Ler notificações bancárias'),
        subtitle: Text('Disponível apenas no Android'),
        enabled: false,
      );
    }
    return ListTile(
      leading: const Icon(Icons.notifications_active_rounded),
      title: const Text('Ler notificações bancárias'),
      subtitle: Text(!_carregado
          ? 'A verificar…'
          : _ativo
              ? 'Activo — notificações de apps de banco/carteira viram transações'
              : 'Desligado — toca para dar acesso nas Definições do Android'),
      trailing: _ativo
          ? const Icon(Icons.check_circle_rounded, color: SemanticColors.receita)
          : const Icon(Icons.chevron_right_rounded),
      onTap: _abrir,
    );
  }
}
