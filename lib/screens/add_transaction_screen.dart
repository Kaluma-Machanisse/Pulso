import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../providers/transaction_providers.dart';
import '../providers/settings_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? tx;
  const AddTransactionScreen({super.key, this.tx});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _type;
  late String _category;
  late DateTime _date;
  late TextEditingController _customCategoryController;

  static const String _outroValue = 'Outro';

  final List<String> _categories = [
    'Geral',
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Salário',
    'Negócio',
    'SMS',
    'Outro',
  ];

  bool get _isCustomCategory =>
      _category == _outroValue || !_categories.contains(_category);

  @override
  void initState() {
    super.initState();
    final tx = widget.tx;
    _amountController =
        TextEditingController(text: tx != null ? tx.amount.toString() : '');
    _descriptionController =
        TextEditingController(text: tx?.description ?? '');
    _type = tx?.type ?? 'despesa';
    _date = tx?.date ?? DateTime.now();
    final categoriaExistente = tx?.category ?? 'Geral';
    if (categoriaExistente != _outroValue &&
        !_categories.contains(categoriaExistente)) {
      // Categoria personalizada criada anteriormente: editar directamente o nome.
      _category = _outroValue;
      _customCategoryController =
          TextEditingController(text: categoriaExistente);
    } else {
      _category = categoriaExistente;
      _customCategoryController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final categoriaFinal = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _category;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    final desc = _descriptionController.text.isNotEmpty
        ? Value(_descriptionController.text)
        : const Value<String?>(null);

    if (widget.tx == null) {
      await ref.read(addTransactionProvider(TransactionsCompanion(
        amount: Value(amount),
        type: Value(_type),
        category: Value(categoriaFinal),
        description: desc,
        date: Value(_date),
        source: const Value('manual'),
      )).future);
    } else {
      await ref.read(updateTransactionProvider(widget.tx!.copyWith(
        amount: amount,
        type: _type,
        category: categoriaFinal,
        description: desc,
        date: _date,
      )).future);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final moeda = ref.watch(settingsProvider).currency;
    final editar = widget.tx != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editar ? 'Editar Transação' : 'Nova Transação'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'receita',
                    label: Text('Receita'),
                    icon: Icon(Icons.arrow_downward)),
                ButtonSegment(
                    value: 'despesa',
                    label: Text('Despesa'),
                    icon: Icon(Icons.arrow_upward)),
              ],
              selected: {_type},
              onSelectionChanged: (val) => setState(() => _type = val.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Valor ($moeda) *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            if (_isCustomCategory) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Nome do tipo de gasto *',
                  helperText:
                      'Este nome vai aparecer nos gráficos e orçamentos',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Indica um nome para esta categoria'
                    : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text('Data: ${_date.day}/${_date.month}/${_date.year}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(editar ? 'Guardar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }
}
