import 'package:flutter/material.dart';
import 'achievements_service.dart';
import '../../utils/texts.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

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
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return AlertDialog(
      title: Text(Texts.t("addAchievement", isEnglish)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: Texts.t("achievementTitle", isEnglish),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: Texts.t("description", isEnglish),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(Texts.t("cancel", isEnglish)),
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

                  Navigator.pop(context);
                },
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(Texts.t("save", isEnglish)),
        ),
      ],
    );
  }
}
