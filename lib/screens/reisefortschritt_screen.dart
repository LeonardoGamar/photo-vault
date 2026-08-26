import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/reisefortschritt.dart';
import '../theme/app_spacing.dart';

/// „41 von 252 Ländern" – der Zähler, der süchtig macht.
///
/// Andere Reisetagebücher lassen ihn von Hand füttern. Hier stand er
/// längst in der Datenbank: Jede verortete Aufnahme trägt Land, Region
/// und Ort aus der Umkehr-Geokodierung.
class ReisefortschrittScreen extends StatelessWidget {
  final Reisefortschritt fortschritt;

  const ReisefortschrittScreen({super.key, required this.fortschritt});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    final zahl = NumberFormat.decimalPattern(
        Localizations.localeOf(context).toString());

    return Scaffold(
      appBar: AppBar(title: Text(t.fortschrittTitel)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Fortschrittsbalken(fortschritt: fortschritt),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.fortschrittHinweis(fortschritt.laenderGesamt),
            style: TextStyle(fontSize: 12, color: farben.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Text(t.fortschrittBesucht,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  for (final land in fortschritt.laender)
                    ListTile(
                      dense: true,
                      title: Text(land.name),
                      trailing: Text(zahl.format(land.aufnahmen),
                          style: TextStyle(color: farben.onSurfaceVariant)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Der Balken samt Zahlen – auch auf dem Reisen-Bildschirm verwendet.
class Fortschrittsbalken extends StatelessWidget {
  final Reisefortschritt fortschritt;

  const Fortschrittsbalken({super.key, required this.fortschritt});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.fortschrittLaender(
              fortschritt.laenderBesucht, fortschritt.laenderGesamt),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${t.fortschrittRegionen(fortschritt.regionen)} · '
          '${t.fortschrittOrte(fortschritt.orte)}',
          style: TextStyle(fontSize: 13, color: farben.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: fortschritt.anteil,
            minHeight: 8,
            // Der Balken ist bei vier von zweihundert kaum zu sehen –
            // deshalb steht die Zahl darüber und nicht darin. Ein Balken,
            // der die Auskunft allein tragen müsste, wäre hier der
            // falsche Träger.
            backgroundColor: farben.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
