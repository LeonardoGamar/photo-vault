import 'package:flutter/material.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/profilbild.dart';
import 'person_suggestions_screen.dart';

/// Was die Wiedererkennung gefunden hat – nach Person gebündelt.
///
/// **Warum eine eigene Liste und nicht gleich die Bestätigung.** Die
/// Vorschläge verteilen sich über die benannten Personen sehr ungleich;
/// an der echten Bibliothek liegen 215 bei einer Person und 12 bei einer
/// anderen. Wer erst die Verteilung sieht, entscheidet, wo sich das
/// Durchsehen lohnt – und bestätigt dann geschlossen für eine Person, mit
/// dem Bildschirm, den es dafür schon gibt ([PersonSuggestionsScreen]).
///
/// **Beiseitegelegte sind ein eigener Schalter.** Sie sind entschieden;
/// sie ungefragt wieder vorzulegen wäre Widerspruch statt Hilfe. Als
/// ausdrücklicher Durchgang lohnt es sich trotzdem: Weggelegt wurde,
/// bevor es die heutigen Personen gab.
class VorschlaegeScreen extends StatefulWidget {
  const VorschlaegeScreen({super.key, required this.library});

  final LibraryState library;

  @override
  State<VorschlaegeScreen> createState() => _VorschlaegeScreenState();
}

class _VorschlaegeScreenState extends State<VorschlaegeScreen> {
  bool _beiseite = false;
  late Future<List<({PersonData person, int anzahl})>> _liste = _laden();
  late Future<int> _nochNieVerglichen =
      widget.library.db.countWiedererkennungOffen();

  Future<List<({PersonData person, int anzahl})>> _laden() =>
      widget.library.db.vorschlaegeJePerson(beiseite: _beiseite);

  void _neuLaden() => setState(() {
        _liste = _laden();
        _nochNieVerglichen = widget.library.db.countWiedererkennungOffen();
      });

  Future<void> _oeffne(PersonData person) async {
    final vorschlaege = await widget.library.db
        .vorschlaegeFuerPerson(person.id, beiseite: _beiseite);
    if (!mounted || vorschlaege.isEmpty) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PersonSuggestionsScreen(
        library: widget.library,
        person: person,
        vorschlaege: vorschlaege,
      ),
    ));
    _neuLaden();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.vorschlaegeTitel)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(t.vorschlaegeEinleitung,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _beiseite,
            onChanged: (an) => setState(() {
              _beiseite = an;
              _liste = _laden();
            }),
            title: Text(t.vorschlaegeBeiseite),
            subtitle: _beiseite ? Text(t.vorschlaegeBeiseiteHinweis) : null,
          ),
          const Divider(),
          FutureBuilder<List<({PersonData person, int anzahl})>>(
            future: _liste,
            builder: (context, schnappschuss) {
              if (!schnappschuss.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final zeilen = schnappschuss.data!;
              if (zeilen.isEmpty) return _leer(t);
              return Column(
                children: [
                  for (final zeile in zeilen)
                    ListTile(
                      leading: Profilbild(
                        datei: zeile.person.coverFaceCropPath == null
                            ? null
                            : widget.library.paths
                                .absolute(zeile.person.coverFaceCropPath!),
                        radius: 20,
                        hintergrund: Colors.grey.shade800,
                        symbolgroesse: 18,
                      ),
                      title: Text(zeile.person.name),
                      subtitle: Text(t.vorschlaegeAnzahl(zeile.anzahl)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _oeffne(zeile.person),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Leer ist nicht gleich leer: „nichts gefunden" und „noch gar nicht
  /// gesucht" sind zwei verschiedene Auskünfte, und nur die zweite hat
  /// einen nächsten Schritt.
  Widget _leer(AppTexte t) => FutureBuilder<int>(
        future: _nochNieVerglichen,
        builder: (context, stand) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            _beiseite
                ? t.vorschlaegeBeiseiteLeer
                : (stand.data ?? 0) > 0
                    ? t.vorschlaegeLaufHinweis
                    : t.vorschlaegeKeine,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
}
