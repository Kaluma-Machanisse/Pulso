import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_providers.dart';
import '../providers/filter_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/budget_providers.dart';
import '../services/sync_service.dart';
import '../widgets/confirm_dialog.dart';
import 'add_transaction_screen.dart';
import 'budgets_screen.dart';
import 'reports_screen.dart';

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
      backgroundColor: ok ? null : Colors.red,
    ));
  }

  void _abrirOrcamentos() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetsScreen()));

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceProvider);
    final filter = ref.watch(financeFilterProvider);
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final moeda = ref.watch(settingsProvider).currency;
    final anoActual = DateTime.now().year;
    final gastosMes = ref.watch(currentMonthExpensesByCategoryProvider);
    final overCount = ref.watch(overBudgetCountProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteira'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: _syncing
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            onPressed: _syncing ? null : _sincronizar,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'orcamentos') {
                _abrirOrcamentos();
              } else if (v == 'relatorios') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ReportsScreen()));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'orcamentos', child: Text('Orçamentos')),
              PopupMenuItem(
                  value: 'relatorios', child: Text('Relatórios mensais')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: scheme.primaryContainer,
            child: balanceAsync.when(
              data: (b) => Text('Saldo: ${b.toStringAsFixed(2)} $moeda',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Erro'),
            ),
          ),

          if (overCount > 0)
            Material(
              color: scheme.errorContainer,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.warning_amber, color: scheme.onErrorContainer),
                title: Text(
                  overCount == 1
                      ? '1 orçamento ultrapassado este mês'
                      : '$overCount orçamentos ultrapassados este mês',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
                trailing: Icon(Icons.chevron_right, color: scheme.onErrorContainer),
                onTap: _abrirOrcamentos,
              ),
            ),

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
                    icon: const Icon(Icons.clear),
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
                  return const Center(child: Text('Sem transações.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: txList.length,
                  itemBuilder: (_, i) {
                    final tx = txList[i];
                    final isReceita = tx.type == 'receita';
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => confirmarEliminacao(
                          context, tx.description ?? tx.category),
                      onDismissed: (_) =>
                          ref.read(deleteTransactionProvider(tx.id)),
                      child: ListTile(
                        leading: Icon(
                          isReceita ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isReceita ? Colors.green : Colors.red,
                        ),
                        title: Text(tx.description ?? tx.category),
                        subtitle: Text(
                          '${tx.category} · ${tx.date.day}/${tx.date.month}/${tx.date.year}'
                          '${tx.source != 'manual' ? '  ·  ${tx.source}' : ''}',
                        ),
                        trailing: Text(
                          '${isReceita ? '+' : '-'}${tx.amount.toStringAsFixed(2)} $moeda',
                          style: TextStyle(
                            color: isReceita ? Colors.green : Colors.red,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
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
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
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
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: maxV <= 0 ? 0 : e.value / maxV,
                              minHeight: 10,
                              backgroundColor: scheme.surfaceContainerHighest,
                              color: scheme.primary,
                            ),
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
