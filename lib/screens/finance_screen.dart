import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/transaction_providers.dart';
import '../providers/filter_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/budget_providers.dart';
import '../providers/stats_providers.dart';
import '../services/sync_service.dart';
import '../theme/semantic_colors.dart';
import '../theme/category_style.dart';
import '../theme/pulso_theme.dart';
import '../widgets/confirm_dialog.dart';
import 'add_transaction_screen.dart';
import 'budgets_screen.dart';

/// Barra de progresso que anima do zero até ao valor actual sempre que este
/// muda — dá vida a algo que, estático, parecia só uma barra genérica.
class _AnimatedBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color background;
  final double height;

  const _AnimatedBar({
    required this.value,
    required this.color,
    required this.background,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: v,
          minHeight: height,
          backgroundColor: background,
          color: color,
        ),
      ),
    );
  }
}

String _tituloDia(DateTime d) {
  final hoje = DateTime.now();
  final h = DateTime(hoje.year, hoje.month, hoje.day);
  final dia = DateTime(d.year, d.month, d.day);
  final diff = h.difference(dia).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Ontem';
  const meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];
  return '${d.day} ${meses[d.month - 1]}${d.year != hoje.year ? ' ${d.year}' : ''}';
}

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _showFilters = false;
  bool _showChart = true;
  bool _syncing = false;

  final List<String> _types = ['todas', 'receita', 'despesa'];
  final List<String> _categories = [
    'Todas', 'Geral', 'Alimentação', 'Transporte', 'Saúde',
    'Lazer', 'Salário', 'Negócio', 'SMS', 'Outro',
  ];
  static const _meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  Future<void> _sincronizar() async {
    setState(() => _syncing = true);
    final ok = await SyncService.pushAll(ref);
    if (!mounted) return;
    setState(() => _syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Sincronização completa'
          : 'Falha na sincronização. Verifica a ligação.'),
      backgroundColor:
          ok ? null : Theme.of(context).colorScheme.error,
    ));
  }

  void _abrirOrcamentos() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetsScreen()));

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(financeFilterProvider);
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final moeda = ref.watch(settingsProvider).currency;
    final anoActual = DateTime.now().year;
    final gastosMes = ref.watch(currentMonthExpensesByCategoryProvider);
    final overCount = ref.watch(overBudgetCountProvider);
    final geral = ref.watch(overallBudgetStatusProvider);
    final monthly = ref.watch(monthlyStatsProvider).valueOrNull ?? const {};
    final scheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final chaveMes = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final mesActual = monthly[chaveMes];
    final receitasMes = mesActual?['receitas'] ?? 0;
    final despesasMes = mesActual?['despesas'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteira'),
        actions: [
          IconButton(
            tooltip: _showFilters ? 'Esconder filtros' : 'Filtros',
            icon: Icon(
              Icons.filter_alt_rounded,
              color: _showFilters
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            tooltip: 'Sincronizar',
            icon: _syncing
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync_rounded),
            onPressed: _syncing ? null : _sincronizar,
          ),
          IconButton(
            tooltip: 'Orçamentos',
            icon: const Icon(Icons.pie_chart_outline_rounded),
            onPressed: _abrirOrcamentos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _HeroMes(
              receitas: receitasMes,
              despesas: despesasMes,
              moeda: moeda,
            ),
          ),

          if (geral.active)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: InkWell(
                onTap: _abrirOrcamentos,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Limite mensal',
                            style: Theme.of(context).textTheme.labelLarge),
                        const Spacer(),
                        Text(
                          '${geral.spent.toStringAsFixed(0)} / '
                          '${geral.limit.toStringAsFixed(0)} $moeda',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: geral.over ? scheme.error : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _AnimatedBar(
                      value: geral.pct.toDouble(),
                      color: geral.over ? scheme.error : scheme.primary,
                      background: scheme.surfaceContainerHighest,
                    ),
                  ],
                ),
              ),
            ),

          if (geral.over)
            Material(
              color: scheme.errorContainer,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
                title: Text(
                  'Limite mensal geral ultrapassado',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: scheme.onErrorContainer),
                onTap: _abrirOrcamentos,
              ),
            ),

          if (overCount > 0)
            Material(
              color: scheme.errorContainer,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
                title: Text(
                  overCount == 1
                      ? '1 orçamento ultrapassado este mês'
                      : '$overCount orçamentos ultrapassados este mês',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: scheme.onErrorContainer),
                onTap: _abrirOrcamentos,
              ),
            ),

          _BudgetSummary(moeda: moeda, onTap: _abrirOrcamentos),

          // Mini-gráfico: gastos do mês por categoria
          if (gastosMes.isNotEmpty)
            _MonthExpenseChart(
              data: gastosMes,
              moeda: moeda,
              expanded: _showChart,
              onToggle: () => setState(() => _showChart = !_showChart),
            ),

          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(children: [
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: filter.type,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: _types
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(t == 'todas' ? 'Todas' : t)))
                          .toList(),
                      onChanged: (v) => ref
                          .read(financeFilterProvider.notifier)
                          .updateType(v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: filter.category,
                      decoration:
                          const InputDecoration(labelText: 'Categoria'),
                      items: _categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => ref
                          .read(financeFilterProvider.notifier)
                          .updateCategory(v!),
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: filter.month,
                      decoration: const InputDecoration(labelText: 'Mês'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todos')),
                        for (var m = 1; m <= 12; m++)
                          DropdownMenuItem(
                              value: m, child: Text(_meses[m - 1])),
                      ],
                      onChanged: (v) =>
                          ref.read(financeFilterProvider.notifier).updateMonth(v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: filter.year,
                      decoration: const InputDecoration(labelText: 'Ano'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todos')),
                        for (var y = anoActual - 4; y <= anoActual; y++)
                          DropdownMenuItem(value: y, child: Text('$y')),
                      ],
                      onChanged: (v) =>
                          ref.read(financeFilterProvider.notifier).updateYear(v),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Limpar filtros',
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () =>
                        ref.read(financeFilterProvider.notifier).reset(),
                  ),
                ]),
              ]),
            ),

          Expanded(
            child: filteredAsync.when(
              data: (txList) {
                if (txList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 56, color: scheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('Sem transações.',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Regista a primeira despesa ou receita, ou espera '
                            'que a app detecte uma SMS do M-Pesa/BIM.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AddTransactionScreen()),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Registar transação'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final items = <Object>[];
                DateTime? ultimoDia;
                for (final tx in txList) {
                  final dia = DateTime(tx.date.year, tx.date.month, tx.date.day);
                  if (ultimoDia == null || dia != ultimoDia) {
                    items.add(dia);
                    ultimoDia = dia;
                  }
                  items.add(tx);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88, top: 4),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    if (item is DateTime) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text(
                          _tituloDia(item).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.5,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      );
                    }
                    final tx = item as Transaction;
                    final isReceita = tx.type == 'receita';
                    final cor = isReceita
                        ? SemanticColors.receita
                        : SemanticColors.despesa;
                    final catCor = CategoryStyle.color(tx.category);
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: SemanticColors.despesa,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      confirmDismiss: (_) => confirmarEliminacao(
                          context, tx.description ?? tx.category),
                      onDismissed: (_) =>
                          ref.read(deleteTransactionProvider(tx.id)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: catCor.withValues(alpha: 0.14),
                          foregroundColor: catCor,
                          child: Icon(
                            CategoryStyle.icon(tx.category),
                            size: 20,
                          ),
                        ),
                        title: Text(tx.description ?? tx.category,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${tx.category}'
                          '${tx.source != 'manual' ? '  ·  ${tx.source}' : ''}',
                        ),
                        trailing: Text(
                          '${isReceita ? '+' : '-'}${tx.amount.toStringAsFixed(2)} $moeda',
                          style: TextStyle(
                            color: cor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(tx: tx),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMes extends StatelessWidget {
  final double receitas;
  final double despesas;
  final String moeda;
  const _HeroMes({
    required this.receitas,
    required this.despesas,
    required this.moeda,
  });

  @override
  Widget build(BuildContext context) {
    final p = PulsoPalette.of(context);
    final total = receitas + despesas;
    final fracReceita = total <= 0 ? 0.5 : receitas / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PulsoRadius.lg),
        color: p.surfaceElevated,
        border: Border.all(color: p.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTE MÊS', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Receitas',
                  valor: '${receitas.toStringAsFixed(0)} $moeda',
                  color: SemanticColors.receita,
                ),
              ),
              Container(
                width: 1,
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: p.borderSubtle,
              ),
              Expanded(
                child: _HeroStat(
                  label: 'Despesas',
                  valor: '${despesas.toStringAsFixed(0)} $moeda',
                  color: SemanticColors.despesa,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: fracReceita),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Row(
                children: [
                  Expanded(
                    flex: (v * 1000).round().clamp(1, 999),
                    child: Container(height: 5, color: SemanticColors.receita),
                  ),
                  Expanded(
                    flex: ((1 - v) * 1000).round().clamp(1, 999),
                    child: Container(height: 5, color: SemanticColors.despesa),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  const _HeroStat(
      {required this.label, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(valor, style: textTheme.displayMedium?.copyWith(fontSize: 22)),
      ],
    );
  }
}

class _BudgetSummary extends ConsumerWidget {
  final String moeda;
  final VoidCallback onTap;

  const _BudgetSummary({required this.moeda, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(budgetStatusProvider);
    if (status.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Orçamentos',
                    style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            for (final s in status)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(CategoryStyle.icon(s.budget.category),
                        size: 15, color: CategoryStyle.color(s.budget.category)),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 78,
                      child: Text(s.budget.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    Expanded(
                      child: _AnimatedBar(
                        value: s.pct.toDouble(),
                        color: s.over ? scheme.error : scheme.primary,
                        background: scheme.surfaceContainerHighest,
                        height: 9,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: Text(
                        '${s.spent.toStringAsFixed(0)}/${s.limit.toStringAsFixed(0)} $moeda',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          color: s.over ? scheme.error : null,
                          fontWeight: s.over ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthExpenseChart extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final String moeda;
  final bool expanded;
  final VoidCallback onToggle;

  const _MonthExpenseChart({
    required this.data,
    required this.moeda,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (s, e) => s + e.value);
    final maxV = data.first.value;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
            child: Row(
              children: [
                Text('Gastos deste mês',
                    style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                Text('${total.toStringAsFixed(0)} $moeda',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                for (final e in data.take(6))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(CategoryStyle.icon(e.key),
                            size: 15, color: CategoryStyle.color(e.key)),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 78,
                          child: Text(e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                        ),
                        Expanded(
                          child: _AnimatedBar(
                            value: maxV <= 0 ? 0 : e.value / maxV,
                            color: CategoryStyle.color(e.key),
                            background: scheme.surfaceContainerHighest,
                            height: 9,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 62,
                          child: Text('${e.value.toStringAsFixed(0)} $moeda',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
