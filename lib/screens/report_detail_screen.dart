import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../services/report_service.dart';
import '../services/report_pdf.dart';

const _meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

String _titulo(String monthKey) {
  final p = monthKey.split('-');
  return '${_meses[int.parse(p[1]) - 1]} ${p[0]}';
}

class ReportDetailScreen extends ConsumerWidget {
  final MonthlyReport? report;
  final FinancialReport? financial;

  const ReportDetailScreen({super.key, this.report, this.financial})
      : assert(report != null || financial != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moeda = ref.watch(settingsProvider).currency;
    final fin = financial;
    final obj = report;

    return Scaffold(
      appBar: AppBar(
        title: Text(fin != null
            ? 'Finanças · ${_titulo(fin.month)}'
            : 'Objectivos · ${_titulo(obj!.month)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: () => fin != null
                ? ReportPdf.openFinancial(fin, moeda)
                : ReportPdf.open(obj!),
          ),
        ],
      ),
      body: fin != null
          ? _Financeiro(fin: fin, moeda: moeda)
          : _Objectivos(r: obj!),
    );
  }
}

class _Objectivos extends StatelessWidget {
  final MonthlyReport r;
  const _Objectivos({required this.r});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          _stat(context, '${r.completedCount}', 'Concluídos'),
          _stat(context, '${r.activeCount}', 'Em curso'),
          _stat(context, '${r.avgActiveProgress.toStringAsFixed(0)}%',
              'Progresso médio'),
        ]),
        const SizedBox(height: 24),
        Text('Concluídos no mês',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (r.completed.isEmpty)
          const Text('Nenhum.')
        else
          ...r.completed.map((g) => ListTile(
                dense: true,
                leading:
                    const Icon(Icons.check_circle, color: Colors.green),
                title: Text(g.title),
                subtitle:
                    Text('${g.category} · ${g.importance} · ${g.term}'),
              )),
        const SizedBox(height: 24),
        Text('Em curso', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (r.active.isEmpty)
          const Text('Nenhum.')
        else
          ...r.active.map((g) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${g.title} · ${g.category}'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (g.progress.clamp(0, 100)) / 100,
                      minHeight: 8,
                    ),
                    Text('${g.progress}%',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )),
      ],
    );
  }
}

class _Financeiro extends StatelessWidget {
  final FinancialReport fin;
  final String moeda;
  const _Financeiro({required this.fin, required this.moeda});

  @override
  Widget build(BuildContext context) {
    final maxV =
        fin.despesasPorCategoria.isEmpty ? 0.0 : fin.despesasPorCategoria.first.value;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          _stat(context, fin.receitas.toStringAsFixed(0), 'Receitas'),
          _stat(context, fin.despesas.toStringAsFixed(0), 'Despesas'),
          _stat(context, fin.saldo.toStringAsFixed(0), 'Saldo'),
        ]),
        const SizedBox(height: 8),
        Text('$moeda · ${fin.nTransacoes} transações no mês',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        Text('Despesas por categoria',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (fin.despesasPorCategoria.isEmpty)
          const Text('Sem despesas.')
        else
          ...fin.despesasPorCategoria.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  SizedBox(
                      width: 96,
                      child: Text(e.key,
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: maxV <= 0 ? 0 : e.value / maxV,
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 70,
                      child: Text('${e.value.toStringAsFixed(0)} $moeda',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 11))),
                ]),
              )),
      ],
    );
  }
}

Widget _stat(BuildContext context, String v, String label) => Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
