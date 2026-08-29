import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../db/database.dart';
import '../services/storage_paths.dart';
import 'profilbild.dart';

/// Was der Nutzer im Zuordnungs-Dialog entschieden hat.
class PersonChoice {
  final String? newName;
  final String? existingPersonId;

  /// „Das ist kein Gesicht" bzw. „interessiert mich nicht" – nur möglich,
  /// wenn der Aufrufer es mit `erlaubtIgnorieren` angeboten hat.
  final bool ignorieren;

  PersonChoice.newPerson(this.newName)
      : existingPersonId = null,
        ignorieren = false;
  PersonChoice.existing(this.existingPersonId)
      : newName = null,
        ignorieren = false;
  const PersonChoice.ignorieren()
      : newName = null,
        existingPersonId = null,
        ignorieren = true;
}

/// Zeigt einen Dialog, um ein (oder mehrere) Gesicht(er) einer neuen oder
/// bestehenden Person zuzuordnen. Wird sowohl bei der Massenzuordnung in
/// "Unbenannte Gesichter" als auch in der Foto-Detailansicht (Gesichter
/// direkt am Foto benennen) verwendet.
///
/// [paths] wird für die Profilbilder in der Liste gebraucht: Bei mehr als
/// einer Handvoll Personen sagt ein Name allein wenig – zwei Verwandte
/// gleichen Vornamens sind an der Schreibweise nicht zu unterscheiden, an
/// ihren Gesichtern sofort.
Future<PersonChoice?> showPersonPickerDialog(
  BuildContext context,
  List<PersonData> existingPeople, {
  required StoragePaths paths,
  String? title,
  String? currentName,
  PersonData? suggestedPerson,
  bool erlaubtIgnorieren = false,
}) {
  return showDialog<PersonChoice>(
    context: context,
    builder: (context) => _PersonPickerDialog(
      existingPeople: existingPeople,
      paths: paths,
      // Vorgabewert erst hier: im Kopf gibt es noch keinen Kontext.
      title: title ?? AppTexte.of(context).personZuordnenTitel,
      currentName: currentName,
      suggestedPerson: suggestedPerson,
      erlaubtIgnorieren: erlaubtIgnorieren,
    ),
  );
}

class _PersonPickerDialog extends StatefulWidget {
  final List<PersonData> existingPeople;
  final StoragePaths paths;
  final String title;
  final String? currentName;
  final PersonData? suggestedPerson;
  final bool erlaubtIgnorieren;
  const _PersonPickerDialog({
    required this.existingPeople,
    required this.paths,
    required this.title,
    this.currentName,
    this.suggestedPerson,
    this.erlaubtIgnorieren = false,
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

  /// Eine Zeile der Liste: Profilbild und Name.
  ///
  /// [imMenue] unterscheidet die aufgeklappte Liste von der zusammen-
  /// geklappten Schaltfläche. In der Liste ist Platz, in der Schaltfläche
  /// nicht – dort muss der Name notfalls abgeschnitten werden, sonst läuft
  /// die Zeile über den Dialogrand hinaus.
  Widget _zeile(PersonData person, {required bool imMenue}) {
    final bild = person.coverFaceCropPath;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Profilbild(
          datei: bild == null ? null : widget.paths.absolute(bild),
          radius: 14,
          hintergrund: Theme.of(context).colorScheme.surfaceContainerHighest,
          symbolgroesse: 16,
        ),
        const SizedBox(width: 10),
        imMenue
            ? Text(person.name)
            : Flexible(child: Text(person.name, overflow: TextOverflow.ellipsis)),
      ],
    );
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
              // Ohne eigenes selectedItemBuilder zeigt Flutter in der
              // zugeklappten Schaltfläche denselben Aufbau wie im Menü –
              // dort aber ohne Breitenbegrenzung, was bei langen Namen
              // überläuft.
              selectedItemBuilder: (context) => widget.existingPeople
                  .map((p) => Align(
                        alignment: Alignment.centerLeft,
                        child: _zeile(p, imMenue: false),
                      ))
                  .toList(),
              items: widget.existingPeople
                  .map((p) => DropdownMenuItem(value: p, child: _zeile(p, imMenue: true)))
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
        if (widget.erlaubtIgnorieren)
          TextButton(
            onPressed: () => Navigator.pop(context, const PersonChoice.ignorieren()),
            child: Text(AppTexte.of(context).gesichtIgnorieren),
          ),
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
