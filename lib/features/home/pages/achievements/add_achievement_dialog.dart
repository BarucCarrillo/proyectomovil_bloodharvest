import 'package:flutter/material.dart';
import 'achievements_service.dart';

class AddAchievementDialog extends StatefulWidget {
  const AddAchievementDialog({super.key});

  @override
  State<AddAchievementDialog> createState() => _AddAchievementDialogState();
}

class _AddAchievementDialogState extends State<AddAchievementDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar nuevo logro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título del Logro'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (_titleController.text.isEmpty) return;

                  setState(() => _isLoading = true);
                  await AchievementsService().addAchievements(
                    _titleController.text.trim(),
                    _descController.text.trim(),
                  );
                },
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
