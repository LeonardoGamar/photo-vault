import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/stammbaum.dart';
import '../services/storage_paths.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/person_picker_dialog.dart';
import 'person_detail_screen.dart';

/// Breite und Höhe einer Personenkarte. Fest, weil die Verbindungslinien
/// aus diesen beiden Zahlen und der Anzahl der Karten berechnet werden –
/// mit von der Schriftlänge abhängigen Breiten wüsste der Zeichner nicht,
/// wo eine Karte endet.
const double _karteBreite = 132;
const double _karteHoehe = 148;
const double _karteAbstand = AppSpacing.lg;

/// Höhe der Fläche zwischen zwei Generationen.
const double _verbinderHoehe = 44;

/// Der Stammbaum um eine Person herum.
///
/// Gezeigt wird immer nur die unmittelbare Verwandtschaft: Eltern darüber,
/// Kinder darunter, Geschwister und Partner daneben. Großeltern und Enkel
/// fehlen mit Absicht – für sie ließe sich in einer gemeinsamen Reihe keine
/// Linie zeichnen, die stimmt (welcher Großelternteil zu welchem Elternteil
/// gehört, ginge verloren). Sie sind einen Klick entfernt: Wer auf eine
/// Karte tippt, rückt sie in die Mitte. Ein kleines Zeichen an der Karte
/// sagt vorher, ob dort etwas wartet.
class StammbaumScreen extends StatefulWidget {
  final LibraryState library;
  final String startPersonId;

  const StammbaumScreen({
    super.key,
    required this.library,
    required this.startPersonId,
  });

  @override
  State<StammbaumScreen> createState() => _StammbaumScreenState();
}

class _StammbaumScreenState extends State<StammbaumScreen> {
  late String _fokusId = widget.startPersonId;

  List<PersonData> _personen = [];
  Map<String, PersonData> _nachId = {};
  Verwandtschaftsnetz _netz = Verwandtschaftsnetz(const []);
  bool _laedt = true;

  /// Der Weg, den man sich durch den Baum genommen hat – damit der
  /// Zurück-Pfeil in den vorigen Ausschnitt führt und nicht gleich aus dem
  /// Stammbaum heraus.
  final List<String> _pfad = [];

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    final personen = widget.library.db.nachAlterSortiert(
        await widget.library.db.select(widget.library.db.people).get());
    final zeilen = await widget.library.db.alleBeziehungen();
    if (!mounted) return;
    setState(() {
      _personen = personen;
      _nachId = {for (final p in personen) p.id: p};
      _netz = Verwandtschaftsnetz([
        for (final z in zeilen)
          if (artAusText(z.art) case final art?) kante(z.personId, z.andereId, art),
      ]);
      _laedt = false;
    });
  }

  void _ruecke(String id) {
    if (id == _fokusId) return;
    setState(() {
      _pfad.add(_fokusId);
      _fokusId = id;
    });
  }

  bool _zurueck() {
    if (_pfad.isEmpty) return false;
    setState(() => _fokusId = _pfad.removeLast());
    return true;
  }

  /// Fragt nach einer Person und trägt sie als [art] ein.
  ///
  /// [umgekehrt] dreht die Richtung: Ein Kind ist keine eigene Art, sondern
  /// dieselbe Elternkante von der anderen Seite gelesen. Ohne diesen
  /// Schalter bräuchte es eine zweite Art, die dasselbe bedeutet – und
  /// zwei Schreibweisen für einen Sachverhalt laufen früher oder später
  /// auseinander.
  Future<void> _hinzufuegen(Verwandtschaft art, {bool umgekehrt = false}) async {
    final t = AppTexte.of(context);
    final titel = switch ((art, umgekehrt)) {
      (Verwandtschaft.elternteil, false) => t.stammbaumElternteilHinzufuegen,
      (Verwandtschaft.elternteil, true) => t.stammbaumKindHinzufuegen,
      (Verwandtschaft.partner, _) => t.stammbaumPartnerHinzufuegen,
    };
    final wahl = await showPersonPickerDialog(
      context,
      // Die Person in der Mitte steht nicht zur Auswahl – mit sich selbst
      // verwandt zu sein wäre der einzige Fehler, den dieser Dialog
      // überhaupt anbieten könnte.
      _personen.where((p) => p.id != _fokusId).toList(),
      paths: widget.library.paths,
      title: titel,
    );
    if (wahl == null || !mounted) return;

    String andereId;
    if (wahl.newName != null) {
      andereId = const Uuid().v4();
      await widget.library.db.createPerson(
        PeopleCompanion.insert(id: andereId, name: wahl.newName!),
      );
    } else {
      andereId = wahl.existingPersonId!;
    }

    final fehler = umgekehrt
        ? await widget.library.db.fuegeBeziehungHinzu(andereId, _fokusId, art)
        : await widget.library.db.fuegeBeziehungHinzu(_fokusId, andereId, art);
    await _laden();
    if (fehler != null && mounted) _meldeFehler(fehler);
  }

  void _meldeFehler(Beziehungsfehler fehler) {
    final t = AppTexte.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (fehler) {
        Beziehungsfehler.mitSichSelbst => t.stammbaumFehlerSelbst,
        Beziehungsfehler.kreis => t.stammbaumFehlerKreis,
        Beziehungsfehler.schonVorhanden => t.stammbaumFehlerVorhanden,
      }),
    ));
  }

  /// Das Menü einer Karte. [art] und [umgekehrt] beschreiben, wie die
  /// Person zur Mitte steht – nur dann lässt sich die Verbindung wieder
  /// lösen. Bei Geschwistern ist beides null: Sie hängen nicht an einer
  /// eigenen Kante, sondern an den gemeinsamen Eltern.
  Future<void> _karteMenue(
    Offset position,
    PersonData person, {
    Verwandtschaft? art,
    bool umgekehrt = false,
  }) async {
    final t = AppTexte.of(context);
    final wo = Overlay.of(context).context.findRenderObject() as RenderBox;
    final wahl = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(position & Size.zero, Offset.zero & wo.size),
      items: [
        if (person.id != _fokusId)
          PopupMenuItem(
            value: 'mitte',
            child: _zeile(Icons.center_focus_strong_outlined, t.stammbaumInDieMitte),
          ),
        PopupMenuItem(
          value: 'lebensdaten',
          child: _zeile(Icons.event_outlined, t.stammbaumLebensdaten),
        ),
        PopupMenuItem(
          value: 'fotos',
          child: _zeile(Icons.photo_library_outlined, t.stammbaumFotosZeigen),
        ),
        if (art != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'loesen',
            child: _zeile(Icons.link_off, t.stammbaumVerbindungEntfernen),
          ),
        ],
      ],
    );
    if (!mounted || wahl == null) return;
    switch (wahl) {
      case 'mitte':
        _ruecke(person.id);
      case 'lebensdaten':
        await _lebensdatenBearbeiten(person);
      case 'fotos':
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PersonDetailScreen(library: widget.library, person: person),
        ));
        await _laden();
      case 'loesen':
        await _verbindungLoesen(person, art!, umgekehrt);
    }
  }

  Future<void> _verbindungLoesen(
      PersonData person, Verwandtschaft art, bool umgekehrt) async {
    final t = AppTexte.of(context);
    final ja = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.stammbaumVerbindungEntfernen),
        content: Text(t.stammbaumVerbindungEntfernenFrage(
            person.name, _nachId[_fokusId]?.name ?? '')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(t.allgAbbrechen)),
          FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(t.allgEntfernen)),
        ],
      ),
    );
    if (ja != true) return;
    if (umgekehrt) {
      await widget.library.db.entferneBeziehung(person.id, _fokusId, art);
    } else {
      await widget.library.db.entferneBeziehung(_fokusId, person.id, art);
    }
    await _laden();
  }

  Future<void> _lebensdatenBearbeiten(PersonData person) async {
    final ergebnis = await showDialog<({DateTime? geburt, DateTime? tod})>(
      context: context,
      builder: (_) => _LebensdatenDialog(person: person),
    );
    if (ergebnis == null) return;
    await widget.library.db.setzeLebensdaten(person.id,
        geburt: ergebnis.geburt, tod: ergebnis.tod);
    await _laden();
  }

  Widget _zeile(IconData icon, String text) => Row(children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Flexible(child: Text(text)),
      ]);

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final fokus = _nachId[_fokusId];
    return PopScope(
      // Der Zurück-Pfeil folgt erst dem eigenen Weg durch den Baum und
      // verlässt den Bildschirm erst, wenn keiner mehr übrig ist.
      canPop: _pfad.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _zurueck();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(fokus == null ? t.stammbaumTitel : t.stammbaumTitelVon(fokus.name)),
          actions: [
            IconButton(
              tooltip: t.stammbaumElternteilHinzufuegen,
              icon: const Icon(Icons.person_add_alt),
              onPressed: fokus == null ? null : () => _hinzufuegen(Verwandtschaft.elternteil),
            ),
            IconButton(
              tooltip: t.stammbaumPartnerHinzufuegen,
              icon: const Icon(Icons.favorite_border),
              onPressed: fokus == null ? null : () => _hinzufuegen(Verwandtschaft.partner),
            ),
            IconButton(
              tooltip: t.stammbaumKindHinzufuegen,
              icon: const Icon(Icons.child_care_outlined),
              onPressed: fokus == null
                  ? null
                  : () => _hinzufuegen(Verwandtschaft.elternteil, umgekehrt: true),
            ),
          ],
        ),
        body: _laedt
            ? const Center(child: CircularProgressIndicator())
            : fokus == null
                ? Center(child: Text(t.stammbaumPersonFehlt))
                : _baum(context, fokus),
      ),
    );
  }

  Widget _baum(BuildContext context, PersonData fokus) {
    final t = AppTexte.of(context);
    final a = ausschnittUm(_netz, _fokusId, [for (final p in _personen) p.id]);

    final eltern = [for (final id in a.eltern) _nachId[id]!];
    final geschwister = [for (final id in a.geschwister) _nachId[id]!];
    final partner = [for (final id in a.partner) _nachId[id]!];
    final kinder = [for (final id in a.kinder) _nachId[id]!];

    final links = _gruppe(t.stammbaumGeschwister, geschwister, a);
    final rechts = _gruppe(t.stammbaumPartner, partner, a, verbunden: true);
    // Die Breiten sind ausrechenbar, weil eine Karte immer gleich breit
    // ist – siehe [_karteBreite]. Genau das braucht die Reihe unten: In
    // einem waagerecht rollbaren Bereich ist die Breite unbegrenzt, und
    // ein `Expanded` hat dort nichts, wovon es einen Anteil nehmen könnte.
    final linksBreite = _reiheBreite(geschwister.length);
    final rechtsBreite = partner.isEmpty
        ? 0.0
        : AppSpacing.lg + _reiheBreite(partner.length);

    // In beide Richtungen rollbar, aber mittig, solange der Baum ins
    // Fenster passt. Die Mindestmaße sind der Grund für den LayoutBuilder:
    // Ein rollbarer Bereich gibt seinem Kind unbegrenzten Platz, und ein
    // Kind, das nur so groß ist wie sein Inhalt, hat nichts, worin es sich
    // zentrieren könnte – der Baum klebte sonst in der linken oberen Ecke.
    return LayoutBuilder(
      builder: (context, platz) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: platz.maxWidth,
              minHeight: platz.maxHeight,
            ),
            child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (eltern.isNotEmpty) ...[
                _beschriftung(t.stammbaumEltern),
                _reihe(eltern, a, art: Verwandtschaft.elternteil),
                _Verbinder(anzahl: eltern.length, vieleOben: true),
              ],
              // Die mittlere Reihe wird auf der schmaleren Seite
              // aufgefüllt, damit die Person in der Mitte tatsächlich
              // waagerecht mittig steht – nur dann treffen die Linien von
              // oben und unten sie auch.
              _ausgeglicheneReihe(
                links: links,
                linksBreite: linksBreite,
                mitte: _karte(fokus, a, istFokus: true),
                rechts: rechts,
                rechtsBreite: rechtsBreite,
              ),
              if (kinder.isNotEmpty) ...[
                _Verbinder(anzahl: kinder.length, vieleOben: false),
                _reihe(kinder, a, art: Verwandtschaft.elternteil, umgekehrt: true),
                _beschriftung(t.stammbaumKinder),
              ],
              if (a.istLeer) ...[
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: 420,
                  child: Text(
                    t.stammbaumLeer,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
              ],
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _beschriftung(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        // Bewusst nicht in Großbuchstaben umgewandelt: Der Text kommt aus
        // der Übersetzung, und ihn im Quelltext umzuformen hiesse, für
        // jede Sprache dieselbe Schreibweise zu behaupten. Die Zeile hebt
        // sich über Größe, Sperrung und Farbe genug ab.
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );

  Widget _reihe(
    List<PersonData> personen,
    Stammbaumausschnitt a, {
    Verwandtschaft? art,
    bool umgekehrt = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < personen.length; i++) ...[
          if (i > 0) const SizedBox(width: _karteAbstand),
          _karte(personen[i], a, art: art, umgekehrt: umgekehrt),
        ],
      ],
    );
  }

  /// Eine beschriftete Nebengruppe (Geschwister, Partner).
  ///
  /// [verbunden] zieht einen kurzen Strich zur Mitte – für Partner
  /// zutreffend. Geschwister bekommen ihn nicht: Sie hängen nicht an der
  /// Person in der Mitte, sondern an den gemeinsamen Eltern, und eine Linie
  /// zwischen ihnen behauptete etwas Falsches.
  Widget? _gruppe(
    String titel,
    List<PersonData> personen,
    Stammbaumausschnitt a, {
    bool verbunden = false,
  }) {
    if (personen.isEmpty) return null;
    // Die Beschriftung schwebt über der Reihe, statt sie nach unten zu
    // drücken: Ein Stack misst sich an seinem nicht positionierten Kind,
    // die Gruppe ist also genau so hoch wie eine Karte. Vorher machte die
    // Beschriftung die Seitengruppe höher als die Karte in der Mitte – und
    // weil die Reihe an der Unterkante ausgerichtet ist, rutschte die
    // mittlere Karte nach unten weg. Die Linie von den Eltern endete dann
    // sichtbar über ihr, statt sie zu treffen.
    final block = Stack(
      clipBehavior: Clip.none,
      children: [
        _reihe(personen, a, art: verbunden ? Verwandtschaft.partner : null),
        Positioned(
          top: -16,
          left: 0,
          right: 0,
          child: Center(child: _beschriftung(titel)),
        ),
      ],
    );
    if (!verbunden) return block;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: AppSpacing.lg,
        height: 2,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      block,
    ]);
  }

  /// Die Breite einer Reihe aus [anzahl] Karten.
  double _reiheBreite(int anzahl) =>
      anzahl == 0 ? 0 : anzahl * _karteBreite + (anzahl - 1) * _karteAbstand;

  /// Die mittlere Reihe, mit der Person in der Mitte auch tatsächlich in
  /// der Mitte.
  ///
  /// Beide Seiten bekommen dieselbe Breite – die der breiteren. Ohne diesen
  /// Ausgleich säße die Person je nach Zahl der Geschwister und Partner
  /// seitlich versetzt, und die Linien von den Eltern und zu den Kindern
  /// träfen sie nicht mehr: Die zeichnen ihre Senkrechte in der Mitte der
  /// Spalte, nicht auf die Karte.
  Widget _ausgeglicheneReihe({
    required Widget? links,
    required double linksBreite,
    required Widget mitte,
    required Widget? rechts,
    required double rechtsBreite,
  }) {
    final seite = linksBreite > rechtsBreite ? linksBreite : rechtsBreite;
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: seite,
            child: Align(
              alignment: Alignment.centerRight,
              child: links ?? const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          mitte,
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: seite,
            child: Align(
              alignment: Alignment.centerLeft,
              child: rechts ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _karte(
    PersonData person,
    Stammbaumausschnitt a, {
    bool istFokus = false,
    Verwandtschaft? art,
    bool umgekehrt = false,
  }) {
    return _Personenkarte(
      person: person,
      paths: widget.library.paths,
      istFokus: istFokus,
      weitereOben: a.weitereOben[person.id] ?? false,
      weitereUnten: a.weitereUnten[person.id] ?? false,
      onTap: () => _ruecke(person.id),
      onMenue: (pos) => _karteMenue(pos, person, art: art, umgekehrt: umgekehrt),
    );
  }
}

/// Eine Personenkarte.
class _Personenkarte extends StatelessWidget {
  final PersonData person;
  final StoragePaths paths;
  final bool istFokus;
  final bool weitereOben;
  final bool weitereUnten;
  final VoidCallback onTap;
  final void Function(Offset position) onMenue;

  const _Personenkarte({
    required this.person,
    required this.paths,
    required this.istFokus,
    required this.weitereOben,
    required this.weitereUnten,
    required this.onTap,
    required this.onMenue,
  });

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final spanne = lebensspanne(person.geburtsdatum, person.sterbedatum);
    final bild = person.coverFaceCropPath;

    return GestureDetector(
      onSecondaryTapDown: (d) => onMenue(d.globalPosition),
      onLongPressStart: (d) => onMenue(d.globalPosition),
      child: InkWell(
        onTap: istFokus ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: _karteBreite,
          height: _karteHoehe,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: istFokus ? farben.surfaceContainerHighest : farben.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: istFokus ? farben.primary : farben.outlineVariant,
              width: istFokus ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Der Hinweis, dass über dieser Person noch Eltern stehen,
              // die hier nicht gezeigt werden – siehe Klassendoku von
              // [StammbaumScreen].
              _Mehrzeichen(sichtbar: weitereOben, nachOben: true),
              CircleAvatar(
                radius: 26,
                backgroundColor: farben.surfaceContainerHigh,
                backgroundImage: bild != null ? FileImage(paths.absolute(bild)) : null,
                child: bild == null
                    ? Icon(Icons.person_outline, size: 24, color: farben.outline)
                    : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                person.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: istFokus ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (spanne != null)
                Text(
                  spanne,
                  style: TextStyle(fontSize: 10, color: farben.outline),
                ),
              _Mehrzeichen(sichtbar: weitereUnten, nachOben: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// Das kleine Zeichen an einer Karte: „hier geht es weiter".
///
/// Nimmt seinen Platz auch dann ein, wenn es unsichtbar ist – sonst
/// verschöben sich Bild und Name zwischen Karten mit und ohne Hinweis, und
/// die Reihe säße nicht mehr auf einer Linie.
class _Mehrzeichen extends StatelessWidget {
  final bool sichtbar;
  final bool nachOben;
  const _Mehrzeichen({required this.sichtbar, required this.nachOben});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: sichtbar
          ? Icon(
              nachOben ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 12,
              color: Theme.of(context).colorScheme.outline,
            )
          : null,
    );
  }
}

/// Die Linien zwischen zwei Generationen.
///
/// Auf der einen Seite steht eine Person (die in der Mitte), auf der
/// anderen [anzahl] nebeneinander. Gezeichnet wird ein waagerechter Balken
/// über der Reihe, kurze Senkrechte zu jeder Karte und eine Senkrechte zur
/// Mitte hin.
///
/// Die Kartenmitten ergeben sich aus fester Kartenbreite und festem
/// Abstand – deshalb sind beide Konstanten und nicht vom Inhalt abhängig.
class _Verbinder extends StatelessWidget {
  final int anzahl;

  /// Ob die vielen Karten oben stehen (Eltern) oder unten (Kinder).
  final bool vieleOben;

  const _Verbinder({required this.anzahl, required this.vieleOben});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: anzahl * _karteBreite + (anzahl - 1) * _karteAbstand,
      height: _verbinderHoehe,
      child: CustomPaint(
        painter: _VerbinderMaler(
          anzahl: anzahl,
          vieleOben: vieleOben,
          farbe: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _VerbinderMaler extends CustomPainter {
  final int anzahl;
  final bool vieleOben;
  final Color farbe;

  const _VerbinderMaler({
    required this.anzahl,
    required this.vieleOben,
    required this.farbe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stift = Paint()
      ..color = farbe
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final mitte = size.width / 2;
    final balkenY = size.height / 2;

    // Die Seite mit den vielen Karten.
    final vieleY = vieleOben ? 0.0 : size.height;
    // Die halbe Balkenbreite: von der Mitte der ersten bis zur Mitte der
    // letzten Karte, also (anzahl-1) volle Kartenschritte.
    final halberBalken = (anzahl - 1) * (_karteBreite + _karteAbstand) / 2;

    if (anzahl > 1) {
      canvas.drawLine(
        Offset(mitte - halberBalken, balkenY),
        Offset(mitte + halberBalken, balkenY),
        stift,
      );
    }
    for (var i = 0; i < anzahl; i++) {
      final x = mitte - halberBalken + i * (_karteBreite + _karteAbstand);
      canvas.drawLine(Offset(x, vieleY), Offset(x, balkenY), stift);
    }
    // Und die eine Senkrechte zur Person in der Mitte.
    canvas.drawLine(
      Offset(mitte, balkenY),
      Offset(mitte, vieleOben ? size.height : 0),
      stift,
    );
  }

  @override
  bool shouldRepaint(_VerbinderMaler alt) =>
      alt.anzahl != anzahl || alt.vieleOben != vieleOben || alt.farbe != farbe;
}

/// Geburts- und Sterbedatum einer Person.
///
/// Beide freiwillig und einzeln löschbar. Der Bereich beginnt 1800: Eine
/// Fotobibliothek reicht selten weiter zurück, und ein Auswahldialog, der
/// bis ins Mittelalter blättert, macht das Suchen des richtigen
/// Jahrzehnts mühsamer.
class _LebensdatenDialog extends StatefulWidget {
  final PersonData person;
  const _LebensdatenDialog({required this.person});

  @override
  State<_LebensdatenDialog> createState() => _LebensdatenDialogState();
}

class _LebensdatenDialogState extends State<_LebensdatenDialog> {
  late DateTime? _geburt = widget.person.geburtsdatum;
  late DateTime? _tod = widget.person.sterbedatum;

  Future<void> _waehle({required bool geburt}) async {
    final jetzt = DateTime.now();
    final gewaehlt = await showDatePicker(
      context: context,
      initialDate: (geburt ? _geburt : _tod) ?? DateTime(jetzt.year - 40),
      firstDate: DateTime(1800),
      lastDate: jetzt,
    );
    if (gewaehlt == null || !mounted) return;
    setState(() => geburt ? _geburt = gewaehlt : _tod = gewaehlt);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return AlertDialog(
      title: Text(t.stammbaumLebensdatenVon(widget.person.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Datumszeile(
            beschriftung: t.stammbaumGeboren,
            wert: _geburt,
            onWaehlen: () => _waehle(geburt: true),
            onLoeschen: () => setState(() => _geburt = null),
          ),
          _Datumszeile(
            beschriftung: t.stammbaumGestorben,
            wert: _tod,
            onWaehlen: () => _waehle(geburt: false),
            onLoeschen: () => setState(() => _tod = null),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.stammbaumNurJahrHinweis,
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(t.allgAbbrechen)),
        FilledButton(
          onPressed: () => Navigator.pop(context, (geburt: _geburt, tod: _tod)),
          child: Text(t.allgSpeichern),
        ),
      ],
    );
  }
}

class _Datumszeile extends StatelessWidget {
  final String beschriftung;
  final DateTime? wert;
  final VoidCallback onWaehlen;
  final VoidCallback onLoeschen;

  const _Datumszeile({
    required this.beschriftung,
    required this.wert,
    required this.onWaehlen,
    required this.onLoeschen,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return Row(
      children: [
        SizedBox(width: 96, child: Text(beschriftung)),
        Expanded(
          child: OutlinedButton(
            onPressed: onWaehlen,
            child: Text(wert == null
                ? t.stammbaumUnbekannt
                : '${wert!.day}.${wert!.month}.${wert!.year}'),
          ),
        ),
        IconButton(
          tooltip: t.allgEntfernen,
          icon: const Icon(Icons.clear, size: 18),
          onPressed: wert == null ? null : onLoeschen,
        ),
      ],
    );
  }
}
