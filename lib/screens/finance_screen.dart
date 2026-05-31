import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_providers.dart';
import '../services/sync_service.dart';
import 'add_transaction_screen.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteira'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await SyncService.pushAll(ref);   // <--- ALTERADO: envia todas as tabelas
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Erro'),
            ),
          ),
          // Lista de transações
          Expanded(
            child: transactionsAsync.when(
              data: (txList) => ListView.builder(
                itemCount: txList.length,
                itemBuilder: (_, i) {
                  final tx = txList[i];
                  final isReceita = tx.type == 'receita';
                  return ListTile(
                    leading: Icon(
                      isReceita ? Icons.arrow_downward : Icons.arrow_upward,
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
              loading: () => const Center(child: CircularProgressIndicator()),
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