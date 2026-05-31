import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_providers.dart';
import '../providers/filter_providers.dart';
import '../services/sync_service.dart';
import 'add_transaction_screen.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _showFilters = false;

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

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceProvider);
    final filter = ref.watch(financeFilterProvider);
    final filteredAsync = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteira'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await SyncService.pushAll(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronização completa')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Saldo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.blue.shade50,
            child: balanceAsync.when(
              data: (balance) => Text(
                'Saldo: ${balance.toStringAsFixed(2)} MZN',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Erro'),
            ),
          ),

          // Painel de filtros (expansível)
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Tipo
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: filter.type,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: _types
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(t == 'todas' ? 'Todas' : t)))
                          .toList(),
                      onChanged: (val) => ref
                          .read(financeFilterProvider.notifier)
                          .updateType(val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Categoria
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: filter.category,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => ref
                          .read(financeFilterProvider.notifier)
                          .updateCategory(val!),
                    ),
                  ),
                ],
              ),
            ),

          // Lista filtrada
          Expanded(
            child: filteredAsync.when(
              data: (txList) => ListView.builder(
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
                    subtitle: Text(tx.category),
                    trailing: Text(
                      '${isReceita ? '+' : '-'}${tx.amount.toStringAsFixed(2)} MZN',
                      style: TextStyle(
                        color: isReceita ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onLongPress: () {
                      ref.read(deleteTransactionProvider(tx.id));
                    },
                  );
                },
              ),
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