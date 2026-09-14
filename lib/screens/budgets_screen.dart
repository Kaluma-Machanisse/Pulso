import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/budget_providers.dart';
import '../providers/settings_providers.dart';
import '../theme/category_style.dart';
import '../theme/pulso_theme.dart';
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

  Future<void> _editarLimiteGeral(BuildContext context, WidgetRef ref) async {
    final actual = ref.read(settingsProvider).monthlyLimit;
    final ctrl = TextEditingController(
        text: actual > 0 ? actual.toStringAsFixed(0) : '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limite geral mensal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quanto queres gastar no total por mês, em todas as '
              'categorias. Deixa vazio ou 0 para desligar.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    );
    if (ok != true) return;
    final limite = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
    await ref.read(settingsProvider.notifier).setMonthlyLimit(limite);
  }

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
    final geral = ref.watch(overallBudgetStatusProvider);
    final moeda = ref.watch(settingsProvider).currency;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Orçamentos mensais')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: scheme.primaryContainer.withValues(alpha: 0.35),
            child: ListTile(
              title: const Text('Limite geral mensal'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: geral.active
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: geral.pct.clamp(0, 1),
                              minHeight: 8,
                              color: geral.over ? scheme.error : scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${geral.spent.toStringAsFixed(0)} / '
                            '${geral.limit.toStringAsFixed(0)} $moeda'
                            '${geral.over ? '  ·  ultrapassado' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: geral.over ? scheme.error : null,
                                  fontWeight:
                                      geral.over ? FontWeight.bold : null,
                                ),
                          ),
                        ],
                      )
                    : Text(
                        'Sem limite definido. Toca em editar para definires '
                        'quanto queres gastar no total por mês.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Editar limite geral',
                onPressed: () => _editarLimiteGeral(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Por categoria', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          if (status.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Sem orçamentos por categoria.\nDefine um limite mensal por '
                'categoria e acompanha os gastos.',
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final s in status) ...[
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        CategoryStyle.color(s.budget.category).withValues(alpha: 0.14),
                    foregroundColor: CategoryStyle.color(s.budget.category),
                    child: Icon(CategoryStyle.icon(s.budget.category), size: 20),
                  ),
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
                            color: s.over ? scheme.error : scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${s.spent.toStringAsFixed(0)} / ${s.limit.toStringAsFixed(0)} $moeda',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: s.over ? scheme.error : null,
                                fontWeight: s.over ? FontWeight.bold : null,
                              ),
                        ),
                        Text(
                          s.over
                              ? 'Ultrapassado em ${(s.spent - s.limit).toStringAsFixed(0)} $moeda'
                              : 'Restam ${(s.limit - s.spent).toStringAsFixed(0)} $moeda',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: s.over ? scheme.error : scheme.onSurfaceVariant,
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
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: PulsoSpace.sm),
            ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editar(context, ref, null),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
