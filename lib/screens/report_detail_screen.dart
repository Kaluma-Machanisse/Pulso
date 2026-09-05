import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../services/report_pdf.dart';

class ReportDetailScreen extends StatelessWidget {
  final MonthlyReport report;
  const ReportDetailScreen({super.key, required this.report});

  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  String get _titulo {
    final p = report.month.split('-');
    return '${_meses[int.parse(p[1]) - 1]} ${p[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório · $_titulo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: () => ReportPdf.open(report),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _card(context, '${report.completedCount}', 'Concluídos'),
              _card(context, '${report.activeCount}', 'Em curso'),
              _card(context, '${report.avgActiveProgress.toStringAsFixed(0)}%',
                  'Progresso médio'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Concluídos no mês',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (report.completed.isEmpty)
            const Text('Nenhum.')
          else
            ...report.completed.map((g) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(g.title),
                  subtitle: Text('${g.category} · ${g.importance} · ${g.term}'),
                )),
          const SizedBox(height: 24),
          Text('Em curso', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (report.active.isEmpty)
            const Text('Nenhum.')
          else
            ...report.active.map((g) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${g.title} · ${g.category}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (g.progress.clamp(0, 100)) / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      Text('${g.progress}%',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String valor, String rotulo) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valor,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(rotulo, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
