import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../providers/report_providers.dart';
import '../providers/settings_providers.dart';
import '../services/report_service.dart';
import '../services/report_pdf.dart';
import '../widgets/confirm_dialog.dart';
import 'report_detail_screen.dart';

const _meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

String tituloMes(String monthKey) {
  final p = monthKey.split('-');
  return '${_meses[int.parse(p[1]) - 1]} ${p[0]}';
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    final moeda = ref.watch(settingsProvider).currency;

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
                  'com o resumo do mês anterior (objectivos e finanças).',
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
              final fin = row.type == ReportService.kFinanceiro;

              final String subtitle;
              final VoidCallback abrirDetalhe;
              final VoidCallback exportar;

              if (fin) {
                final r = ReportService.parseFinancial(row);
                subtitle =
                    'saldo ${r.saldo.toStringAsFixed(0)} $moeda · ${r.nTransacoes} transações';
                abrirDetalhe = () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(financial: r)));
                exportar = () => ReportPdf.openFinancial(r, moeda);
              } else {
                final r = ReportService.parse(row);
                subtitle =
                    '${r.completedCount} concluídos · ${r.activeCount} em curso';
                abrirDetalhe = () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(report: r)));
                exportar = () => ReportPdf.open(r);
              }

              return ListTile(
                leading: Icon(fin ? Icons.account_balance_wallet : Icons.flag),
                title: Text('${fin ? 'Finanças' : 'Objectivos'} · '
                    '${tituloMes(row.month)}'),
                subtitle: Text(subtitle),
                trailing: IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Exportar PDF',
                  onPressed: exportar,
                ),
                onTap: abrirDetalhe,
                onLongPress: () async {
                  if (await confirmarEliminacao(context,
                      'relatório de ${tituloMes(row.month)}')) {
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
