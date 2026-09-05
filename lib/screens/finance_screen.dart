import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_providers.dart';
import '../providers/filter_providers.dart';
import '../providers/settings_providers.dart';
import '../services/sync_service.dart';
import '../widgets/confirm_dialog.dart';
import 'add_transaction_screen.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _showFilters = false;
  bool _syncing = false;

  final List<String> _types = ['todas', 'receita', 'despesa'];
  final List<String> _categories = [
    'Todas',
    'Geral',
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Salário',
    'Negócio',
    'Outro',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Sincronização completa'
            : 'Falha na sincronização. Verifica a ligação.'),
        backgroundColor: ok ? null : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceProvider);
    final filter = ref.watch(financeFilterProvider);
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final moeda = ref.watch(settingsProvider).currency;
    final anoActual = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteira'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _syncing ? null : _sincronizar,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: balanceAsync.when(
              data: (balance) => Text(
                'Saldo: ${balance.toStringAsFixed(2)} $moeda',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Erro'),
            ),
          ),
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: filter.type,
                          decoration:
                              const InputDecoration(labelText: 'Tipo'),
                          items: _types
                              .map((t) => DropdownMenuItem(
                                  value: t,
                                  child:
                                      Text(t == 'todas' ? 'Todas' : t)))
                              .toList(),
                          onChanged: (val) => ref
                              .read(financeFilterProvider.notifier)
                              .updateType(val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: filter.category,
                          decoration:
                              const InputDecoration(labelText: 'Categoria'),
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => ref
                              .read(financeFilterProvider.notifier)
                              .updateCategory(val!),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: filter.month,
                          decoration:
                              const InputDecoration(labelText: 'Mês'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Todos')),
                            for (var m = 1; m <= 12; m++)
                              DropdownMenuItem(
                                  value: m, child: Text(_meses[m - 1])),
                          ],
                          onChanged: (val) => ref
                              .read(financeFilterProvider.notifier)
                              .updateMonth(val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: filter.year,
                          decoration:
                              const InputDecoration(labelText: 'Ano'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Todos')),
                            for (var y = anoActual - 4; y <= anoActual; y++)
                              DropdownMenuItem(
                                  value: y, child: Text('$y')),
                          ],
                          onChanged: (val) => ref
                              .read(financeFilterProvider.notifier)
                              .updateYear(val),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Limpar filtros',
                        icon: const Icon(Icons.clear),
                        onPressed: () => ref
                            .read(financeFilterProvider.notifier)
                            .reset(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredAsync.when(
              data: (txList) {
                if (txList.isEmpty) {
                  return const Center(child: Text('Sem transações.'));
                }
                return ListView.builder(
                  itemCount: txList.length,
                  itemBuilder: (_, i) {
                    final tx = txList[i];
                    final isReceita = tx.type == 'receita';
                    return ListTile(
                      leading: Icon(
                        isReceita
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: isReceita ? Colors.green : Colors.red,
                      ),
                      title: Text(tx.description ?? tx.category),
                      subtitle: Text(
                          '${tx.category} · ${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                      trailing: Text(
                        '${isReceita ? '+' : '-'}${tx.amount.toStringAsFixed(2)} $moeda',
                        style: TextStyle(
                          color: isReceita ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onLongPress: () async {
                        if (await confirmarEliminacao(
                            context, tx.description ?? tx.category)) {
                          await ref
                              .read(deleteTransactionProvider(tx.id).future);
                        }
                      },
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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
