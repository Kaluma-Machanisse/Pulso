import 'package:flutter/material.dart';
import '../theme/pulso_theme.dart';

/// Grelha de check-ins de um hábito (estilo "contributions"). Tamanho de
/// célula fixo e sóbrio; o número de colunas ajusta-se para preencher a
/// largura do cartão — é só controlo visual, não altera quando o hábito
/// termina de facto (`end`). Dias fora do período real (antes do início
/// ou depois do fim) aparecem apenas como preenchimento esbatido.
class HabitHeatmap extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final Set<DateTime> checkins; // datas normalizadas (sem hora)

  const HabitHeatmap({
    super.key,
    required this.start,
    required this.end,
    required this.checkins,
  });

  static const _cellSize = 16.0;
  static const _gap = 4.0;
  static const _labelWidth = 14.0;
  static const _labelGap = 6.0;
  static const _diasLetra = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  static DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final p = PulsoPalette.of(context);
    final hoje = _dia(DateTime.now());
    final inicioReal = _dia(start);
    final fimReal = _dia(end);

    // Alinha o início da grelha ao domingo da semana do início do hábito,
    // para que cada coluna represente sempre o mesmo dia da semana.
    final inicioGrelha =
        inicioReal.subtract(Duration(days: inicioReal.weekday % 7));

    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraDisponivel =
            constraints.maxWidth - _labelWidth - _labelGap;
        final nSemanas =
            (larguraDisponivel / (_cellSize + _gap)).floor().clamp(1, 999);

        // A grelha estende-se por `nSemanas` para preencher o cartão —
        // pode ir além do fim real do hábito, só como enchimento visual.
        final semanas = <List<DateTime>>[];
        var cursorSemana = inicioGrelha;
        for (var s = 0; s < nSemanas; s++) {
          final semana = <DateTime>[
            for (var i = 0; i < 7; i++) cursorSemana.add(Duration(days: i)),
          ];
          semanas.add(semana);
          cursorSemana = cursorSemana.add(const Duration(days: 7));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _labelWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final l in _diasLetra)
                        SizedBox(
                          height: _cellSize + _gap,
                          child: Center(
                            child: Text(l,
                                style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: p.textMuted)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: _labelGap),
                for (final semana in semanas)
                  Padding(
                    padding: const EdgeInsets.only(right: _gap),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final d in semana)
                          Padding(
                            padding: const EdgeInsets.only(bottom: _gap),
                            child: d.isBefore(inicioReal)
                                ? const SizedBox(
                                    width: _cellSize, height: _cellSize)
                                : _buildCell(d, hoje, fimReal, p),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: _labelWidth + _labelGap),
              child: Text('Preenchido = feito  ·  contorno = falhado',
                  style: TextStyle(fontSize: 10, color: p.textMuted)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCell(DateTime d, DateTime hoje, DateTime fimReal, PulsoPalette p) {
    final feito = checkins.contains(d);
    final foraDoPeriodo = d.isAfter(fimReal);
    final futuro = d.isAfter(hoje);
    final ehHoje = d == hoje;

    BoxDecoration decoration;
    if (feito) {
      decoration = BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(4),
      );
    } else if (foraDoPeriodo || futuro) {
      // Fora do período real do hábito, ou dia futuro dentro dele: só
      // enchimento visual, bem esbatido.
      decoration = BoxDecoration(
        color: p.borderSubtle,
        borderRadius: BorderRadius.circular(4),
      );
    } else {
      // Falhado: só contorno — bem distinto do preenchido de "feito".
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: p.border, width: 1.3),
      );
    }

    if (ehHoje && !feito) {
      decoration = decoration.copyWith(
        border: Border.all(color: p.primary, width: 1.7),
      );
    }

    return Container(
      width: _cellSize,
      height: _cellSize,
      decoration: decoration,
    );
  }
}
