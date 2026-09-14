import 'package:flutter/material.dart';
import '../theme/pulso_theme.dart';

/// Grelha de check-ins de um hábito (estilo "contributions"), um quadrado
/// por dia do período — feito = preenchido a cor de marca, falhado =
/// apenas contorno (bem distinto do preenchido), futuro = quase invisível.
/// Alinhada por dia da semana, com as iniciais dos dias à esquerda.
class HabitHeatmap extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final Set<DateTime> checkins; // datas normalizadas (sem hora)

  /// Máximo de semanas mostradas (mostra sempre as mais recentes). Mantém
  /// a grelha compacta para hábitos com períodos longos.
  final int maxWeeks;

  const HabitHeatmap({
    super.key,
    required this.start,
    required this.end,
    required this.checkins,
    this.maxWeeks = 6,
  });

  static const _cellSize = 18.0;
  static const _gap = 5.0;
  static const _diasLetra = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final p = PulsoPalette.of(context);
    final hoje = _dia(DateTime.now());
    final fim = _dia(end);

    // Alinha o início da grelha ao domingo da semana do início do hábito,
    // para que cada coluna represente sempre o mesmo dia da semana.
    final inicioReal = _dia(start);
    final inicioGrelha =
        inicioReal.subtract(Duration(days: inicioReal.weekday % 7));

    final semanas = <List<DateTime?>>[];
    var cursorSemana = inicioGrelha;
    while (!cursorSemana.isAfter(fim)) {
      final semana = <DateTime?>[];
      for (var i = 0; i < 7; i++) {
        final d = cursorSemana.add(Duration(days: i));
        semana.add((d.isBefore(inicioReal) || d.isAfter(fim)) ? null : d);
      }
      semanas.add(semana);
      cursorSemana = cursorSemana.add(const Duration(days: 7));
    }
    final visiveis = semanas.length > maxWeeks
        ? semanas.sublist(semanas.length - maxWeeks)
        : semanas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final l in _diasLetra)
                  SizedBox(
                    width: 14,
                    height: _cellSize + _gap,
                    child: Center(
                      child: Text(l,
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: p.textMuted)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            for (final semana in visiveis)
              Padding(
                padding: const EdgeInsets.only(right: _gap),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final d in semana)
                      Padding(
                        padding: const EdgeInsets.only(bottom: _gap),
                        child: d == null
                            ? const SizedBox(
                                width: _cellSize, height: _cellSize)
                            : _buildCell(d, hoje, p),
                      ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text('Preenchido = feito  ·  contorno = falhado',
              style: TextStyle(fontSize: 10, color: p.textMuted)),
        ),
      ],
    );
  }

  Widget _buildCell(DateTime d, DateTime hoje, PulsoPalette p) {
    final feito = checkins.contains(d);
    final futuro = d.isAfter(hoje);
    final ehHoje = d == hoje;

    BoxDecoration decoration;
    if (feito) {
      decoration = BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(5),
      );
    } else if (futuro) {
      decoration = BoxDecoration(
        color: p.borderSubtle,
        borderRadius: BorderRadius.circular(5),
      );
    } else {
      // Falhado: só contorno — bem distinto do preenchido de "feito".
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: p.border, width: 1.4),
      );
    }

    if (ehHoje && !feito) {
      decoration = decoration.copyWith(
        border: Border.all(color: p.primary, width: 1.8),
      );
    }

    return Container(
      width: _cellSize,
      height: _cellSize,
      decoration: decoration,
    );
  }

  static DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);
}
