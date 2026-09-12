import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database.dart';
import '../providers/stats_providers.dart';
import '../providers/transaction_providers.dart';
import '../providers/settings_providers.dart';
import '../services/sync_service.dart';
import '../theme/semantic_colors.dart';
import 'reports_screen.dart';

enum _TipoGrafico { barras, circular }

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  _TipoGrafico _tipo = _TipoGrafico.barras;
  _TipoGrafico _tipoObjectivos = _TipoGrafico.barras;

  @override
  Widget build(BuildContext context) {
    final monthlyStatsAsync = ref.watch(monthlyStatsProvider);
    final weeklySpendAsync = ref.watch(weeklySpendProvider);
    final goalsProgressAsync = ref.watch(goalsProgressProvider);
    final balanceAsync = ref.watch(balanceProvider);
    final moeda = ref.watch(settingsProvider).currency;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'Relatórios mensais',
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsScreen())),
          ),
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
            // ---- Resumo ----
            monthlyStatsAsync.when(
              data: (monthly) {
                final chave = monthly.keys.isEmpty
                    ? null
                    : (monthly.keys.toList()..sort()).last;
                final mesActual = chave != null ? monthly[chave]! : null;
                return Row(
                  children: [
                    _StatCard(
                      label: 'Saldo',
                      value: balanceAsync.when(
                        data: (b) => '${b.toStringAsFixed(0)} $moeda',
                        loading: () => '—',
                        error: (_, __) => '—',
                      ),
                      color: scheme.primary,
                    ),
                    _StatCard(
                      label: 'Receitas (mês)',
                      value:
                          '${(mesActual?['receitas'] ?? 0).toStringAsFixed(0)} $moeda',
                      color: SemanticColors.receita,
                    ),
                    _StatCard(
                      label: 'Despesas (mês)',
                      value:
                          '${(mesActual?['despesas'] ?? 0).toStringAsFixed(0)} $moeda',
                      color: SemanticColors.despesa,
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                  height: 74, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Erro: $e'),
            ),
            const SizedBox(height: 24),

            // ---- Gráfico mensal ----
            Row(
              children: [
                Expanded(
                  child: Text('Receitas vs despesas',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                SegmentedButton<_TipoGrafico>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: _TipoGrafico.barras,
                      icon: Icon(Icons.bar_chart, size: 18),
                    ),
                    ButtonSegment(
                      value: _TipoGrafico.circular,
                      icon: Icon(Icons.pie_chart, size: 18),
                    ),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (s) => setState(() => _tipo = s.first),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _Legenda(cor: SemanticColors.receita, texto: 'Receitas'),
                const SizedBox(width: 16),
                _Legenda(cor: SemanticColors.despesa, texto: 'Despesas'),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                child: SizedBox(
                  height: 230,
                  child: monthlyStatsAsync.when(
                    data: (monthly) {
                      if (monthly.isEmpty) {
                        return const Center(
                            child: Text('Sem transações registadas.'));
                      }
                      if (_tipo == _TipoGrafico.circular) {
                        return _GraficoCircular(monthly: monthly, moeda: moeda);
                      }
                      final months = monthly.keys.toList()..sort();
                      // As barras são lado a lado, não empilhadas: o topo do
                      // eixo é o maior valor individual, com 10% de folga.
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
                          gridData: FlGridData(
                            drawVerticalLine: false,
                            horizontalInterval: maiorValor == 0
                                ? 1
                                : (maiorValor * 1.1) / 4,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: scheme.outlineVariant,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(months.length, (i) {
                            final data = monthly[months[i]]!;
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: data['receitas']!,
                                  color: SemanticColors.receita,
                                  width: 12,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                BarChartRodData(
                                  toY: data['despesas']!,
                                  color: SemanticColors.despesa,
                                  width: 12,
                                  borderRadius: BorderRadius.circular(3),
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
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: scheme.onSurfaceVariant),
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
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: scheme.onSurfaceVariant));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
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
              ),
            ),
            const SizedBox(height: 28),

            // ---- Gastos por semana (pico do mês) ----
            Text('Gastos por semana (este mês)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
                child: weeklySpendAsync.when(
                  data: (semanas) {
                    if (semanas.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                            child: Text('Sem despesas registadas este mês.')),
                      );
                    }
                    final pico = semanas.reduce(
                        (a, b) => a.total >= b.total ? a : b);
                    final maiorValor = pico.total;
                    final semanaActual = ((DateTime.now().day - 1) ~/ 7) + 1;
                    final gastoSemanaActual = semanas
                        .firstWhere(
                          (s) => s.semana == semanaActual,
                          orElse: () => WeekSpend(semanaActual, 0),
                        )
                        .total;
                    final gastoMesTotal =
                        semanas.fold<double>(0, (s, e) => s + e.total);
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MiniResumo(
                                label: 'Esta semana',
                                valor:
                                    '${gastoSemanaActual.toStringAsFixed(0)} $moeda',
                              ),
                            ),
                            Expanded(
                              child: _MiniResumo(
                                label: 'Este mês (até agora)',
                                valor:
                                    '${gastoMesTotal.toStringAsFixed(0)} $moeda',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maiorValor == 0 ? 1 : maiorValor * 1.15,
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                horizontalInterval:
                                    maiorValor == 0 ? 1 : (maiorValor * 1.15) / 4,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: scheme.outlineVariant,
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: semanas
                                  .map((s) => BarChartGroupData(
                                        x: s.semana,
                                        barRods: [
                                          BarChartRodData(
                                            toY: s.total,
                                            width: 22,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: s.semana == pico.semana
                                                ? SemanticColors.despesa
                                                : scheme.primary,
                                          ),
                                        ],
                                      ))
                                  .toList(),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toStringAsFixed(0),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: scheme.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) => Text(
                                      'Sem ${value.toInt()}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: scheme.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.trending_up,
                                size: 16, color: SemanticColors.despesa),
                            const SizedBox(width: 6),
                            Text(
                              'Pico: semana ${pico.semana} · '
                              '${pico.total.toStringAsFixed(0)} $moeda',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ---- Progresso dos objectivos ----
            Row(
              children: [
                Expanded(
                  child: Text('Objectivos',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                SegmentedButton<_TipoGrafico>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: _TipoGrafico.barras,
                      icon: Icon(Icons.bar_chart, size: 18),
                    ),
                    ButtonSegment(
                      value: _TipoGrafico.circular,
                      icon: Icon(Icons.pie_chart, size: 18),
                    ),
                  ],
                  selected: {_tipoObjectivos},
                  onSelectionChanged: (s) =>
                      setState(() => _tipoObjectivos = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            goalsProgressAsync.when(
              data: (goals) {
                final activos = goals.where((g) => g.archivedAt == null).toList()
                  ..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
                if (activos.isEmpty) {
                  return Text('Nenhum objectivo activo.',
                      style: TextStyle(color: scheme.onSurfaceVariant));
                }
                return Column(children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                    child: SizedBox(
                      height: 220,
                      child: _tipoObjectivos == _TipoGrafico.circular
                          ? _GoalsCircular(goals: activos)
                          : _GoalsBars(goals: activos, scheme: scheme),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final goal in activos) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(goal.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Text('${goal.progressPercentage}%',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: goal.progressPercentage >= 100
                                          ? SemanticColors.receita
                                          : scheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: goal.progressPercentage / 100,
                              minHeight: 7,
                              backgroundColor: scheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  goal.progressPercentage >= 100
                                      ? SemanticColors.receita
                                      : scheme.primary),
                            ),
                          ),
                          if (goal != activos.last) const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
                ]);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MiniResumo extends StatelessWidget {
  final String label;
  final String valor;
  const _MiniResumo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(valor,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;
  const _Legenda({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _GraficoCircular extends StatelessWidget {
  final Map<String, Map<String, double>> monthly;
  final String moeda;
  const _GraficoCircular({required this.monthly, required this.moeda});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final receitas =
        monthly.values.fold<double>(0, (s, m) => s + (m['receitas'] ?? 0));
    final despesas =
        monthly.values.fold<double>(0, (s, m) => s + (m['despesas'] ?? 0));
    final total = receitas + despesas;

    if (total <= 0) {
      return const Center(child: Text('Sem valores para mostrar.'));
    }

    final pctReceitas = (receitas / total * 100);
    final pctDespesas = (despesas / total * 100);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 56,
            sections: [
              PieChartSectionData(
                value: receitas,
                color: SemanticColors.receita,
                radius: 44,
                showTitle: pctReceitas >= 8,
                title: '${pctReceitas.toStringAsFixed(0)}%',
                titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              PieChartSectionData(
                value: despesas,
                color: SemanticColors.despesa,
                radius: 44,
                showTitle: pctDespesas >= 8,
                title: '${pctDespesas.toStringAsFixed(0)}%',
                titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${total.toStringAsFixed(0)} $moeda',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            Text('movimentado (total)',
                style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

// Cores do ponto de prazo (mesmas do ecrã de Objectivos): Curto = mais
// urgente/laranja, Médio = amarelo, Longo = verde/tranquilo.
const _corCurto = Color(0xFFF57C00);
const _corMedio = Color(0xFFFBC02D);
const _corLongo = Color(0xFF388E3C);

Color _corPorPrazo(String term) {
  switch (term) {
    case 'Curto prazo':
      return _corCurto;
    case 'Médio prazo':
      return _corMedio;
    default:
      return _corLongo;
  }
}

class _GoalsBars extends StatelessWidget {
  final List<Goal> goals;
  final ColorScheme scheme;
  const _GoalsBars({required this.goals, required this.scheme});

  static const _ordem = ['Curto prazo', 'Médio prazo', 'Longo prazo'];
  static const _rotulo = {
    'Curto prazo': 'Curto',
    'Médio prazo': 'Médio',
    'Longo prazo': 'Longo',
  };

  @override
  Widget build(BuildContext context) {
    // Agrupado por prazo: uma barra por grupo, com o progresso médio.
    final grupos = <String, List<Goal>>{
      for (final t in _ordem) t: goals.where((g) => g.term == t).toList(),
    };

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 110,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outlineVariant, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(_ordem.length, (i) {
          final term = _ordem[i];
          final lista = grupos[term]!;
          final media = lista.isEmpty
              ? 0.0
              : lista.map((g) => g.progressPercentage).reduce((a, b) => a + b) /
                  lista.length;
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: media,
              width: 34,
              borderRadius: BorderRadius.circular(4),
              color: media >= 100 ? SemanticColors.receita : _corPorPrazo(term),
            ),
          ]);
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 25,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}%',
                  style:
                      TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= _ordem.length) return const Text('');
                final term = _ordem[idx];
                final n = grupos[term]!.length;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    children: [
                      Text(_rotulo[term]!,
                          style: TextStyle(
                              fontSize: 10, color: scheme.onSurfaceVariant)),
                      Text('($n)',
                          style: TextStyle(
                              fontSize: 9, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class _GoalsCircular extends StatelessWidget {
  final List<Goal> goals;
  const _GoalsCircular({required this.goals});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final porPrazo = <String, int>{};
    for (final g in goals) {
      porPrazo[g.term] = (porPrazo[g.term] ?? 0) + 1;
    }
    const ordem = ['Curto prazo', 'Médio prazo', 'Longo prazo'];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 46,
              sections: [
                for (final term in ordem)
                  if (porPrazo[term] != null)
                    PieChartSectionData(
                      value: porPrazo[term]!.toDouble(),
                      color: _corPorPrazo(term),
                      radius: 40,
                      title: '${porPrazo[term]}',
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final term in ordem)
              if (porPrazo[term] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: _corPorPrazo(term), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text('$term (${porPrazo[term]})',
                          style: TextStyle(
                              fontSize: 11, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
          ],
        ),
      ],
    );
  }
}
