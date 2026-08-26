import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/hintergrundlauf.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../services/meldungsdienst.dart';

/// Eine Aktion innerhalb einer [_TaskCard] – startet einen der
/// `Stream<ImportProgress>`-Backfills auf [LibraryState] als Lauf, der das
/// Wegnavigieren überlebt.
class _TaskAction {
  final String label;
  final IconData icon;

  /// Was während des Laufs in der Karte steht – „Bildbeschreibungen werden
  /// erzeugt". Hiess früher `dialogTitle`, weil er die Kopfzeile des
  /// Fortschrittsfensters füllte; den Namen behält er nicht, damit niemand
  /// nach einem Fenster sucht, das es nicht mehr gibt.
  final String laufTitel;
  final String emptyMessage;
  final Stream<ImportProgress> Function() stream;
  const _TaskAction({
    required this.label,
    required this.icon,
    required this.laufTitel,
    required this.emptyMessage,
    required this.stream,
  });
}

/// Einheitlicher Hinweistext für ein fehlendes KI-Modell/Datenset – dieselbe
/// Formulierung wie in ToolsScreen (Werkzeuge), damit beide Einstiegspunkte
/// nicht auseinanderdriften.
String? _modelHint(AppTexte t, bool available, String model, String where) =>
    available ? null : t.aufgModellNoetig(model, where);

/// Der Zustand eines laufenden oder eben beendeten Vorgangs, dort wo sonst
/// die Zahlen „Aktiv/Wartend" stehen.
///
/// Das ersetzt das frühere Fortschrittsfenster. Es sperrte den Bildschirm,
/// liess sich nicht beiseitelegen und machte die Bezeichnung
/// „Hintergrundaufgabe" zur Fehlbeschriftung: Wer die Bibliothek währenddessen
/// ansehen wollte, musste abbrechen.
class _Laufanzeige extends StatelessWidget {
  final Hintergrundlauf lauf;
  const _Laufanzeige({required this.lauf});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;

    final String satz;
    if (lauf.fehler != null) {
      satz = t.fortschrittFehlgeschlagen('${lauf.fehler}');
    } else if (lauf.gesamt == 0) {
      // Der Strom war sofort durch: Es gab nichts nachzuholen. Die Meldung
      // der Karte ist genauer als ein „0 / 0".
      satz = lauf.beendet ? lauf.leermeldung : t.aufgWirdErmittelt;
    } else if (lauf.abgebrochen) {
      satz = t.aufgAbgebrochenBei(lauf.erledigt, lauf.gesamt);
    } else if (lauf.beendet) {
      satz = t.aufgFertigMit(lauf.gesamt);
    } else {
      satz = '${lauf.erledigt} / ${lauf.gesamt}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lauf.titel, style: TextStyle(fontSize: 13, color: farben.onSurface)),
        const SizedBox(height: AppSpacing.sm),
        // Ein Balken auch im beendeten Zustand, damit die Karte nicht in der
        // Höhe springt, sobald der Vorgang durch ist.
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: lauf.beendet ? 1.0 : lauf.anteil,
            minHeight: 6,
            color: lauf.fehler != null ? farben.error : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          satz,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: lauf.fehler != null ? farben.error : farben.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (lauf.laeuft && lauf.datei != null)
          Text(
            lauf.datei!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: farben.outline),
          ),
      ],
    );
  }
}

/// Ein Zahlenfeld der Kopfzeile: Beschriftung links, Wert rechts.
///
/// Zwei davon nebeneinander bilden die Zeile „Aktiv / Wartend" – das
/// auffällige Feld links, das ruhige rechts.
class _Zahlenfeld extends StatelessWidget {
  final String beschriftung;
  final String wert;
  final bool hervorgehoben;
  const _Zahlenfeld({
    required this.beschriftung,
    required this.wert,
    this.hervorgehoben = false,
  });

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    // Die Paare aus dem Farbschema statt eigener Werte: Sie sind auf
    // ausreichenden Kontrast ausgelegt und gelten in beiden Helligkeiten.
    final grund = hervorgehoben ? farben.primaryContainer : farben.surfaceContainerHighest;
    final schrift = hervorgehoben ? farben.onPrimaryContainer : farben.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      decoration: BoxDecoration(color: grund, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(beschriftung,
                overflow: TextOverflow.ellipsis, style: TextStyle(color: schrift)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(wert,
              style: TextStyle(
                color: schrift,
                fontWeight: FontWeight.w600,
                // Damit die Zahlen zweier Karten untereinander fluchten.
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
        ],
      ),
    );
  }
}

/// Die Zahlenzeile einer Karte.
class _Zahlenreihe extends StatelessWidget {
  final String linksBeschriftung;
  final String linksWert;
  final String rechtsBeschriftung;
  final String rechtsWert;
  const _Zahlenreihe({
    required this.linksBeschriftung,
    required this.linksWert,
    required this.rechtsBeschriftung,
    required this.rechtsWert,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Zahlenfeld(
              beschriftung: linksBeschriftung, wert: linksWert, hervorgehoben: true),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _Zahlenfeld(beschriftung: rechtsBeschriftung, wert: rechtsWert),
        ),
      ],
    );
  }
}

/// Ein Knopf der Aktionsleiste.
///
/// Bewusst nicht [_TaskAction]: Die Gesamtanalyse-Karte startet nicht über
/// ein Fortschrittsfenster, sondern über [LibraryState]. Sie müsste sonst
/// eine Aktion mit leerem Strom und leerem Titel erfinden, nur um in die
/// Leiste zu passen.
class _Leistenknopf {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _Leistenknopf({required this.label, required this.icon, this.onTap});
}

/// Die Aktionsleiste rechts an der Karte, über deren volle Höhe.
///
/// Die Knöpfe stehen aussen statt unter dem Text, weil sie dadurch bei allen
/// Karten an derselben Stelle sitzen – gleich, ob die Beschreibung ein oder
/// zwei Zeilen braucht. Man findet „Alle erneut" dann mit den Augen, ohne
/// jede Karte einzeln zu lesen.
class _Aktionsleiste extends StatelessWidget {
  final List<_Leistenknopf> knoepfe;

  /// Falsch, wenn ein Modell oder Datensatz fehlt – die Knöpfe sind dann
  /// abgeschaltet, der Grund steht in der Karte.
  final bool bedienbar;

  const _Aktionsleiste({required this.knoepfe, required this.bedienbar});

  /// Fest, nicht anteilig: Zwei Karten nebeneinander hätten sonst
  /// unterschiedlich breite Leisten, je nach Länge ihrer Beschreibung.
  static const double breite = 112;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Container(
      width: breite,
      color: farben.surfaceContainerHigh,
      child: Column(
        children: [
          for (var i = 0; i < knoepfe.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: farben.outlineVariant),
            Expanded(
              child: InkWell(
                onTap: bedienbar ? knoepfe[i].onTap : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(knoepfe[i].icon,
                          size: 26,
                          color: bedienbar ? farben.onSurface : farben.onSurface.withValues(alpha: 0.38)),
                      const SizedBox(height: 6),
                      Text(
                        knoepfe[i].label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: bedienbar
                              ? farben.onSurfaceVariant
                              : farben.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Der gemeinsame Rahmen aller Aufgabenkarten: links Inhalt, rechts die
/// Aktionsleiste über die volle Höhe.
class _Aufgabenrahmen extends StatelessWidget {
  final IconData icon;
  final String titel;
  final String beschreibung;
  final Widget inhalt;
  final List<_Leistenknopf> knoepfe;
  final bool bedienbar;

  const _Aufgabenrahmen({
    required this.icon,
    required this.titel,
    required this.beschreibung,
    required this.inhalt,
    required this.knoepfe,
    required this.bedienbar,
  });

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      // Ohne das Beschneiden stünde die Leiste rechts über die abgerundeten
      // Ecken der Karte hinaus.
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 20, color: farben.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(titel,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: farben.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(beschreibung,
                        style: TextStyle(fontSize: 13, color: farben.outline)),
                    const SizedBox(height: AppSpacing.md),
                    inhalt,
                  ],
                ),
              ),
            ),
            _Aktionsleiste(knoepfe: knoepfe, bedienbar: bedienbar),
          ],
        ),
      ),
    );
  }
}

/// Eine Aufgaben-Karte: Symbol und Titel, Kurzbeschreibung, die Zahlen
/// „Aktiv" und „Wartend" und rechts die Aktionsleiste.
///
/// „Aktiv" ist keine Zierde: Vier dieser Aufgaben sind zugleich Stufen der
/// Hintergrundanalyse ([stufe]), die weiterläuft, während man durch die App
/// navigiert. Wer diesen Bildschirm während eines Laufs öffnet, sieht dort
/// die tatsächlich verbleibende Zahl der gerade bearbeiteten Stufe. Die
/// übrigen Aufgaben laufen in einem Fortschrittsfenster, das den Bildschirm
/// verdeckt – bei ihnen steht dort zwangsläufig 0, und das ist richtig so.
///
/// [unavailableReason] gesetzt: Leiste abgeschaltet, Grund statt der Zahlen
/// (fehlendes KI-Modell o.ä.) – dieselben Verfügbarkeits-Getter wie in
/// ToolsScreen.
class _TaskCard extends StatefulWidget {
  final LibraryState library;

  /// Kennung des Laufs dieser Karte (siehe [LibraryState.starteAufgabe]).
  /// Fest im Quelltext vergeben statt aus dem Titel abgeleitet: Ein
  /// übersetzter Titel wäre in jeder Sprache eine andere Kennung, und ein
  /// beim Sprachwechsel laufender Vorgang verschwände aus seiner Karte.
  final String schluessel;

  final IconData icon;
  final String title;
  final String description;
  final Future<int> Function() pendingCount;

  /// Ob diese Aufgabe zu den teuren gehört (KI-Modell im Speicher oder
  /// dieselbe Arbeit wie eine Stufe der Hintergrundanalyse). Solche laufen
  /// nur einzeln – siehe [LibraryState.pruefeStart].
  final bool rechenintensiv;

  /// Die Stufe der Hintergrundanalyse, die dieselbe Arbeit erledigt – oder
  /// `null`, wenn diese Aufgabe nur von Hand läuft.
  final Analysestufe? stufe;

  /// null heisst „Wartend" – der übersetzte Vorgabewert kann nicht im Kopf
  /// stehen, dort gibt es noch keinen Kontext.
  final String? pendingLabel;
  final String? unavailableReason;
  final List<_TaskAction> actions;
  const _TaskCard({
    required this.library,
    required this.schluessel,
    required this.icon,
    required this.title,
    required this.description,
    required this.pendingCount,
    this.rechenintensiv = false,
    this.stufe,
    this.pendingLabel,
    this.unavailableReason,
    required this.actions,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  // Nur berechnen, wenn die Karte den Zähler überhaupt anzeigt – bei
  // fehlendem Modell (unavailableReason gesetzt) würde die Abfrage sonst
  // unnötig eine volle Tabellen-Zählung auslösen, ohne dass das Ergebnis je
  // sichtbar wird.
  late Future<int>? _countFuture = widget.unavailableReason == null ? widget.pendingCount() : null;

  /// Ob der Lauf dieser Karte beim letzten Bescheid schon beendet war –
  /// damit der Zähler genau einmal aufgefrischt wird, wenn ein Vorgang
  /// durchläuft, und nicht bei jedem der tausenden Fortschritts-Bescheide.
  bool _warBeendet = true;

  @override
  void initState() {
    super.initState();
    widget.library.addListener(_aufLaufwechsel);
  }

  @override
  void dispose() {
    widget.library.removeListener(_aufLaufwechsel);
    super.dispose();
  }

  void _aufLaufwechsel() {
    final lauf = widget.library.lauf(widget.schluessel);
    final beendet = lauf == null || lauf.beendet;
    if (beendet && !_warBeendet) _refreshCount();
    _warBeendet = beendet;
  }

  void _refreshCount() {
    if (widget.unavailableReason != null) return;
    if (!mounted) return;
    // Die Abfrage VOR setState anstossen und nur die fertige Future
    // hineinreichen: Ein Pfeilrumpf gäbe hier das `Future` der Zuweisung
    // zurück, und setState verbietet einen Rückgabewert dieser Art
    // ausdrücklich (Zusicherung im Framework).
    final naechste = widget.pendingCount();
    setState(() {
      _countFuture = naechste;
    });
  }

  void _runAction(_TaskAction action) {
    final abweisung = widget.library
        .pruefeStart(widget.schluessel, rechenintensiv: widget.rechenintensiv);
    if (abweisung != null) {
      melde.warnung(abweisungstext(AppTexte.of(context), abweisung));
      return;
    }
    // Kein `await`: Der Lauf soll weiterlaufen, wenn dieser Bildschirm
    // längst weg ist. Der Fortschritt kommt über LibraryState zurück.
    unawaited(widget.library.starteAufgabe(
      schluessel: widget.schluessel,
      titel: action.laufTitel,
      leermeldung: action.emptyMessage,
      strom: action.stream,
      rechenintensiv: widget.rechenintensiv,
    ));
  }

  /// Wie viele Fotos die Hintergrundanalyse in dieser Stufe gerade noch vor
  /// sich hat – `0`, wenn sie nicht läuft oder woanders steht.
  int _aktiv() {
    final analyse = widget.library.analyse;
    if (analyse == null || analyse.stufe != widget.stufe) return 0;
    final offen = analyse.gesamt - analyse.erledigt;
    return offen < 0 ? 0 : offen;
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.unavailableReason;
    // Auf LibraryState hören, damit „Aktiv" mitläuft, während die
    // Hintergrundanalyse arbeitet – und damit der eigene Lauf dieser Karte
    // seinen Fortschritt hierher meldet.
    return ListenableBuilder(
      listenable: widget.library,
      builder: (context, _) {
        final t = AppTexte.of(context);
        final lauf = widget.library.lauf(widget.schluessel);

        // Während ein Lauf offen ist, tritt die Aktionsleiste hinter einen
        // einzigen Knopf zurück: Abbrechen, solange er arbeitet, danach
        // Schliessen. Vier Aktionen anzubieten, von denen keine etwas tut,
        // wäre die schlechtere Antwort als eine, die zum Zustand passt.
        final List<_Leistenknopf> knoepfe;
        if (lauf == null) {
          knoepfe = [
            for (final aktion in widget.actions)
              _Leistenknopf(
                label: aktion.label,
                icon: aktion.icon,
                onTap: () => _runAction(aktion),
              ),
          ];
        } else if (lauf.laeuft) {
          knoepfe = [
            _Leistenknopf(
              label: t.allgAbbrechen,
              icon: Icons.stop_circle_outlined,
              onTap: () => widget.library.brichAufgabeAb(widget.schluessel),
            ),
          ];
        } else {
          knoepfe = [
            _Leistenknopf(
              label: t.allgSchliessen,
              icon: Icons.check,
              onTap: () {
                widget.library.verwerfeLauf(widget.schluessel);
                _refreshCount();
              },
            ),
          ];
        }

        return _Aufgabenrahmen(
          icon: widget.icon,
          titel: widget.title,
          beschreibung: widget.description,
          knoepfe: knoepfe,
          bedienbar: reason == null,
          inhalt: reason != null
              ? Text(reason, style: TextStyle(fontSize: 12, color: context.semantik.warnung))
              : lauf != null
                  ? _Laufanzeige(lauf: lauf)
                  : FutureBuilder<int>(
                      future: _countFuture,
                      builder: (context, snapshot) => _Zahlenreihe(
                        linksBeschriftung: t.aufgAktiv,
                        linksWert: '${_aktiv()}',
                        rechtsBeschriftung: widget.pendingLabel ?? t.aufgWartend,
                        rechtsWert: snapshot.hasData ? '${snapshot.data}' : '…',
                      ),
                    ),
        );
      },
    );
  }
}

/// Sonderkarte für [LibraryState.starteHintergrundanalyse]: läuft (anders als
/// die übrigen Aufgaben hier) bereits echt im Hintergrund weiter, während man
/// navigiert – deshalb zeigt sie neben der Zahl der aktiven Fotos die gerade
/// bearbeitete Stufe im Klartext, gespeist aus
/// [LibraryState.analyse]/[LibraryState.analyseLaeuft] über ListenableBuilder
/// (LibraryState ist ein ChangeNotifier).
class _CombinedAnalysisCard extends StatelessWidget {
  final LibraryState library;
  const _CombinedAnalysisCard({required this.library});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: library,
      builder: (context, _) {
        final t = AppTexte.of(context);
        final analyse = library.analyse;
        final laeuft = library.analyseLaeuft;
        final offen = analyse == null ? 0 : (analyse.gesamt - analyse.erledigt).clamp(0, 1 << 31);

        return _Aufgabenrahmen(
          icon: Icons.auto_awesome_outlined,
          titel: t.werkzAllesNachholenTitel,
          beschreibung: t.werkzAllesNachholenText,
          // Anders als bei den übrigen Karten bleibt die Leiste bedienbar,
          // während gearbeitet wird – sonst gäbe es keinen Weg, einen Lauf
          // über 8000 Fotos wieder anzuhalten, ausser die App zu beenden.
          bedienbar: true,
          knoepfe: [
            if (laeuft)
              _Leistenknopf(
                label: t.allgAbbrechen,
                icon: Icons.stop_circle_outlined,
                onTap: library.brichHintergrundanalyseAb,
              )
            else
              _Leistenknopf(
                label: t.aufgJetztStarten,
                icon: Icons.play_arrow,
                onTap: () {
                  library.starteHintergrundanalyse();
                  melde.hinweis(t.aufgLaeuft);
                },
              ),
          ],
          inhalt: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Zahlenreihe(
                linksBeschriftung: t.aufgAktiv,
                linksWert: '$offen',
                rechtsBeschriftung: t.aufgStatus,
                rechtsWert: laeuft && analyse != null
                    ? t.aufgStufeKurz(analyse.stufeNummer, analyse.stufenGesamt)
                    : t.aufgBereit,
              ),
              if (laeuft && analyse != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.aufgStufe(analysestufeName(t, analyse.stufe), analyse.erledigt,
                      analyse.gesamt, analyse.stufeNummer, analyse.stufenGesamt),
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Übersicht aller Hintergrund-/Backfill-Aufgaben im Stil von Immichs
/// Admin-Seite "Auftrags-Schlangen": pro Aufgabe eine Karte mit Kurzbe-
/// schreibung, Anzahl noch offener Fotos und Start-Knöpfen. Rein additiv zu
/// ToolsScreen (Werkzeuge) gedacht – ruft exakt dieselben LibraryState-Streams
/// auf, ersetzt Werkzeuge aber nicht (viele Stellen in der App verweisen
/// wörtlich dorthin).
class BackgroundTasksScreen extends StatelessWidget {
  final LibraryState library;
  const BackgroundTasksScreen({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.einstAbschnittHintergrund)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _CombinedAnalysisCard(library: library),
          const SizedBox(height: AppSpacing.md),
          _TaskCard(
            library: library,
            schluessel: 'gesichter',
            rechenintensiv: true,
            // Dieselbe Stufe wie Unschärfe und Einbettung: Der gemeinsame
            // Durchgang der Analyse dekodiert jedes Foto einmal und erledigt
            // alle drei daran. Ohne diese Angabe stand hier „Aktiv 0",
            // während die Analyse sichtbar genau diese Arbeit tat.
            stufe: Analysestufe.bildanalyse,
            icon: Icons.face_retouching_natural,
            title: t.werkzGesichterScannenTitel,
            description: t.aufgGesichterText,
            pendingCount: () => library.db.countFaceScan(onlyNew: true),
            unavailableReason: _modelHint(
                t, library.faceDetectionAvailable, t.aufgYunetModell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgNeueFotos,
                icon: Icons.search,
                laufTitel: t.werkzScanneNeue,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.rescanFaces(onlyNewPhotos: true),
              ),
              _TaskAction(
                label: t.aufgAlleErneut,
                icon: Icons.all_inclusive,
                laufTitel: t.werkzScanneAlle,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.rescanFaces(onlyNewPhotos: false),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'vorschau',
            icon: Icons.photo_size_select_actual_outlined,
            title: t.werkzAbschnittVorschau,
            description: t.aufgVorschauText,
            pendingCount: () => library.db.countThumbnailRegen(onlyMissing: true),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.search,
                laufTitel: t.werkzErstelleFehlende,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.regenerateThumbnails(onlyMissing: true),
              ),
              _TaskAction(
                label: t.aufgAlleNeu,
                icon: Icons.all_inclusive,
                laufTitel: t.werkzErstelleAlle,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.regenerateThumbnails(onlyMissing: false),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'ocr',
            rechenintensiv: true,
            icon: Icons.text_fields,
            title: t.aufgOcrTitel,
            stufe: Analysestufe.texterkennung,
            description: t.aufgOcrText,
            pendingCount: () => library.db.countOcrBackfill(),
            // Auf macOS immer verfügbar (Vision-Framework), sonst erst mit
            // den beiden nachgeladenen Modellen.
            unavailableReason:
                _modelHint(t, library.ocrAvailable, t.aufgOcrModell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzErkenneText,
                emptyMessage: t.werkzAlleTextDurchsucht,
                stream: () => library.backfillOcrText(),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'beschreibungen',
            rechenintensiv: true,
            icon: Icons.subtitles_outlined,
            title: t.aufgBeschreibungenTitel,
            stufe: Analysestufe.bildbeschreibung,
            description: t.aufgBeschreibungenText,
            pendingCount: () => library.db.countCaptionBackfill(),
            unavailableReason: _modelHint(
                t, library.captioningAvailable, t.aufgBeschreibungsmodell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzErzeugeBeschreibungen,
                emptyMessage: t.werkzAlleHabenBeschreibung,
                stream: () => library.backfillCaptions(),
              ),
              // Nach dem Modellwechsel der eigentlich sinnvolle Weg: Die
              // vorhandenen Sätze stammen vom abgelösten Modell.
              _TaskAction(
                label: t.werkzAlleFotos,
                icon: Icons.all_inclusive,
                laufTitel: t.werkzErzeugeBeschreibungen,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.backfillCaptions(alle: true),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'beschreibungen_de',
            rechenintensiv: true,
            icon: Icons.translate,
            title: t.aufgUebersetzenTitel,
            description: t.aufgUebersetzenText,
            pendingCount: () => library.db.countCaptionTranslation(),
            unavailableReason: _modelHint(t, library.uebersetzungEnDeAvailable,
                t.aufgUebersetzungsmodell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzUebersetzeBeschreibungen,
                emptyMessage: t.werkzAlleUebersetzt,
                stream: () => library.uebersetzeBildbeschreibungen(),
              ),
              // Nach einem Wechsel des Übersetzungsmodells der sinnvolle Weg.
              _TaskAction(
                label: t.werkzAlleFotos,
                icon: Icons.all_inclusive,
                laufTitel: t.werkzUebersetzeBeschreibungen,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.uebersetzeBildbeschreibungen(alle: true),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'embeddings',
            rechenintensiv: true,
            icon: Icons.scatter_plot_outlined,
            title: t.aufgEmbeddingsTitel,
            stufe: Analysestufe.bildanalyse,
            description: t.aufgEmbeddingsText,
            pendingCount: () => library.db.countEmbeddingBackfill(),
            unavailableReason:
                _modelHint(t, library.clipAvailable, t.aufgClipModell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzBerechneEmbeddings,
                emptyMessage: t.werkzAlleHabenEmbedding,
                stream: () => library.backfillClipEmbeddings(),
              ),
              // Nach der Umstellung der Bildvorverarbeitung der eigentlich
              // sinnvolle Weg: Die gespeicherten Vektoren stammen noch vom
              // gestauchten Bild. Fehlte hier, während die Bildbeschreibung
              // ihn längst hatte – „Starten" rechnete dann nur das eine
              // fehlende Foto und sah nach getaner Arbeit aus.
              _TaskAction(
                label: t.werkzAlleFotos,
                icon: Icons.all_inclusive,
                laufTitel: t.werkzBerechneEmbeddings,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.backfillClipEmbeddings(alle: true),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'kitags',
            rechenintensiv: true,
            icon: Icons.sell_outlined,
            title: t.aufgKiTagsTitel,
            stufe: Analysestufe.schlagwoerter,
            description: t.aufgKiTagsText,
            pendingCount: () => library.db.countAiTagging(onlyUntagged: true),
            unavailableReason:
                _modelHint(t, library.clipAvailable, t.aufgClipModell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgUngetaggte,
                icon: Icons.search,
                laufTitel: t.werkzBerechneKiTags,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.backfillAiTags(onlyUntagged: true),
              ),
              _TaskAction(
                label: t.werkzAlleFotos,
                icon: Icons.all_inclusive,
                laufTitel: t.werkzBerechneKiTags,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.backfillAiTags(onlyUntagged: false),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'unschaerfe',
            rechenintensiv: true,
            // Teil des gemeinsamen Durchgangs, siehe Gesichter.
            stufe: Analysestufe.bildanalyse,
            icon: Icons.blur_on,
            title: t.aufgUnschaerfeTitel,
            description: t.aufgUnschaerfeText,
            pendingCount: () => library.db.countBlurBackfill(),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzBerechneUnschaerfe,
                emptyMessage: t.werkzAlleHabenUnschaerfe,
                stream: () => library.backfillBlurScores(),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'orte',
            icon: Icons.place_outlined,
            title: t.aufgOrteTitel,
            description: t.aufgOrteText,
            pendingCount: () => library.db.countLocationBackfill(),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzLeseOrte,
                emptyMessage: t.werkzAlleHabenOrt,
                stream: () => library.backfillLocations(),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'ortsnamen',
            icon: Icons.map_outlined,
            title: t.werkzOrteAufloesenTitel,
            description: t.aufgOrteAufloesenText,
            pendingCount: () => library.db.countLocationNameBackfill(),
            unavailableReason: _modelHint(
                t, library.geoDataAvailable, t.aufgGeoDatensatz, t.aufgWoStandortdaten),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzLoeseOrteAuf,
                emptyMessage: t.werkzAlleAufgeloest,
                stream: () => library.backfillLocationNames(),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'kameradaten',
            icon: Icons.photo_camera_outlined,
            title: t.aufgKameraTitel,
            description: t.aufgKameraText,
            pendingCount: () => library.db.countCameraMetadataBackfill(),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzLeseKameradaten,
                emptyMessage: t.werkzAlleHabenKameradaten,
                stream: () => library.backfillCameraMetadata(),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'livephotos',
            icon: Icons.motion_photos_on_outlined,
            title: t.aufgLivePhotoTitel,
            description: t.aufgLivePhotoText,
            pendingCount: () => library.db.countUnlinkedAssetsOfType('IMAGE'),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.play_arrow,
                laufTitel: t.werkzPruefeLivePhotos,
                emptyMessage: t.werkzKeineUnverknuepften,
                stream: () => library.relinkLivePhotos(),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'rendern',
            icon: Icons.tune,
            title: t.werkzNeuRendernTitel,
            description: t.aufgRendernText,
            pendingLabel: t.aufgBetrifft,
            pendingCount: () => library.db.countAssetsWithDevelopSettings(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                laufTitel: t.werkzRendereNeu,
                emptyMessage: t.werkzKeineEntwickelten,
                stream: () => library.redevelopAll(),
              ),
            ],
          ),
          _TaskCard(
            library: library,
            schluessel: 'xmp',
            icon: Icons.description_outlined,
            title: t.werkzXmpSchreibenTitel,
            description: t.aufgXmpText,
            pendingLabel: t.aufgBetrifft,
            pendingCount: () => library.db.countXmpExport(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                laufTitel: t.werkzSchreibeXmp,
                emptyMessage: t.werkzKeineFotosGesperrt,
                stream: () => library.writeXmpSidecars(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
