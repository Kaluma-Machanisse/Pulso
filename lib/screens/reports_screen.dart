import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../providers/report_providers.dart';
import '../services/report_service.dart';
import '../services/report_pdf.dart';
import '../widgets/confirm_dialog.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  String _titulo(String monthKey) {
    final p = monthKey.split('-');
    return '${_meses[int.parse(p[1]) - 1]} ${p[0]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios mensais')),
      body: reportsAsync.when(
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Ainda não há relatórios.\nÉ gerado um no início de cada mês, '
                  'com o resumo do mês anterior.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final row = rows[i];
              final report = ReportService.parse(row);
              return ListTile(
                leading: const Icon(Icons.description),
                title: Text(_titulo(row.month)),
                subtitle: Text(
                    '${report.completedCount} concluídos · ${report.activeCount} em curso'),
                trailing: IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Exportar PDF',
                  onPressed: () => ReportPdf.open(report),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(report: report),
                  ),
                ),
                onLongPress: () async {
                  if (await confirmarEliminacao(
                      context, 'relatório de ${_titulo(row.month)}')) {
                    await ReportService.deleteReports(
                        ref.read(databaseProvider), [row.id]);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
