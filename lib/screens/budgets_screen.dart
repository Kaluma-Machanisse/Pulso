import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/budget_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/confirm_dialog.dart';

const _categoriasDespesa = [
  'Geral',
  'Alimentação',
  'Transporte',
  'Saúde',
  'Lazer',
  'Negócio',
  'SMS',
  'Outro',
];

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  Future<void> _editar(BuildContext context, WidgetRef ref, Budget? b) async {
    final usadas = (ref.read(budgetsProvider).valueOrNull ?? [])
        .map((e) => e.category)
        .toSet();
    var categoria = b?.category ?? _categoriasDespesa.firstWhere(
        (c) => !usadas.contains(c),
        orElse: () => 'Geral');
    final ctrl = TextEditingController(
        text: b != null ? b.monthlyLimit.toStringAsFixed(0) : '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSt) => AlertDialog(
          title: Text(b == null ? 'Novo orçamento' : 'Editar orçamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categoriasDespesa
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: b == null
                    ? (v) => setSt(() => categoria = v!)
                    : null,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Limite mensal'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final limite = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
    if (limite <= 0) return;
    await ref.read(upsertBudgetProvider(
            (id: b?.id, category: categoria, limit: limite))
        .future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(budgetStatusProvider);
    final moeda = ref.watch(settingsProvider).currency;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Orçamentos mensais')),
      body: status.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Sem orçamentos.\nDefine um limite mensal por categoria e '
                  'acompanha os gastos.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final s in status)
                  Card(
                    child: ListTile(
                      title: Text(s.budget.category),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: s.pct.clamp(0, 1),
                                minHeight: 8,
                                color: s.over
                                    ? scheme.error
                                    : scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${s.spent.toStringAsFixed(0)} / ${s.limit.toStringAsFixed(0)} $moeda'
                              '${s.over ? '  ·  ultrapassado' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: s.over ? scheme.error : null,
                                fontWeight:
                                    s.over ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'editar') {
                            await _editar(context, ref, s.budget);
                          } else if (v == 'eliminar') {
                            if (await confirmarEliminacao(
                                context, 'orçamento de ${s.budget.category}')) {
                              await ref
                                  .read(deleteBudgetProvider(s.budget.id).future);
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'editar', child: Text('Editar')),
                          PopupMenuItem(
                              value: 'eliminar', child: Text('Eliminar')),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editar(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
