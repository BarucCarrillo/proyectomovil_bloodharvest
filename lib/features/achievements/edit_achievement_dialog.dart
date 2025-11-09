import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievements_service.dart';

class EditAchievementDialog extends StatefulWidget {
  final String achievementId;
  final Map<String, dynamic> achievementData;

  const EditAchievementDialog({
    super.key,
    required this.achievementId,
    required this.achievementData,
  });

  @override
  _EditAchievementDialogState createState() => _EditAchievementDialogState();
}

class _EditAchievementDialogState extends State<EditAchievementDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.achievementData['title'],
    );
    _descriptionController = TextEditingController(
      text: widget.achievementData['description'],
    );
    _selectedDate = (widget.achievementData['date'] as Timestamp)
        .toDate(); // Convertir desde Firestore
  }

  @override
  Widget build(BuildContext context) {
    final achievementsService = AchievementsService();

    return AlertDialog(
      title: const Text('Editar Logro'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un título' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Fecha: "),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => _selectedDate = pickedDate);
                      }
                    },
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await achievementsService.updateAchievement(
                widget.achievementId,
                _titleController.text.trim(),
                _descriptionController.text.trim(),
                _selectedDate,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
