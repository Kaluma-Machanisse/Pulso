import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../providers/task_providers.dart';
import '../providers/goal_providers.dart';
import '../services/goal_progress_service.dart';
import '../services/task_reminder_service.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _priority;
  late DateTime _dueDate;
  int? _goalId;
  bool _completed = false;

  bool _isHabit = false;
  late DateTime _habitStart;
  late DateTime _habitEnd;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _priorities = ['Alta', 'Média', 'Baixa'];

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? 'Média';
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _goalId = task?.goalId;
    _completed = task?.isCompleted ?? false;

    _isHabit = task?.isHabit ?? false;
    _habitStart = task?.habitStartDate ?? DateTime.now();
    _habitEnd = task?.habitEndDate ?? DateTime.now().add(const Duration(days: 29));
    if (task?.reminderHour != null) {
      _reminderTime =
          TimeOfDay(hour: task!.reminderHour!, minute: task.reminderMinute ?? 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isHabit && !_habitEnd.isAfter(_habitStart)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('A data de fim tem de ser depois da data de início.'),
      ));
      return;
    }

    final oldGoalId = widget.task?.goalId;

    if (widget.task == null) {
      final newTask = TasksCompanion.insert(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? Value(_descriptionController.text)
            : const Value.absent(),
        priority: Value(_priority),
        dueDate: _isHabit ? const Value.absent() : Value(_dueDate),
        isCompleted: Value(_isHabit ? false : _completed),
        goalId: _goalId != null ? Value(_goalId!) : const Value.absent(),
        isHabit: Value(_isHabit),
        habitStartDate: _isHabit ? Value(_habitStart) : const Value.absent(),
        habitEndDate: _isHabit ? Value(_habitEnd) : const Value.absent(),
        reminderHour: _isHabit ? Value(_reminderTime.hour) : const Value.absent(),
        reminderMinute:
            _isHabit ? Value(_reminderTime.minute) : const Value.absent(),
      );
      await ref.read(addTaskProvider(newTask).future);
    } else {
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text,
        description: Value<String?>(
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        ),
        priority: _priority,
        dueDate: Value<DateTime?>(_isHabit ? null : _dueDate),
        isCompleted: _isHabit ? widget.task!.isCompleted : _completed,
        goalId: Value<int?>(_goalId),
        habitStartDate: Value<DateTime?>(_isHabit ? _habitStart : null),
        habitEndDate: Value<DateTime?>(_isHabit ? _habitEnd : null),
        reminderHour: Value<int?>(_isHabit ? _reminderTime.hour : null),
        reminderMinute: Value<int?>(_isHabit ? _reminderTime.minute : null),
      );
      await ref.read(updateTaskProvider(updatedTask).future);
    }

    // Actualiza o progresso do(s) objectivo(s) afectado(s) e reagenda os
    // lembretes das tarefas.
    await GoalProgressService.recompute(ref, _goalId);
    if (oldGoalId != null && oldGoalId != _goalId) {
      await GoalProgressService.recompute(ref, oldGoalId);
    }
    await TaskReminderService.rescheduleAll(ref);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _escolherData({required bool inicio}) async {
    final actual = inicio ? _habitStart : _habitEnd;
    final picked = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (inicio) {
        _habitStart = picked;
        if (!_habitEnd.isAfter(_habitStart)) {
          _habitEnd = _habitStart.add(const Duration(days: 29));
        }
      } else {
        _habitEnd = picked;
      }
    });
  }

  Future<void> _escolherHora() async {
    final picked =
        await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null) setState(() => _reminderTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);
    final podeMudarTipo = widget.task == null; // só ao criar

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
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
              initialValue: _priority,
              items: _priorities
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => _priority = val!),
              decoration: const InputDecoration(labelText: 'Prioridade'),
            ),
            const SizedBox(height: 16),
            goalsAsync.when(
              data: (goals) => DropdownButtonFormField<int?>(
                initialValue:
                    goals.any((g) => g.id == _goalId) ? _goalId : null,
                decoration: const InputDecoration(
                  labelText: 'Objectivo (opcional)',
                  helperText:
                      'Ligar a um objectivo faz o progresso dele contar as tarefas',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nenhum')),
                  for (final g in goals)
                    DropdownMenuItem(value: g.id, child: Text(g.title)),
                ],
                onChanged: (val) => setState(() => _goalId = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const Divider(height: 32),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tarefa-hábito'),
              subtitle: const Text(
                  'Check-in diário durante um período, em vez de uma data única'),
              value: _isHabit,
              onChanged: podeMudarTipo
                  ? (v) => setState(() => _isHabit = v)
                  : null,
            ),

            if (_isHabit) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(
                    'Início: ${_habitStart.day}/${_habitStart.month}/${_habitStart.year}'),
                onTap: () => _escolherData(inicio: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available),
                title: Text(
                    'Fim: ${_habitEnd.day}/${_habitEnd.month}/${_habitEnd.year}'
                    '  (${_habitEnd.difference(_habitStart).inDays + 1} dias)'),
                onTap: () => _escolherData(inicio: false),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(
                    'Lembrete diário às ${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'),
                onTap: _escolherHora,
              ),
            ] else ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Concluída'),
                value: _completed,
                onChanged: (v) => setState(() => _completed = v),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Data de vencimento: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(widget.task == null ? 'Criar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
