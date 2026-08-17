import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../db/database.dart';

class PersonChoice {
  final String? newName;
  final String? existingPersonId;
  PersonChoice.newPerson(this.newName) : existingPersonId = null;
  PersonChoice.existing(this.existingPersonId) : newName = null;
}

/// Zeigt einen Dialog, um ein (oder mehrere) Gesicht(er) einer neuen oder
/// bestehenden Person zuzuordnen. Wird sowohl bei der Massenzuordnung in
/// "Unbenannte Gesichter" als auch in der Foto-Detailansicht (Gesichter
/// direkt am Foto benennen) verwendet.
Future<PersonChoice?> showPersonPickerDialog(
  BuildContext context,
  List<PersonData> existingPeople, {
  String? title,
  String? currentName,
  PersonData? suggestedPerson,
}) {
  return showDialog<PersonChoice>(
    context: context,
    builder: (context) => _PersonPickerDialog(
      existingPeople: existingPeople,
      // Vorgabewert erst hier: im Kopf gibt es noch keinen Kontext.
      title: title ?? AppTexte.of(context).personZuordnenTitel,
      currentName: currentName,
      suggestedPerson: suggestedPerson,
    ),
  );
}

class _PersonPickerDialog extends StatefulWidget {
  final List<PersonData> existingPeople;
  final String title;
  final String? currentName;
  final PersonData? suggestedPerson;
  const _PersonPickerDialog({
    required this.existingPeople,
    required this.title,
    this.currentName,
    this.suggestedPerson,
  });

  @override
  State<_PersonPickerDialog> createState() => _PersonPickerDialogState();
}

class _PersonPickerDialogState extends State<_PersonPickerDialog> {
  final _nameCtrl = TextEditingController();
  late PersonData? _selectedExisting = widget.suggestedPerson;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.currentName != null) ...[
            Text(AppTexte.of(context).personAktuell(widget.currentName!),
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
          ],
          if (widget.existingPeople.isNotEmpty) ...[
            DropdownButtonFormField<PersonData>(
              initialValue: _selectedExisting,
              isExpanded: true,
              decoration: InputDecoration(labelText: AppTexte.of(context).personBestehende),
              items: widget.existingPeople
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (p) => setState(() => _selectedExisting = p),
            ),
            const SizedBox(height: 12),
            Text(AppTexte.of(context).allgOder, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: AppTexte.of(context).personNeuAnlegen),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTexte.of(context).allgAbbrechen)),
        FilledButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isNotEmpty) {
              Navigator.pop(context, PersonChoice.newPerson(_nameCtrl.text.trim()));
            } else if (_selectedExisting != null) {
              Navigator.pop(context, PersonChoice.existing(_selectedExisting!.id));
            }
          },
          child: Text(AppTexte.of(context).personZuordnenAktion),
        ),
      ],
    );
  }
}
