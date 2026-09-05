import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../providers/goal_providers.dart';
import '../providers/task_providers.dart';
import '../services/goal_reminder_service.dart';
import '../services/goal_archive_service.dart';
import '../services/goal_progress_service.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  final Goal? goal;

  const AddGoalScreen({super.key, this.goal});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _category;
  late DateTime _targetDate;
  late int _progress;
  late String _importance;
  late String _term;

  final List<String> _categories = [
    'Geral',
    'Saúde',
    'Financeiro',
    'Carreira',
    'Pessoal',
  ];

  // Ordem = frequência crescente de lembretes por semana.
  final List<String> _importances = ['Baixa', 'Média', 'Alta', 'Crítica'];
  final List<String> _terms = ['Curto prazo', 'Longo prazo'];

  static const Map<String, String> _importanceHint = {
    'Baixa': '1 lembrete por semana',
    'Média': '2 lembretes por semana',
    'Alta': '3 lembretes por semana',
    'Crítica': '4 lembretes por semana',
  };

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _descriptionController =
        TextEditingController(text: goal?.description ?? '');
    _category = goal?.category ?? 'Geral';
    _targetDate = goal?.targetDate ?? DateTime.now().add(const Duration(days: 30));
    _progress = goal?.progressPercentage ?? 0;
    _importance = goal?.importance ?? 'Média';
    _term = goal?.term ?? 'Curto prazo';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Tarefas ligadas a este objectivo (só faz sentido em edição).
  List<Task> get _linkedTasks {
    final id = widget.goal?.id;
    if (id == null) return const [];
    return ref.read(tasksByGoalProvider(id)).valueOrNull ?? const [];
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final autoProgresso = _linkedTasks.isNotEmpty;
      if (widget.goal == null) {
        // Criação – campos não‑nullable passam directo, nullable usam Value
        final newGoal = GoalsCompanion.insert(
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty
              ? Value(_descriptionController.text)
              : const Value.absent(),
          category: Value(_category),
          targetDate: Value(_targetDate),
          progressPercentage: Value(_progress),
          importance: Value(_importance),
          term: Value(_term),
        );
        await ref.read(addGoalProvider(newGoal).future);
      } else {
        // Edição – copyWith: não‑nullable directo, nullable com Value<T?>
        final updatedGoal = widget.goal!.copyWith(
          title: _titleController.text,
          description: Value<String?>(
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
          ),
          category: _category,
          targetDate: Value<DateTime?>(_targetDate),
          // Com tarefas ligadas o progresso é automático — não se sobrepõe.
          progressPercentage: autoProgresso ? widget.goal!.progressPercentage : _progress,
          importance: _importance,
          term: _term,
        );
        await ref.read(updateGoalProvider(updatedGoal).future);
      }

      // Recalcula o progresso a partir das tarefas (se houver), arquiva se
      // chegou a 100% e reagenda os lembretes.
      if (autoProgresso) {
        await GoalProgressService.recompute(ref, widget.goal!.id);
      }
      await GoalArchiveService.sweep(ref);
      await GoalReminderService.rescheduleAll(ref);

      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget _buildProgresso() {
    final id = widget.goal?.id;
    final tasks = id == null
        ? const <Task>[]
        : (ref.watch(tasksByGoalProvider(id)).valueOrNull ?? const <Task>[]);

    // Com tarefas ligadas → progresso automático (slider escondido).
    if (tasks.isNotEmpty) {
      final done = tasks.where((t) => t.isCompleted).length;
      final pct = (done / tasks.length * 100).round();
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, size: 18),
                const SizedBox(width: 8),
                Text('Progresso automático: $pct%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text('$done de ${tasks.length} tarefas concluídas',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: pct / 100, minHeight: 8),
            ),
          ],
        ),
      );
    }

    // Sem tarefas → progresso manual.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progresso: $_progress%'),
        Slider(
          value: _progress.toDouble(),
          min: 0,
          max: 100,
          divisions: 10,
          label: '$_progress%',
          onChanged: (val) => setState(() => _progress = val.round()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Novo Objectivo' : 'Editar Objectivo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((cat) =>
                      DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _importance,
              items: _importances
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: (val) => setState(() => _importance = val!),
              decoration: InputDecoration(
                labelText: 'Importância',
                helperText: _importanceHint[_importance],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _term,
              items: _terms
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _term = val!),
              decoration: const InputDecoration(labelText: 'Prazo'),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Data alvo: ${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
            ),
            const SizedBox(height: 16),
            _buildProgresso(),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(widget.goal == null ? 'Criar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}