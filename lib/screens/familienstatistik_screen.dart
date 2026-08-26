import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/familienstatistik.dart';
import '../theme/app_spacing.dart';

/// Zahlen über eine Familie.
///
/// Statistik gab es bisher nur über Fotos – über die Menschen darauf
/// sagte die App nichts, obwohl alle Angaben dafür längst eingetragen
/// sind.
///
/// Der Bildschirm rechnet **nicht selbst**: Er bekommt die fertige
/// [Familienstatistik] herein. Die Rechnungen stehen als reine
/// Funktionen in services/familienstatistik.dart, und nur dort sind sie
/// nachprüfbar – am fertigen Balkendiagramm ist ein falscher
/// Durchschnitt nicht zu erkennen.
class FamilienstatistikScreen extends StatelessWidget {
  final Familienstatistik statistik;

  /// Der Name der Person in der Mitte – die Auswertung gilt für ihre
  /// Familie, nicht für die ganze Bibliothek.
  final String fokusName;

  const FamilienstatistikScreen({
    super.key,
    required this.statistik,
    required this.fokusName,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final zahl = NumberFormat.decimalPattern(
        Localizations.localeOf(context).toString());
    final einStelle = NumberFormat('#,##0.#',
        Localizations.localeOf(context).toString());

    String jahre(double? wert) =>
        wert == null ? t.famstatOhneWert : t.famstatJahre(einStelle.format(wert));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.stammbaumFamilienstatistik),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.lg, bottom: AppSpacing.sm),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(fokusName,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ),
      ),
      body: statistik.istLeer
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: SizedBox(
                  width: 420,
                  child: Text(t.famstatLeer, textAlign: TextAlign.center),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _Kachel(
                      symbol: Icons.groups_outlined,
                      titel: t.famstatPersonen,
                      wert: zahl.format(statistik.personen),
                    ),
                    _Kachel(
                      symbol: Icons.hourglass_bottom_outlined,
                      titel: t.famstatLebensalter,
                      wert: jahre(statistik.sterbealter.durchschnitt),
                      unten: statistik.sterbealter.istLeer
                          ? null
                          : t.famstatSpanne(statistik.sterbealter.kleinstes!,
                              statistik.sterbealter.groesstes!),
                    ),
                    _Kachel(
                      symbol: Icons.favorite_outline,
                      titel: t.famstatHeiratsalter,
                      wert: jahre(statistik.heiratsalter.durchschnitt),
                      unten: statistik.heiratsalter.istLeer
                          ? null
                          : t.famstatEingerechnet(
                              statistik.heiratsalter.anzahl),
                    ),
                    if (statistik.nachnamen.isNotEmpty)
                      _Kachel(
                        symbol: Icons.badge_outlined,
                        titel: t.famstatHaeufigsterName,
                        wert: statistik.nachnamen.first.name,
                        unten: zahl.format(statistik.nachnamen.first.anzahl),
                      ),
                  ],
                ),

                // Der Hinweis steht direkt unter der Zahl, auf die er
                // sich bezieht – nicht als Fußnote am Seitenende. Eine
                // Einschränkung, die man erst nach dem Weiterblättern
                // liest, ist keine.
                if (statistik.sterbealter.nichtGezaehlt > 0)
                  _Einschraenkung(
                    text: t.famstatOhneSterbedatum(
                        statistik.sterbealter.nichtGezaehlt),
                    grund: t.famstatWarumOhneSterbedatum,
                  ),
                if (statistik.heiratsalter.nichtGezaehlt > 0)
                  _Einschraenkung(
                    text: t.famstatOhneGeburtsdatum(
                        statistik.heiratsalter.nichtGezaehlt),
                  ),

                if (statistik.alterJeGeneration.isNotEmpty) ...[
                  _Ueberschrift(t.famstatAlterJeGeneration),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.sm,
                          AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
                      child: _GenerationenDiagramm(
                          werte: statistik.alterJeGeneration),
                    ),
                  ),
                  _Fussnote(t.famstatGenerationHinweis),
                ],

                _Ueberschrift(t.famstatKinderzahl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sm,
                        AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
                    child: _KinderDiagramm(
                        verteilung: statistik.kinderverteilung),
                  ),
                ),
                _Fussnote(t.famstatKinderHinweis),

                if (statistik.nachnamen.isNotEmpty) ...[
                  _Ueberschrift(t.famstatNachnamen),
                  _Namensliste(eintraege: statistik.nachnamen),
                ],
                if (statistik.vornamen.isNotEmpty) ...[
                  _Ueberschrift(t.famstatVornamen),
                  _Namensliste(eintraege: statistik.vornamen),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
    );
  }
}

class _Ueberschrift extends StatelessWidget {
  final String text;
  const _Ueberschrift(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: AppSpacing.sm),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Fussnote extends StatelessWidget {
  final String text;
  const _Fussnote(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
}

/// Was in einer Zahl **nicht** steckt.
///
/// Absichtlich auffällig und nicht als graue Fußnote: Der ausgeschlossene
/// Teil ist hier keine Nebensache, sondern der Unterschied zwischen einer
/// richtigen und einer grob falschen Zahl.
class _Einschraenkung extends StatelessWidget {
  final String text;
  final String? grund;
  const _Einschraenkung({required this.text, this.grund});

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: farben.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: farben.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: const TextStyle(fontSize: 13)),
                  if (grund != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        grund!,
                        style: TextStyle(
                            fontSize: 12, color: farben.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kachel extends StatelessWidget {
  final IconData symbol;
  final String titel;
  final String wert;
  final String? unten;

  const _Kachel({
    required this.symbol,
    required this.titel,
    required this.wert,
    this.unten,
  });

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(symbol, color: farben.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titel,
                        style: TextStyle(
                            fontSize: 12, color: farben.onSurfaceVariant)),
                    Text(wert,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    if (unten != null)
                      Text(unten!,
                          style: TextStyle(
                              fontSize: 11, color: farben.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenerationenDiagramm extends StatelessWidget {
  final Map<int, Altersauswertung> werte;
  const _GenerationenDiagramm({required this.werte});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farbe = Theme.of(context).colorScheme.primary;
    final stufen = werte.keys.toList()..sort();
    final hoechstes = werte.values
        .fold<double>(0, (a, b) => (b.durchschnitt ?? 0) > a ? b.durchschnitt! : a);

    return Semantics(
      label: t.famstatDiagrammGenerationen([
        for (final s in stufen)
          '${t.famstatGeneration(s)}: '
              '${werte[s]!.durchschnitt!.round()}'
      ].join(', ')),
      child: ExcludeSemantics(
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: hoechstes == 0 ? 1 : hoechstes * 1.15,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (gruppe, _, stab, __) => BarTooltipItem(
                    '${t.famstatGeneration(stufen[gruppe.x.toInt()])}\n'
                    '${stab.toY.round()}',
                    const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (wert, meta) {
                      final i = wert.toInt();
                      if (i < 0 || i >= stufen.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(t.famstatGenerationKurz(stufen[i]),
                            style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < stufen.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: werte[stufen[i]]!.durchschnitt!,
                      color: farbe,
                      width: 20,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KinderDiagramm extends StatelessWidget {
  final Map<int, int> verteilung;
  const _KinderDiagramm({required this.verteilung});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farbe = Theme.of(context).colorScheme.secondary;
    // Lückenlos von null bis zur höchsten vorkommenden Kinderzahl: Eine
    // fehlende Spalte in der Mitte („niemand hat genau drei") ist selbst
    // eine Aussage und darf nicht wegfallen.
    final hoechste =
        verteilung.keys.fold<int>(0, (a, b) => b > a ? b : a);
    final stufen = [for (var k = 0; k <= hoechste; k++) k];
    final hoechstes =
        verteilung.values.fold<int>(0, (a, b) => b > a ? b : a);

    return Semantics(
      label: t.famstatDiagrammKinder([
        for (final k in stufen)
          '${t.famstatKinderAchse(k)}: ${verteilung[k] ?? 0}'
      ].join(', ')),
      child: ExcludeSemantics(
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: hoechstes == 0 ? 1 : hoechstes * 1.15,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (gruppe, _, stab, __) => BarTooltipItem(
                    '${t.famstatKinderAchse(stufen[gruppe.x.toInt()])}\n'
                    '${stab.toY.round()}',
                    const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (wert, meta) {
                      final i = wert.toInt();
                      if (i < 0 || i >= stufen.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text('${stufen[i]}',
                            style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < stufen.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: (verteilung[stufen[i]] ?? 0).toDouble(),
                      color: farbe,
                      width: 20,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Namensliste extends StatelessWidget {
  final List<({String name, int anzahl})> eintraege;
  const _Namensliste({required this.eintraege});

  @override
  Widget build(BuildContext context) {
    final farbe = Theme.of(context).colorScheme.primary;
    final hoechstes = eintraege.fold<int>(0, (a, e) => e.anzahl > a ? e.anzahl : a);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            for (final e in eintraege)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(e.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: farbe.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xs),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor:
                                hoechstes == 0 ? 0 : e.anzahl / hoechstes,
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: farbe,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xs),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 32,
                      child: Text('${e.anzahl}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
