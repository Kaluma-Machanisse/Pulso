// Gera os PNGs do ícone da app a partir do símbolo Pulso (linha de batimento).
// Correr:  flutter test test/gen_icons_test.dart
//
// Produz:
//   assets/icon/icon.png             — ícone completo (fundo tinta + linha)
//   assets/icon/icon_foreground.png  — só a linha, centrada com margem (adaptive)
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _ink = Color(0xFF15171C);
const _blue = Color(0xFF5B8CFF);

Path _pulsePath(double s) {
  // Linha de ECG centrada numa caixa s x s.
  final y = s * 0.5;
  return Path()
    ..moveTo(s * 0.14, y)
    ..lineTo(s * 0.40, y)
    ..lineTo(s * 0.44, y)
    ..lineTo(s * 0.50, y - s * 0.17)
    ..lineTo(s * 0.57, y + s * 0.13)
    ..lineTo(s * 0.62, y)
    ..lineTo(s * 0.86, y);
}

Future<void> _write(String path, Future<ui.Image> Function() build) async {
  final img = await build();
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  test('gerar ícones', () async {
    const size = 1024.0;

    // ---- icon.png : fundo tinta + linha azul ----
    await _write('assets/icon/icon.png', () async {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      c.drawRect(const Rect.fromLTWH(0, 0, size, size), Paint()..color = _ink);
      c.drawPath(
        _pulsePath(size),
        Paint()
          ..color = _blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.055
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      return rec.endRecording().toImage(size.toInt(), size.toInt());
    });

    // ---- icon_foreground.png : só a linha, com margem segura (adaptive) ----
    await _write('assets/icon/icon_foreground.png', () async {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      // escala 0.6 e centra (a máscara adaptive corta ~1/3 de cada lado)
      c.translate(size * 0.2, size * 0.2);
      c.scale(0.6);
      c.drawPath(
        _pulsePath(size),
        Paint()
          ..color = _blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.055 / 0.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      return rec.endRecording().toImage(size.toInt(), size.toInt());
    });

    expect(File('assets/icon/icon.png').existsSync(), isTrue);
    expect(File('assets/icon/icon_foreground.png').existsSync(), isTrue);
  });
}
