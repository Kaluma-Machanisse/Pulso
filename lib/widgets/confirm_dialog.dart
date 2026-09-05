import 'package:flutter/material.dart';

/// Diálogo genérico de confirmação de eliminação.
/// Devolve `true` só se o utilizador confirmar.
Future<bool> confirmarEliminacao(BuildContext context, String nome) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar?'),
      content: Text(
        'Queres mesmo eliminar "$nome"? Esta acção não pode ser anulada.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
