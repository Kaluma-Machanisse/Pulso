import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'report_service.dart';

/// Gera e abre o PDF de um relatório mensal (módulo de Objectivos).
class ReportPdf {
  ReportPdf._();

  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  /// Largura útil da página A4 com margens de 32pt (595 - 64 ≈ 531).
  static const double _barWidth = 531;

  static String _mesPorExtenso(String monthKey) {
    final p = monthKey.split('-');
    final ano = p[0];
    final mes = int.parse(p[1]);
    return '${_meses[mes - 1]} $ano';
  }

  static String _data(DateTime? d) =>
      d == null ? '—' : '${d.day}/${d.month}/${d.year}';

  static Future<Uint8List> build(MonthlyReport r) async {
    final doc = pw.Document();
    final titulo = _mesPorExtenso(r.month);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Pulso — Relatório mensal',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('Objectivos · $titulo',
                    style: const pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey700)),
                pw.Text('Gerado em ${_data(r.generatedAt)}',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey500)),
              ],
            ),
          ),
          _resumo(r),
          pw.SizedBox(height: 20),
          pw.Text('Objectivos concluídos no mês (${r.completedCount})',
              style: pw.TextStyle(
                  fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (r.completed.isEmpty)
            pw.Text('Nenhum objectivo concluído neste mês.',
                style: const pw.TextStyle(color: PdfColors.grey600))
          else
            _tabelaConcluidos(r),
          pw.SizedBox(height: 20),
          pw.Text('Objectivos em curso (${r.activeCount})',
              style: pw.TextStyle(
                  fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (r.active.isEmpty)
            pw.Text('Nenhum objectivo activo.',
                style: const pw.TextStyle(color: PdfColors.grey600))
          else
            _graficoProgresso(r),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _resumo(MonthlyReport r) {
    pw.Widget card(String valor, String rotulo) => pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.only(right: 8),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(valor,
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(rotulo,
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey700)),
              ],
            ),
          ),
        );

    return pw.Row(children: [
      card('${r.completedCount}', 'Concluídos no mês'),
      card('${r.activeCount}', 'Em curso'),
      card('${r.avgActiveProgress.toStringAsFixed(0)}%', 'Progresso médio'),
    ]);
  }

  static pw.Widget _tabelaConcluidos(MonthlyReport r) {
    return pw.TableHelper.fromTextArray(
      headers: ['Título', 'Categoria', 'Importância', 'Prazo', 'Arquivado'],
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerStyle:
          pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      data: r.completed
          .map((g) => [
                g.title,
                g.category,
                g.importance,
                g.term,
                _data(g.archivedAt),
              ])
          .toList(),
    );
  }

  static pw.Widget _graficoProgresso(MonthlyReport r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: r.active.map((g) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text('${g.title}  ·  ${g.category}',
                        style: const pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Text('${g.progress}%  (alvo ${_data(g.targetDate)})',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Stack(children: [
                pw.Container(
                  width: _barWidth,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
                pw.Container(
                  width: _barWidth * (g.progress.clamp(0, 100)) / 100,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: g.progress >= 100
                        ? PdfColors.green
                        : PdfColors.blue400,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
              ]),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Abre o diálogo do sistema para ver / imprimir / partilhar o PDF.
  static Future<void> open(MonthlyReport r) async {
    final bytes = await build(r);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'pulso_objectivos_${r.month}.pdf',
    );
  }

  // ------------------- Relatório financeiro -------------------

  static Future<Uint8List> buildFinancial(FinancialReport r, String moeda) async {
    final doc = pw.Document();
    final maxV = r.despesasPorCategoria.isEmpty
        ? 0.0
        : r.despesasPorCategoria.first.value;

    pw.Widget card(String valor, String rotulo) => pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.only(right: 8),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('$valor $moeda',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(rotulo,
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey700)),
              ],
            ),
          ),
        );

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Pulso — Relatório mensal',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('Finanças · ${_mesPorExtenso(r.month)}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey700)),
              pw.Text('Gerado em ${_data(r.generatedAt)}',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey500)),
            ],
          ),
        ),
        pw.Row(children: [
          card(r.receitas.toStringAsFixed(0), 'Receitas'),
          card(r.despesas.toStringAsFixed(0), 'Despesas'),
          card(r.saldo.toStringAsFixed(0), 'Saldo'),
        ]),
        pw.SizedBox(height: 6),
        pw.Text('${r.nTransacoes} transações no mês',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 20),
        pw.Text('Despesas por categoria',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (r.despesasPorCategoria.isEmpty)
          pw.Text('Sem despesas.',
              style: const pw.TextStyle(color: PdfColors.grey600))
        else
          ...r.despesasPorCategoria.map((e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(e.key, style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('${e.value.toStringAsFixed(0)} $moeda',
                            style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Stack(children: [
                      pw.Container(
                        width: _barWidth,
                        height: 8,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                      pw.Container(
                        width: maxV <= 0 ? 0 : _barWidth * e.value / maxV,
                        height: 8,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue400,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                    ]),
                  ],
                ),
              )),
      ],
    ));

    return doc.save();
  }

  static Future<void> openFinancial(FinancialReport r, String moeda) async {
    final bytes = await buildFinancial(r, moeda);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'pulso_financas_${r.month}.pdf',
    );
  }
}
