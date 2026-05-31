import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../providers/task_providers.dart';

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

  final List<String> _priorities = ['Alta', 'Média', 'Baixa'];

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? 'Média';
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (widget.task == null) {
        // Criação
        final newTask = TasksCompanion.insert(
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty
              ? Value(_descriptionController.text)
              : const Value.absent(),
          priority: Value(_priority),
          dueDate: Value(_dueDate),
        );
        await ref.read(addTaskProvider(newTask).future);
      } else {
        // Edição — campos nullable usam Value<T?>, não-nullable usam tipo simples
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text,
          description: Value<String?>(
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
          ),
          priority: _priority,
          dueDate: Value<DateTime?>(_dueDate),
        );
        await ref.read(updateTaskProvider(updatedTask).future);
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ListTile(
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