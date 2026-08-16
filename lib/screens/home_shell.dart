import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import 'albums_screen.dart';
import 'calendar_screen.dart';
import 'explore_screen.dart';
import 'import_progress_sheet.dart';
import 'map_screen.dart';
import 'people_screen.dart';
import 'restore_queue_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'timeline_screen.dart';
import 'tools_screen.dart';

/// Dauerhafter, kleiner Hinweis auf laufende/wartende KI-Restaurierungs-
/// Aufträge (siehe RestoreQueueService) – bleibt sichtbar, während der
/// Nutzer zwischen den Hauptbereichen wechselt, da es (anders als eine
/// SnackBar auf einem einzelnen Screen) Teil der dauerhaften App-Hülle ist.
/// Tippen öffnet die vollständige Warteschlange ([RestoreQueueScreen]).
/// Unsichtbar (`SizedBox.shrink`), solange kein Auftrag wartet/läuft.
class _RestoreQueueBanner extends StatelessWidget {
  final LibraryState library;
  const _RestoreQueueBanner({required this.library});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RestoreJobData>>(
      stream: library.db.watchRestoreJobs(),
      builder: (context, snapshot) {
        final jobs = snapshot.data ?? const <RestoreJobData>[];
        final running = jobs.where((j) => j.status == 'running').firstOrNull;
        final queuedCount = jobs.where((j) => j.status == 'queued').length;
        if (running == null && queuedCount == 0) return const SizedBox.shrink();

        final text = switch ((running, queuedCount)) {
          (final r?, 0) when r.tilesTotal > 0 =>
            'KI-Restaurierung läuft – Kachel ${r.tilesDone}/${r.tilesTotal}',
          (final r?, final q) when r.tilesTotal > 0 =>
            'KI-Restaurierung läuft – Kachel ${r.tilesDone}/${r.tilesTotal} · $q in Warteschlange',
          (null, final q) =>
            '$q Foto(s) in der Warteschlange für KI-Restaurierung',
          _ => 'KI-Restaurierung wird vorbereitet …',
        };

        return Material(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RestoreQueueScreen(library: library),
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(text,
                          style: Theme.of(context).textTheme.bodySmall)),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Zeigt an, dass die rechenintensiven KI-Auswertungen nach einem Import
/// im Hintergrund nachlaufen (siehe LibraryState.starteHintergrundanalyse).
/// Unsichtbar, solange nichts läuft. Tippen bricht ab.
class _AnalyseBanner extends StatelessWidget {
  final LibraryState library;
  const _AnalyseBanner({required this.library});

  @override
  Widget build(BuildContext context) {
    final a = library.analyse;
    if (a == null) return const SizedBox.shrink();

    final anteil = a.gesamt > 0 ? a.erledigt / a.gesamt : null;
    // Nur der Knopf bricht ab, nicht das ganze Banner: Ein Tipp auf den
    // Fortschrittstext beendete sonst einen stundenlangen Lauf (Audit-Fund).
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.only(
            left: AppSpacing.lg, right: AppSpacing.sm, top: AppSpacing.sm, bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, value: anteil),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '${a.stufe} wird berechnet '
                '(Schritt ${a.stufeNummer} von ${a.stufenGesamt}'
                '${a.gesamt > 0 ? ", ${a.erledigt}/${a.gesamt}" : ""})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: library.brichHintergrundanalyseAb,
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon für einen Navigationseintrag mit Hover-"Pop"-Effekt (leichtes
/// Aufskalieren + Tooltip mit dem Namen) für Maus-Nutzer auf dem Desktop –
/// relevant, weil bei `labelType: NavigationRailLabelType.selected` nicht
/// ausgewählte Einträge sonst nur als reines Icon ohne Beschriftung
/// erscheinen.
class _HoverNavIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final double size;
  const _HoverNavIcon(
      {required this.icon, required this.label, this.size = 24});

  @override
  State<_HoverNavIcon> createState() => _HoverNavIconState();
}

class _HoverNavIconState extends State<_HoverNavIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Tooltip(
        message: widget.label,
        waitDuration: const Duration(milliseconds: 300),
        child: AnimatedScale(
          scale: _hovering ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Icon(widget.icon, size: widget.size),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  final LibraryState library;
  const HomeShell({super.key, required this.library});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // labelType.selected zeigt den Namen nur beim ausgewählten Eintrag an
  // (siehe Kommentar unten) – beim Hovern über einen NICHT ausgewählten
  // Eintrag mit der Maus soll er trotzdem kurz sichtbar werden, kombiniert
  // mit einem leichten Pop/Scale-Effekt (siehe _HoverNavIcon).
  //
  // [iconSize]/[itemPadding] skalieren mit der Fensterhöhe (siehe
  // [_railScale] in build()) – ohne das stehen die 9 Einträge bei einem
  // hohen Fenster winzig oben zusammengedrängt, mit viel ungenutztem Platz
  // darunter bis zum Import-Button.
  List<NavigationRailDestination> _buildDestinations(
      double iconSize, double itemPadding) {
    NavigationRailDestination dest(
        IconData outlined, IconData filled, String label) {
      return NavigationRailDestination(
        icon: _HoverNavIcon(icon: outlined, label: label, size: iconSize),
        selectedIcon: _HoverNavIcon(icon: filled, label: label, size: iconSize),
        label: Text(label),
        padding: EdgeInsets.symmetric(vertical: itemPadding),
      );
    }

    return [
      for (var i = 0; i < _destinationLabels.length; i++)
        dest(_destinationIconsOutlined[i], _destinationIconsFilled[i],
            _destinationLabels[i]),
    ];
  }

  /// Reihenfolge = Tab-Index = ⌘1…⌘9 (siehe [_handleKeyEvent]) = Reihenfolge
  /// der [NavigationBar]-Ziele unten – eine einzige Quelle der Wahrheit statt
  /// dreier parallel gepflegter Listen.
  static const _destinationLabels = [
    'Timeline',
    'Erkunden',
    'Kalender',
    'Karte',
    'Suche',
    'Personen',
    'Alben',
    'Werkzeuge',
    'Einstellungen',
  ];
  static const _destinationIconsOutlined = [
    Icons.photo_outlined,
    Icons.explore_outlined,
    Icons.calendar_today_outlined,
    Icons.map_outlined,
    Icons.search_outlined,
    Icons.face_outlined,
    Icons.photo_album_outlined,
    Icons.build_outlined,
    Icons.settings_outlined,
  ];
  static const _destinationIconsFilled = [
    Icons.photo,
    Icons.explore,
    Icons.calendar_today,
    Icons.map,
    Icons.search,
    Icons.face,
    Icons.photo_album,
    Icons.build,
    Icons.settings,
  ];

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (HardwareKeyboard.instance.isMetaPressed) {
      final digitKeys = {
        LogicalKeyboardKey.digit1: 0,
        LogicalKeyboardKey.digit2: 1,
        LogicalKeyboardKey.digit3: 2,
        LogicalKeyboardKey.digit4: 3,
        LogicalKeyboardKey.digit5: 4,
        LogicalKeyboardKey.digit6: 5,
        LogicalKeyboardKey.digit7: 6,
        LogicalKeyboardKey.digit8: 7,
        LogicalKeyboardKey.digit9: 8,
      };
      final target = digitKeys[event.logicalKey];
      if (target != null) {
        setState(() => _index = target);
        return KeyEventResult.handled;
      }
    }
    // event.character statt LogicalKeyboardKey.slash, damit es unabhängig
    // vom Tastaturlayout funktioniert ("?" liegt auf deutschen Tastaturen
    // z.B. auf Umschalt+ß, nicht auf Umschalt+/ wie im US-Layout).
    if (event.character == '?') {
      _showShortcutsOverview();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _showShortcutsOverview() {
    showDialog<void>(
        context: context,
        builder: (context) => const _ShortcutsOverviewDialog());
  }

  @override
  Widget build(BuildContext context) {
    // "Foto in der Timeline anzeigen" (Kontextmenü der Vollbildansicht):
    // einmalig auf den Timeline-Tab wechseln und die Ziel-ID durchreichen,
    // noch bevor `pages` unten gebaut wird. Direktes Setzen von `_index`
    // statt setState() genügt hier, da wir uns bereits mitten in build()
    // befinden und der neue Wert unten sofort verwendet wird.
    final pendingHighlight = widget.library.timelineHighlightAssetId;
    if (pendingHighlight != null) {
      _index = 0;
      widget.library.clearTimelineHighlightRequest();
    }

    final pages = [
      TimelineScreen(
          library: widget.library, highlightAssetId: pendingHighlight),
      ExploreScreen(library: widget.library),
      CalendarScreen(library: widget.library),
      MapScreen(library: widget.library),
      SearchScreen(library: widget.library),
      PeopleScreen(library: widget.library),
      AlbumsScreen(library: widget.library),
      ToolsScreen(library: widget.library),
      SettingsScreen(library: widget.library),
    ];

    final wide = MediaQuery.of(context).size.width >= 700;

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Column(
          children: [
            _RestoreQueueBanner(library: widget.library),
            _AnalyseBanner(library: widget.library),
            Expanded(child: LayoutBuilder(
              builder: (context, constraints) {
                // Skaliert Icon-Größe und Abstand zwischen den 9 Einträgen mit der
                // verfügbaren Fensterhöhe: bei einem hohen Fenster/Bildschirm
                // stünden sie sonst winzig oben gedrängt, mit viel ungenutztem
                // Platz darunter bis zum Import-Button. 700px ist die Bezugshöhe,
                // ab der die Rail genau wie zuvor (Icon-Größe 24, kein Extra-
                // Abstand) aussieht; die Obergrenze verhindert unangemessen große
                // Icons auf sehr hohen Bildschirmen.
                final railScale = (constraints.maxHeight / 700).clamp(1.0, 1.8);
                final railIconSize = 24.0 * railScale;
                final railItemPadding = 10.0 * (railScale - 1.0);

                return Row(
                  children: [
                    if (wide)
                      NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: (i) =>
                            setState(() => _index = i),
                        // "selected" statt "all": bei 9 Einträgen würde die Rail mit
                        // Label unter jedem Icon bei normaler Fensterhöhe überlaufen.
                        labelType: NavigationRailLabelType.selected,
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image(
                                image: const AssetImage('assets/icon/app_icon.png'),
                                width: 32 * railScale,
                                height: 32 * railScale,
                              ),
                              // Name der geöffneten Bibliothek – erst, wenn es
                              // überhaupt mehr als eine gibt. Ohne diesen
                              // Hinweis ist nach einem Wechsel nicht
                              // erkennbar, worin man gerade arbeitet.
                              if (widget.library.aktiveBibliothek != null) ...[
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 72,
                                  child: Tooltip(
                                    message:
                                        'Geöffnete Bibliothek: ${widget.library.aktiveBibliothek}',
                                    child: Text(
                                      widget.library.aktiveBibliothek!,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        destinations:
                            _buildDestinations(railIconSize, railItemPadding),
                        trailing: Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: FloatingActionButton(
                                heroTag: 'import-rail',
                                tooltip: 'Fotos/Videos importieren',
                                onPressed: () =>
                                    showImportSheet(context, widget.library),
                                child: const Icon(
                                    Icons.add_photo_alternate_outlined),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (wide) const VerticalDivider(width: 1),
                    Expanded(child: pages[_index]),
                  ],
                );
              },
            )),
          ],
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: [
                  for (var i = 0; i < _destinationLabels.length; i++)
                    NavigationDestination(
                      icon: Icon(_destinationIconsOutlined[i]),
                      selectedIcon: Icon(_destinationIconsFilled[i]),
                      // "Mehr" statt "Einstellungen" nur unten in der schmalen
                      // NavigationBar, damit der letzte Eintrag nicht wie eine
                      // reine Einstellungen-Seite wirkt, obwohl er (wie auf der
                      // breiten Rail) alles rund um App-Konfiguration bündelt.
                      label: i == _destinationLabels.length - 1
                          ? 'Mehr'
                          : _destinationLabels[i],
                    ),
                ],
              ),
        floatingActionButton: wide
            ? null
            : FloatingActionButton(
                heroTag: 'import-bottom',
                onPressed: () => showImportSheet(context, widget.library),
                child: const Icon(Icons.add_photo_alternate_outlined),
              ),
      ),
    );
  }
}

/// Zentrale Übersicht aller Tastaturkürzel der App, über "?" erreichbar
/// (siehe [_HomeShellState._handleKeyEvent]) – bislang mussten Nutzer die
/// Kürzel aus dem Quellcode kennen oder erraten; die Sichtungs-Modus-
/// Hinweiszeile in der Vollbildansicht erklärte bisher nur ihre eigenen drei
/// Kürzel, nicht die allgemeinen.
class _ShortcutsOverviewDialog extends StatelessWidget {
  const _ShortcutsOverviewDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tastaturkürzel'),
      content: const SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShortcutSection(title: 'Navigation', shortcuts: [
                ('⌘1 – ⌘9', 'Zwischen den Hauptbereichen wechseln'),
                ('?', 'Diese Übersicht öffnen'),
              ]),
              SizedBox(height: 16),
              _ShortcutSection(title: 'Vollbildansicht', shortcuts: [
                ('← / →', 'Vorheriges / nächstes Foto'),
                ('Leertaste', 'Nächstes Foto'),
                ('0 – 5', 'Sternebewertung setzen'),
                ('F', 'Favorit umschalten'),
                (
                  '⌫ / Delete',
                  'In den Papierkorb verschieben (mit Bestätigung)'
                ),
                ('Esc', 'Schließen'),
              ]),
              SizedBox(height: 16),
              _ShortcutSection(title: 'Sichtungs-Modus (Culling)', shortcuts: [
                ('⌫ / Delete', 'Sofort ablehnen und weiter (ohne Bestätigung)'),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen')),
      ],
    );
  }
}

class _ShortcutSection extends StatelessWidget {
  final String title;
  final List<(String, String)> shortcuts;
  const _ShortcutSection({required this.title, required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final (key, description) in shortcuts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    key,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                    child: Text(description,
                        style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
