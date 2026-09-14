import 'package:flutter/material.dart';

/// Ícone e cor de cada categoria financeira — dá identidade visual própria
/// a cada tipo de gasto/receita em vez de um ícone genérico único.
class CategoryStyle {
  CategoryStyle._();

  static const Map<String, IconData> _icons = {
    'Geral': Icons.category_rounded,
    'Alimentação': Icons.restaurant_rounded,
    'Transporte': Icons.directions_car_filled_rounded,
    'Saúde': Icons.local_hospital_rounded,
    'Lazer': Icons.sports_esports_rounded,
    'Salário': Icons.payments_rounded,
    'Negócio': Icons.storefront_rounded,
    'SMS': Icons.sms_rounded,
    'Outro': Icons.more_horiz_rounded,
  };

  static const List<Color> _paleta = [
    Color(0xFF2F6BED),
    Color(0xFFE8A13C),
    Color(0xFF9C6BE0),
    Color(0xFF1FA971),
    Color(0xFFE5484D),
    Color(0xFF2FA9C9),
    Color(0xFFC2528B),
  ];

  static IconData icon(String categoria) =>
      _icons[categoria] ?? Icons.label_outline_rounded;

  /// Cor estável por categoria — categorias personalizadas (fora da lista
  /// fixa) recebem uma cor da paleta com base no nome, sempre a mesma.
  static Color color(String categoria) {
    const fixas = {
      'Geral': Color(0xFF707784),
      'Alimentação': Color(0xFFE8A13C),
      'Transporte': Color(0xFF2FA9C9),
      'Saúde': Color(0xFFE5484D),
      'Lazer': Color(0xFF9C6BE0),
      'Salário': Color(0xFF1FA971),
      'Negócio': Color(0xFF2F6BED),
      'SMS': Color(0xFF8A909C),
      'Outro': Color(0xFFC2528B),
    };
    if (fixas.containsKey(categoria)) return fixas[categoria]!;
    final idx = categoria.codeUnits.fold<int>(0, (s, c) => s + c) % _paleta.length;
    return _paleta[idx];
  }
}
