import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_providers.dart';
import '../services/sync_service.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyStatsAsync = ref.watch(monthlyStatsProvider);
    final goalsProgressAsync = ref.watch(goalsProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Restaurar dados do Supabase',
            onPressed: () async {
              final ok = await SyncService.pullAll(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Dados restaurados'
                        : 'Falha ao restaurar. Verifica a ligação.'),
                    backgroundColor: ok ? null : Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receitas vs Despesas (mensal)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: monthlyStatsAsync.when(
                data: (monthly) {
                  if (monthly.isEmpty) {
                    return const Center(child: Text('Sem dados'));
                  }
                  final months = monthly.keys.toList()..sort();
                  // As barras (receitas/despesas) são lado a lado, não
                  // empilhadas: o topo do eixo é o maior valor individual,
                  // com 10% de folga.
                  final maiorValor = monthly.values.fold<double>(
                    0.0,
                    (prev, m) => [
                      prev,
                      m['receitas'] ?? 0,
                      m['despesas'] ?? 0,
                    ].reduce((a, b) => a > b ? a : b),
                  );
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maiorValor == 0 ? 1 : maiorValor * 1.1,
                      barGroups: List.generate(months.length, (i) {
                        final data = monthly[months[i]]!;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: data['receitas']!,
                              color: Colors.green,
                              width: 12,
                            ),
                            BarChartRodData(
                              toY: data['despesas']!,
                              color: Colors.red,
                              width: 12,
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < months.length) {
                                return Text(months[idx],
                                    style: const TextStyle(fontSize: 9));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
              ),
            ),
            const SizedBox(height: 32),
            Text('Progresso dos Objectivos',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            goalsProgressAsync.when(
              data: (goals) {
                if (goals.isEmpty) {
                  return const Text('Nenhum objectivo.');
                }
                return Column(
                  children: goals.map((goal) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: goal.progressPercentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                goal.progressPercentage >= 100
                                    ? Colors.green
                                    : Colors.blue),
                          ),
                          Text('${goal.progressPercentage}%',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ],
        ),
      ),
    );
  }
}