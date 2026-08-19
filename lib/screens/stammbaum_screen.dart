import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/stammbaum.dart';
import '../services/verwandtschaftsgrad.dart';
import '../services/storage_paths.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../services/faechertafel.dart';
import '../services/familienorte.dart';
import '../services/gedcom_export.dart';
import '../services/tafel_pdf.dart';
import '../services/sanduhr.dart';
import '../widgets/faecher_ansicht.dart';
import '../widgets/person_picker_dialog.dart';
import '../widgets/sanduhr_ansicht.dart';
import '../widgets/verwandtschaft_text.dart';
import 'familienfotos_screen.dart';
import 'familienorte_screen.dart';
import 'lebenslauf_screen.dart';
import 'person_detail_screen.dart';

/// Breite und Höhe einer Personenkarte. Fest, weil die Verbindungslinien
/// aus diesen beiden Zahlen und der Anzahl der Karten berechnet werden –
/// mit von der Schriftlänge abhängigen Breiten wüsste der Zeichner nicht,
/// wo eine Karte endet.
const double _karteBreite = 132;
/// Nachgemessen, nicht geschätzt: zwei Zeichen à 12, Bildkreis 52,
/// Abstand 4, zweizeiliger Name 34, Bezeichnung 14, Lebensspanne 14,
/// Polster 16 – zusammen 158. Vorher standen hier 148, und eine Karte mit
/// zweizeiligem Namen lief unten über („Marianne Schmidt-Hollmann" genügt
/// dafür). Die zwei Punkte Zugabe fangen die Randbreite ab.
const double _karteHoehe = 160;
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
/// Die beiden Sichten auf dieselbe Familie.
/// Wie eine Karte zur Person in der Mitte steht – nicht die Art der
/// gespeicherten Kante, sondern die Stelle im Bild.
///
/// Die Art selbst wird daraus im Netz nachgeschlagen (siehe
/// [_StammbaumScreenState._artFuer]); die Reihe kennt sie nicht.
/// Verwandte, die sich über eine Zwischenperson eintragen lassen.
///
/// Sie sind keine eigene Kantenart – gespeichert werden weiterhin nur
/// Eltern, Kinder und Partner. Diese Aufzählung beschreibt nur, an wem
/// die neue Person hängt.
enum _Weitere { geschwister, grosselternteil, enkel }

enum _Bezug {
  /// Die Karte steht in der Elternreihe.
  elternteil,

  /// Die Karte steht in der Kinderreihe.
  kind,

  /// Die Karte steht in der Partnergruppe.
  partner,

  /// Geschwister und die Person in der Mitte selbst: Zwischen ihnen und
  /// der Mitte steht keine eigene Kante, die man lösen könnte.
  keiner,
}

enum _Ansicht {
  /// Der Baum: unmittelbare Verwandtschaft, räumlich angeordnet.
  baum,

  /// Der Fächer: bis zu vier Generationen Vorfahren als Ringe. Die
  /// gewählte Baumoptik – sie kann als einzige mehrere Generationen
  /// zeigen, ohne dass eine Linie mehrdeutig wird.
  faecher,

  /// Die Sanduhr: Vorfahren und Nachkommen über mehrere Generationen in
  /// einem Bild.
  sanduhr,

  /// Die Nachfahren als eingerückte Gliederung – die Gegenrichtung zum
  /// Fächer, der nur nach oben zeigen kann.
  nachfahren,

  /// Die Liste: **alle** Verwandten mit ihrer Bezeichnung, von den
  /// nächsten zu den entferntesten. Erst hier tauchen die Bezeichnungen
  /// auf, für die im Baum kein Platz ist – Urgroßvater, Cousine zweiten
  /// Grades, Schwägerin.
  liste,
}

class StammbaumScreen extends StatefulWidget {
  final LibraryState library;

  /// Wer in der Mitte steht. `null`, wenn der Bildschirm über den
  /// Menüpunkt geöffnet wird und noch niemand gewählt ist – dann sucht er
  /// sich selbst eine Person aus (siehe [_StammbaumScreenState._startperson]).
  final String? startPersonId;

  const StammbaumScreen({
    super.key,
    required this.library,
    this.startPersonId,
  });

  @override
  State<StammbaumScreen> createState() => _StammbaumScreenState();
}

class _StammbaumScreenState extends State<StammbaumScreen> {
  String? _fokusId;
  _Ansicht _ansicht = _Ansicht.baum;

  List<PersonData> _personen = [];
  Map<String, PersonData> _nachId = {};
  Verwandtschaftsnetz _netz = Verwandtschaftsnetz(const []);

  /// Die Bezeichnung jeder verwandten Person, bezogen auf [_fokusId].
  /// Einmal je Fokuswechsel gerechnet statt je Karte – für die Liste
  /// braucht es ohnehin alle.
  Map<String, Grad> _grade = const {};
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
    final netz = Verwandtschaftsnetz([
      for (final z in zeilen)
        if (artAusText(z.art) case final art?) kante(z.personId, z.andereId, art),
    ]);
    setState(() {
      _personen = personen;
      _nachId = {for (final p in personen) p.id: p};
      _netz = netz;
      _fokusId ??= widget.startPersonId ?? _startperson(personen, netz);
      _laedt = false;
    });
    _rechneGrade();
  }

  /// Wen der Bildschirm zeigt, wenn er ohne Vorgabe geöffnet wird.
  ///
  /// Die Person mit den meisten eingetragenen Verwandten – dort ist am
  /// meisten zu sehen. Die erste Person der Liste wäre die schlechtere
  /// Wahl: Das ist die älteste oder alphabetisch erste, und die steht
  /// typischerweise am Rand des Baums, nicht in seiner Mitte.
  String? _startperson(List<PersonData> personen, Verwandtschaftsnetz netz) {
    if (personen.isEmpty) return null;
    var beste = personen.first;
    var meiste = -1;
    for (final p in personen) {
      final anzahl = netz.eltern(p.id).length +
          netz.kinder(p.id).length +
          netz.partner(p.id).length;
      if (anzahl > meiste) {
        meiste = anzahl;
        beste = p;
      }
    }
    return beste.id;
  }

  void _rechneGrade() {
    final fokus = _fokusId;
    if (fokus == null) return;
    setState(() {
      _grade = alleGrade(_netz, fokus, [for (final p in _personen) p.id]);
    });
  }

  /// Die Bezeichnung einer Person, bezogen auf die Person in der Mitte.
  String? _bezeichnung(PersonData person) {
    final grad = _grade[person.id];
    if (grad == null) return null;
    return verwandtschaftText(
        context, grad, geschlechtAusText(person.geschlecht));
  }

  void _ruecke(String id) {
    if (id == _fokusId) return;
    setState(() {
      _pfad.add(_fokusId!);
      _fokusId = id;
    });
    _rechneGrade();
  }

  bool _zurueck() {
    if (_pfad.isEmpty) return false;
    setState(() => _fokusId = _pfad.removeLast());
    _rechneGrade();
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
    final fokusId = _fokusId;
    if (fokusId == null) return;
    final t = AppTexte.of(context);
    final titel = art == Verwandtschaft.partner
        ? t.stammbaumPartnerHinzufuegen
        : umgekehrt
            ? t.stammbaumKindHinzufuegen
            : t.stammbaumElternteilHinzufuegen;
    final wahl = await showPersonPickerDialog(
      context,
      // Die Person in der Mitte steht nicht zur Auswahl – mit sich selbst
      // verwandt zu sein wäre der einzige Fehler, den dieser Dialog
      // überhaupt anbieten könnte.
      _personen.where((p) => p.id != fokusId).toList(),
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
        ? await widget.library.db.fuegeBeziehungHinzu(andereId, fokusId, art)
        : await widget.library.db.fuegeBeziehungHinzu(fokusId, andereId, art);
    await _laden();
    if (fehler != null && mounted) _meldeFehler(fehler);
  }

  /// Legt einen Verwandten an, der nicht unmittelbar an der Person in der
  /// Mitte hängt – ein Geschwisterkind, einen Großelternteil, ein
  /// Enkelkind.
  ///
  /// Gespeichert werden weiterhin nur Eltern, Kinder und Partner; alles
  /// andere ist ausgerechnet (siehe verwandtschaftsgrad.dart). Diese
  /// Einträge sind deshalb keine neue Kantenart, sondern eine Abkürzung:
  /// Sie hängen die neue Person an der richtigen Stelle ein, statt dass
  /// man erst zum Elternteil rücken, dort ein Kind eintragen und wieder
  /// zurückrücken muss.
  ///
  /// Wo die Stelle nicht eindeutig ist – wessen Elternteil, wessen Kind –,
  /// wird gefragt statt geraten.
  Future<void> _weitererVerwandter(_Weitere art) async {
    final fokusId = _fokusId;
    final fokus = _nachId[fokusId];
    if (fokusId == null || fokus == null) return;
    final t = AppTexte.of(context);

    // Die Personen, an die die neue angehängt wird. Für ein
    // Geschwisterkind sind das ALLE Eltern – ein Geschwisterkind mit nur
    // einem der beiden Elternteile wäre ein Halbgeschwisterkind, und das
    // ist eine andere Aussage.
    List<String> anker;
    switch (art) {
      case _Weitere.geschwister:
        anker = _netz.eltern(fokusId).toList();
        if (anker.isEmpty) {
          _kurzerHinweis(t.stammbaumBrauchtElternteil(fokus.name));
          return;
        }
      case _Weitere.grosselternteil:
        final eltern = _netz.eltern(fokusId).toList();
        if (eltern.isEmpty) {
          _kurzerHinweis(t.stammbaumBrauchtElternteil(fokus.name));
          return;
        }
        final gewaehlt = await _wenVon(eltern, t.stammbaumWelcherElternteil);
        if (gewaehlt == null) return;
        anker = [gewaehlt];
      case _Weitere.enkel:
        final kinder = _netz.kinder(fokusId).toList();
        if (kinder.isEmpty) {
          _kurzerHinweis(t.stammbaumBrauchtKind(fokus.name));
          return;
        }
        final gewaehlt = await _wenVon(kinder, t.stammbaumWelchesKind);
        if (gewaehlt == null) return;
        anker = [gewaehlt];
    }
    if (!mounted) return;

    final titel = switch (art) {
      _Weitere.geschwister => t.stammbaumGeschwisterHinzufuegen,
      _Weitere.grosselternteil => t.stammbaumGrosselternteilHinzufuegen,
      _Weitere.enkel => t.stammbaumEnkelHinzufuegen,
    };
    final wahl = await showPersonPickerDialog(
      context,
      // Weder die Mitte noch die Anker stehen zur Auswahl: Beide wären
      // ein Kreis oder eine Verwandtschaft mit sich selbst.
      _personen
          .where((p) => p.id != fokusId && !anker.contains(p.id))
          .toList(),
      paths: widget.library.paths,
      title: titel,
    );
    if (wahl == null || !mounted) return;

    String neueId;
    if (wahl.newName != null) {
      neueId = const Uuid().v4();
      await widget.library.db.createPerson(
        PeopleCompanion.insert(id: neueId, name: wahl.newName!),
      );
    } else {
      neueId = wahl.existingPersonId!;
    }

    Beziehungsfehler? fehler;
    for (final ankerId in anker) {
      // Ein Großelternteil ist Elternteil des Ankers, ein Geschwisterkind
      // und ein Enkelkind sind dessen Kind.
      final f = art == _Weitere.grosselternteil
          ? await widget.library.db
              .fuegeBeziehungHinzu(ankerId, neueId, Verwandtschaft.elternteil)
          : await widget.library.db
              .fuegeBeziehungHinzu(neueId, ankerId, Verwandtschaft.elternteil);
      // Der erste Fehler zählt: Bei einem Geschwisterkind mit zwei Eltern
      // sagt „schon vorhanden" beim zweiten nichts Neues.
      fehler ??= f;
    }
    await _laden();
    if (!mounted) return;
    if (fehler != null) {
      _meldeFehler(fehler);
      return;
    }
    // Ein Geschwisterkind entsteht aus zwei (oder mehr) Kanten auf einmal,
    // und keine davon führt zur Person in der Mitte. Wer das nicht weiß,
    // sieht nur eine neue Karte auftauchen. Die Rückmeldung nennt, was
    // tatsächlich eingetragen wurde.
    if (art == _Weitere.geschwister) {
      _kurzerHinweis(t.stammbaumGeschwisterHinweis(
        fokus.name,
        [for (final id in anker) _nachId[id]?.name ?? '?'].join(', '),
      ));
    }
  }

  /// Fragt, an welcher von mehreren Personen die neue hängen soll. Steht
  /// nur eine zur Wahl, wird nicht gefragt.
  Future<String?> _wenVon(List<String> ids, String titel) async {
    if (ids.length == 1) return ids.first;
    final personen = [
      for (final id in ids)
        if (_nachId[id] case final p?) p,
    ];
    if (personen.isEmpty) return null;
    if (!mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (dialog) => SimpleDialog(
        title: Text(titel),
        children: [
          for (final p in personen)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialog, p.id),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundImage: p.coverFaceCropPath != null
                      ? FileImage(
                          widget.library.paths.absolute(p.coverFaceCropPath!))
                      : null,
                  child: p.coverFaceCropPath == null
                      ? const Icon(Icons.person_outline, size: 18)
                      : null,
                ),
                title: Text(p.name),
                subtitle: lebensspanne(p.geburtsdatum, p.sterbedatum) == null
                    ? null
                    : Text(lebensspanne(p.geburtsdatum, p.sterbedatum)!),
              ),
            ),
        ],
      ),
    );
  }

  /// Ein kurzer Hinweis am unteren Rand – für die Fälle, in denen der
  /// Wunsch verständlich, aber (noch) nicht ausführbar ist.
  void _kurzerHinweis(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
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
          value: 'lebenslauf',
          child: _zeile(Icons.timeline_outlined, t.stammbaumLebenslauf),
        ),
        PopupMenuItem(
          value: 'fotos',
          child: _zeile(Icons.photo_library_outlined, t.stammbaumFotosZeigen),
        ),
        if (art != null) ...[
          const PopupMenuDivider(),
          // Nur für Elternverbindungen: Zwischen Partnern gibt es keine
          // Arten, und zwischen Geschwistern keine eigene Kante.
          if (istElternArt(art))
            PopupMenuItem(
              value: 'art',
              child: _zeile(Icons.swap_horiz, t.stammbaumVerbindungsart),
            ),
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
      case 'lebenslauf':
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LebenslaufScreen(library: widget.library, person: person),
        ));
      case 'fotos':
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PersonDetailScreen(library: widget.library, person: person),
        ));
        await _laden();
      case 'art':
        await _verbindungsartAendern(person, art!, umgekehrt);
      case 'loesen':
        await _verbindungLoesen(person, art!, umgekehrt);
    }
  }

  /// Ändert eine bestehende Elternverbindung zwischen „leiblich",
  /// „Adoptiv" und „Pflege".
  ///
  /// Bisher blieb nur, die Verbindung zu lösen und neu zu legen – und wer
  /// das tat, verlor dabei nichts, musste aber die Person im Wähler erneut
  /// suchen. Die Art ist eine Eigenschaft der Verbindung; sie zu ändern
  /// sollte die Verbindung nicht antasten.
  Future<void> _verbindungsartAendern(
      PersonData person, Verwandtschaft art, bool umgekehrt) async {
    final fokusId = _fokusId;
    if (fokusId == null) return;
    // Wer ist hier das Kind? In der Elternreihe die Mitte, in der
    // Kinderreihe die angeklickte Person.
    final kindId = umgekehrt ? person.id : fokusId;
    final elternteilId = umgekehrt ? fokusId : person.id;
    final t = AppTexte.of(context);

    final neueArt = await showDialog<Verwandtschaft>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.stammbaumVerbindungsartTitel(
          _nachId[kindId]?.name ?? '',
          _nachId[elternteilId]?.name ?? '',
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (kandidat, symbol, text) in [
              (Verwandtschaft.elternteil, Icons.person_outline, t.stammbaumLeiblich),
              (Verwandtschaft.adoptivelternteil, Icons.family_restroom, t.stammbaumAdoptiv),
              (
                Verwandtschaft.pflegeelternteil,
                Icons.volunteer_activism_outlined,
                t.stammbaumPflege
              ),
            ])
              ListTile(
                leading: Icon(symbol),
                title: Text(text),
                selected: kandidat == art,
                // Ein Haken statt eines Auswahlknopfes: Die Liste hat drei
                // Einträge, jeder schliesst den Dialog sofort. Ein
                // Auswahlknopf verspräche ein späteres „Übernehmen", das es
                // hier nicht gibt.
                trailing: kandidat == art ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(dialog, kandidat),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.stammbaumVerbindungsartHinweis,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: Text(t.allgAbbrechen)),
        ],
      ),
    );
    if (neueArt == null || neueArt == art) return;
    await widget.library.db.aendereElternart(kindId, elternteilId, neueArt);
    await _laden();
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
    final fokusId = _fokusId!;
    final entfernt = umgekehrt
        ? await widget.library.db.entferneBeziehung(person.id, fokusId, art)
        : await widget.library.db.entferneBeziehung(fokusId, person.id, art);
    await _laden();
    // Ein Griff ins Leere soll nicht als Erfolg aussehen. Genau das war
    // der Fehler bei Adoptiv- und Pflegeeltern: Es passierte nichts, und
    // nichts sagte es.
    if (!entfernt && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.stammbaumNichtsEntfernt)));
    }
  }

  Future<void> _lebensdatenBearbeiten(PersonData person) async {
    final ergebnis =
        await showDialog<({DateTime? geburt, DateTime? tod, Geschlecht? geschlecht})>(
      context: context,
      builder: (_) => _LebensdatenDialog(person: person),
    );
    if (ergebnis == null) return;
    await widget.library.db.setzeLebensdaten(person.id,
        geburt: ergebnis.geburt, tod: ergebnis.tod);
    await widget.library.db.setzeGeschlecht(person.id, ergebnis.geschlecht);
    await _laden();
  }

  /// Wechselt die Person in der Mitte über die bekannte Personenauswahl.
  ///
  /// Ein neuer Name ist dort erlaubt und legt die Person an – so lässt
  /// sich ein Stammbaum auch dann beginnen, wenn noch niemand benannt ist.
  Future<void> _waehlePerson() async {
    final wahl = await showPersonPickerDialog(
      context,
      _personen,
      paths: widget.library.paths,
      title: AppTexte.of(context).stammbaumAndereWaehlen,
    );
    if (wahl == null || !mounted) return;
    if (wahl.newName != null) {
      final id = const Uuid().v4();
      await widget.library.db
          .createPerson(PeopleCompanion.insert(id: id, name: wahl.newName!));
      if (!mounted) return;
      setState(() => _fokusId = id);
      await _laden();
      return;
    }
    _ruecke(wahl.existingPersonId!);
  }

  /// Öffnet alle Fotos, auf denen jemand aus dieser Familie zu sehen ist.
  ///
  /// Die Funktion, die diese App von einem Ahnenprogramm unterscheidet:
  /// Die Gesichter sind bereits Personen zugeordnet, die Verwandtschaft
  /// steht daneben – es fehlte nur die Abfrage, die beides verbindet.
  Future<void> _fotosDerFamilie() async {
    final fokus = _fokusId;
    if (fokus == null) return;
    final t = AppTexte.of(context);
    // Die Person selbst gehört dazu, sonst fehlten ausgerechnet ihre
    // eigenen Fotos.
    final ids = [fokus, ..._grade.keys];
    final assets = await widget.library.db.assetsFuerPersonen(ids);
    if (!mounted) return;
    if (assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.stammbaumKeineFamilienfotos)),
      );
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FamilienfotosScreen(
        library: widget.library,
        titel: t.stammbaumFamilienfotosVon(_nachId[fokus]?.name ?? ''),
        assets: assets,
      ),
    ));
  }

  /// Zeigt die Fotos der Familie auf einer Karte, eingefärbt nach
  /// Verwandtschaftsrichtung.
  Future<void> _orteDerFamilie() async {
    final fokus = _fokusId;
    if (fokus == null) return;
    final t = AppTexte.of(context);
    final roh = await widget.library.db
        .verorteteAssetsFuerPersonen([fokus, ..._grade.keys]);
    if (!mounted) return;
    final orte = <Familienort>[
      for (final e in roh)
        if (gruppeFuerFoto(e.personen, _grade, fokus: fokus) case final g?)
          (asset: e.asset, gruppe: g),
    ];
    if (orte.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.stammbaumKeineFamilienorte)),
      );
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FamilienorteScreen(
        library: widget.library,
        titel: t.stammbaumFamilienorteVon(_nachId[fokus]?.name ?? ''),
        orte: orte,
      ),
    ));
  }

  /// Schreibt den Fächer als PDF – die Tafel zum Aufhängen.
  ///
  /// Gezeichnet wird mit **derselben** Routine wie auf dem Bildschirm,
  /// nur auf eine viel größere Leinwand; das Ergebnis wandert als Bild in
  /// die Seite. Die Alternative – den Fächer ein zweites Mal mit den
  /// Zeichenbefehlen der PDF-Bibliothek zu bauen – hätte zwei
  /// Darstellungen ergeben, die auseinanderlaufen können.
  Future<void> _tafelDrucken() async {
    final fokus = _fokusId;
    if (fokus == null) return;
    final t = AppTexte.of(context);
    final rang = {for (var i = 0; i < _personen.length; i++) _personen[i].id: i};
    final plaetze = faechertafel(_netz, fokus, (id) => rang[id] ?? 1 << 30);

    final ziel = await FilePicker.platform.saveFile(
      dialogTitle: t.stammbaumTafelDrucken,
      fileName: tafelDateiname,
      type: FileType.custom,
      allowedExtensions: const [tafelEndungOhnePunkt],
    );
    if (ziel == null || !mounted) return;

    final bytes = await baueTafelPdf(
      plaetze: plaetze,
      personen: _nachId,
      titel: _nachId[fokus]?.name ?? '',
      farben: Theme.of(context).colorScheme,
      textRichtung: Directionality.of(context),
    );
    await File(mitTafelEndung(ziel)).writeAsBytes(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.stammbaumTafelFertig)),
    );
  }

  /// Schreibt den Bestand als GEDCOM-Datei.
  ///
  /// Ohne diesen Weg wären die eingetragenen Verwandtschaften in dieser
  /// App gefangen – Fotos lassen sich immer noch kopieren, ein
  /// Verwandtschaftsnetz nicht.
  Future<void> _gedcomExport() async {
    final t = AppTexte.of(context);
    final ziel = await FilePicker.platform.saveFile(
      dialogTitle: t.stammbaumGedcomExport,
      fileName: gedcomDateiname,
      type: FileType.custom,
      allowedExtensions: const [gedcomEndungOhnePunkt],
    );
    if (ziel == null || !mounted) return;

    final inhalt = schreibeGedcom(
      [
        for (final p in _personen)
          (
            id: p.id,
            name: p.name,
            geschlecht: geschlechtAusText(p.geschlecht),
            geburt: p.geburtsdatum,
            tod: p.sterbedatum,
          ),
      ],
      _netz,
      erzeuger: gedcomErzeuger,
      // Aus dem Paket statt als feste Zeichenkette – sonst stünde in der
      // exportierten Datei irgendwann eine Version, die es nicht gibt.
      version: (await PackageInfo.fromPlatform()).version,
    );
    if (!mounted) return;
    // Ausdrücklich UTF-8: Der Kopf der Datei kündigt es an, und die
    // Standard-Kodierung von `writeAsString` ist es nicht überall.
    await File(mitEndung(ziel)).writeAsString(inhalt, encoding: utf8);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.stammbaumGedcomFertig(_personen.length))),
    );
  }

  /// Der Fächer – siehe [FaecherAnsicht].
  Widget _faecher(BuildContext context, PersonData fokus) {
    final rang = {for (var i = 0; i < _personen.length; i++) _personen[i].id: i};
    final plaetze = faechertafel(
      _netz,
      fokus.id,
      (id) => rang[id] ?? 1 << 30,
    );
    // Nicht "nur ein Platz": Für eine Person ohne Eltern liefert die
    // Tafel zwei leere Elternplätze mit – die Lücke ist gewollt. Leer ist
    // der Fächer erst, wenn außerhalb der Mitte niemand steht.
    if (plaetze.every((p) => p.ring == 0 || p.istLeer)) {
      return _hinweis(context, AppTexte.of(context).stammbaumKeineVorfahren);
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: FaecherAnsicht(
        plaetze: plaetze,
        personen: _nachId,
        onTippen: _ruecke,
      ),
    );
  }

  /// Die Sanduhr – siehe [SanduhrAnsicht].
  Widget _sanduhr(BuildContext context, PersonData fokus) {
    final rang = {for (var i = 0; i < _personen.length; i++) _personen[i].id: i};
    final s = ordneSanduhr(_netz, fokus.id, (id) => rang[id] ?? 1 << 30);
    if (s.knoten.length == 1) {
      return _hinweis(context, AppTexte.of(context).stammbaumLeer);
    }
    return SanduhrAnsicht(
      sanduhr: s,
      personen: _nachId,
      fokusId: fokus.id,
      onTippen: _ruecke,
    );
  }

  /// Die Nachkommen als eingerückte Gliederung.
  Widget _nachfahrenTafel(BuildContext context, PersonData fokus) {
    final rang = {for (var i = 0; i < _personen.length; i++) _personen[i].id: i};
    final zeilen = nachfahren(_netz, fokus.id, (id) => rang[id] ?? 1 << 30);
    if (zeilen.length == 1) {
      return _hinweis(context, AppTexte.of(context).stammbaumKeineNachfahren);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: zeilen.length,
      itemBuilder: (context, index) {
        final zeile = zeilen[index];
        final person = _nachId[zeile.personId];
        if (person == null) return const SizedBox.shrink();
        final spanne = lebensspanne(person.geburtsdatum, person.sterbedatum);
        return InkWell(
          onTap: () => _ruecke(person.id),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.lg + zeile.stufe * 24.0,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm),
            child: Row(
              children: [
                // Ein Winkel statt eines Aufzählungspunkts: Er zeigt an,
                // dass die Zeile an der darüber hängt.
                Icon(
                  zeile.stufe == 0
                      ? Icons.person_outline
                      : Icons.subdirectory_arrow_right,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  person.name,
                  style: TextStyle(
                    fontWeight:
                        zeile.stufe == 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (spanne != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(spanne,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _hinweis(BuildContext context, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: SizedBox(
            width: 420,
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ),
        ),
      );

  /// Alle Verwandten mit ihrer Bezeichnung, von den nächsten zu den
  /// entferntesten.
  ///
  /// Der Grund, warum es diese Sicht neben dem Baum gibt: Im Baum steht
  /// nur die unmittelbare Verwandtschaft, dort tauchen „Urgroßvater" oder
  /// „Cousine zweiten Grades" nie auf. Hier schon.
  Widget _verwandtenListe(BuildContext context, PersonData fokus) {
    final t = AppTexte.of(context);
    final eintraege = _grade.entries
        .where((e) => _nachId.containsKey(e.key))
        .toList()
      ..sort((a, b) {
        final rang = naeheRang(a.value).compareTo(naeheRang(b.value));
        if (rang != 0) return rang;
        return _nachId[a.key]!.name.toLowerCase().compareTo(
            _nachId[b.key]!.name.toLowerCase());
      });

    if (eintraege.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: SizedBox(
            width: 420,
            child: Text(t.stammbaumLeer, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: eintraege.length + 1,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
            child: Text(
              t.stammbaumListeKopf(fokus.name, eintraege.length),
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          );
        }
        final eintrag = eintraege[index - 1];
        final person = _nachId[eintrag.key]!;
        final spanne = lebensspanne(person.geburtsdatum, person.sterbedatum);
        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            backgroundImage: person.coverFaceCropPath != null
                ? FileImage(widget.library.paths.absolute(person.coverFaceCropPath!))
                : null,
            child: person.coverFaceCropPath == null
                ? const Icon(Icons.person_outline, size: 18)
                : null,
          ),
          title: Text(person.name),
          subtitle: Text(
            verwandtschaftText(context, eintrag.value,
                geschlechtAusText(person.geschlecht)),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (spanne != null)
                Text(spanne,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12)),
              Builder(
                builder: (knopfKontext) => IconButton(
                  tooltip: t.stammbaumMenue,
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    final kasten =
                        knopfKontext.findRenderObject() as RenderBox;
                    final bezug = _bezugZurMitte(person.id);
                    _karteMenue(
                      kasten.localToGlobal(
                          kasten.size.bottomLeft(Offset.zero)),
                      person,
                      art: _artFuer(person, bezug),
                      umgekehrt: bezug == _Bezug.kind,
                    );
                  },
                ),
              ),
            ],
          ),
          // Kein langes Drücken wie auf einer Karte: Hier steht der Knopf
          // sichtbar daneben, eine zweite verborgene Geste wäre nur eine
          // weitere Möglichkeit, dasselbe zu tun.
          onTap: () => _ruecke(person.id),
        );
      },
    );
  }

  /// Der Knopf zum Hinzufügen eines Elternteils bzw. Kindes.
  ///
  /// Ein Menü statt eines einfachen Knopfes, seit es drei Arten von
  /// Elternschaft gibt. Die Alternative wäre gewesen, nach der Auswahl
  /// der Person noch nach der Art zu fragen – ein zweiter Dialog bei
  /// jedem Eintrag, für eine Angabe, die in den allermeisten Fällen
  /// „leiblich“ lautet.
  Widget _elternMenue(AppTexte t, PersonData? fokus, {required bool umgekehrt}) {
    return PopupMenuButton<Verwandtschaft>(
      tooltip: umgekehrt ? t.stammbaumKindHinzufuegen : t.stammbaumElternteilHinzufuegen,
      icon: Icon(umgekehrt ? Icons.child_care_outlined : Icons.person_add_alt),
      enabled: fokus != null,
      onSelected: (art) => _hinzufuegen(art, umgekehrt: umgekehrt),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: Verwandtschaft.elternteil,
          child: _zeile(Icons.person_outline, t.stammbaumLeiblich),
        ),
        PopupMenuItem(
          value: Verwandtschaft.adoptivelternteil,
          child: _zeile(Icons.family_restroom, t.stammbaumAdoptiv),
        ),
        PopupMenuItem(
          value: Verwandtschaft.pflegeelternteil,
          child: _zeile(Icons.volunteer_activism_outlined, t.stammbaumPflege),
        ),
      ],
    );
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
          title: Row(
            children: [
              Flexible(
                child: Text(fokus == null
                    ? t.stammbaumTitel
                    : t.stammbaumTitelVon(fokus.name)),
              ),
              if (fokus != null) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  tooltip: t.stammbaumAndereWaehlen,
                  icon: const Icon(Icons.swap_horiz, size: 20),
                  onPressed: _waehlePerson,
                ),
              ],
            ],
          ),
          bottom: fokus == null
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  // Waagerecht rollbar statt umbrechend: Bei knapp 480
                  // Punkten Fensterbreite brachen die vier Beschriftungen
                  // zweizeilig um, und die Abschnitte bekamen
                  // unterschiedliche Höhen. Lieber eine Zeile, die sich
                  // schieben lässt.
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SegmentedButton<_Ansicht>(
                      // Ohne Symbole: Vier Abschnitte mit Symbol UND
                      // Beschriftung laufen in einem schmalen Fenster über.
                      segments: [
                        ButtonSegment(
                          value: _Ansicht.baum,
                          label: Text(t.stammbaumAnsichtBaum),
                        ),
                        ButtonSegment(
                          value: _Ansicht.faecher,
                          label: Text(t.stammbaumAnsichtFaecher),
                        ),
                        ButtonSegment(
                          value: _Ansicht.sanduhr,
                          label: Text(t.stammbaumAnsichtSanduhr),
                        ),
                        ButtonSegment(
                          value: _Ansicht.nachfahren,
                          label: Text(t.stammbaumAnsichtNachfahren),
                        ),
                        ButtonSegment(
                          value: _Ansicht.liste,
                          label: Text(t.stammbaumAnsichtListe),
                        ),
                      ],
                      selected: {_ansicht},
                      showSelectedIcon: false,
                      onSelectionChanged: (w) => setState(() => _ansicht = w.first),
                    ),
                  ),
                ),
          actions: [
            _elternMenue(t, fokus, umgekehrt: false),
            IconButton(
              tooltip: t.stammbaumPartnerHinzufuegen,
              icon: const Icon(Icons.favorite_border),
              onPressed: fokus == null ? null : () => _hinzufuegen(Verwandtschaft.partner),
            ),
            _elternMenue(t, fokus, umgekehrt: true),
            PopupMenuButton<String>(
              tooltip: t.allgMehr,
              onSelected: (w) => switch (w) {
                'geschwister' => _weitererVerwandter(_Weitere.geschwister),
                'grosseltern' => _weitererVerwandter(_Weitere.grosselternteil),
                'enkel' => _weitererVerwandter(_Weitere.enkel),
                'fotos' => _fotosDerFamilie(),
                'orte' => _orteDerFamilie(),
                'tafel' => _tafelDrucken(),
                _ => _gedcomExport(),
              },
              itemBuilder: (context) => [
                // Verwandte, die nicht unmittelbar an der Mitte hängen.
                // Die Knöpfe daneben legen Eltern, Kinder und Partner an –
                // das sind die Kanten, die es wirklich gibt. Was hier
                // steht, hängt die neue Person an einer Zwischenperson ein.
                // Die Überschrift sagt das, ohne dass man es erraten muss.
                PopupMenuItem(
                  enabled: false,
                  height: 32,
                  child: Text(
                    t.stammbaumWeitereVerwandte,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'geschwister',
                  enabled: fokus != null,
                  child: _zeile(Icons.people_outline,
                      t.stammbaumGeschwisterHinzufuegen),
                ),
                PopupMenuItem(
                  value: 'grosseltern',
                  enabled: fokus != null,
                  child: _zeile(Icons.elderly_outlined,
                      t.stammbaumGrosselternteilHinzufuegen),
                ),
                PopupMenuItem(
                  value: 'enkel',
                  enabled: fokus != null,
                  child: _zeile(Icons.child_friendly_outlined,
                      t.stammbaumEnkelHinzufuegen),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'fotos',
                  enabled: fokus != null,
                  child: _zeile(Icons.photo_library_outlined, t.stammbaumFamilienfotos),
                ),
                PopupMenuItem(
                  value: 'orte',
                  enabled: fokus != null,
                  child: _zeile(Icons.map_outlined, t.stammbaumFamilienorte),
                ),
                PopupMenuItem(
                  value: 'tafel',
                  enabled: fokus != null,
                  child: _zeile(Icons.print_outlined, t.stammbaumTafelDrucken),
                ),
                PopupMenuItem(
                  value: 'gedcom',
                  enabled: _personen.isNotEmpty,
                  child: _zeile(Icons.ios_share, t.stammbaumGedcomExport),
                ),
              ],
            ),
          ],
        ),
        body: _laedt
            ? const Center(child: CircularProgressIndicator())
            : fokus == null
                ? Center(child: Text(_personen.isEmpty
                    ? t.stammbaumKeinePersonen
                    : t.stammbaumPersonFehlt))
                : switch (_ansicht) {
                    _Ansicht.baum => _baum(context, fokus),
                    _Ansicht.faecher => _faecher(context, fokus),
                    _Ansicht.sanduhr => _sanduhr(context, fokus),
                    _Ansicht.nachfahren => _nachfahrenTafel(context, fokus),
                    _Ansicht.liste => _verwandtenListe(context, fokus),
                  },
      ),
    );
  }

  Widget _baum(BuildContext context, PersonData fokus) {
    final t = AppTexte.of(context);
    final a = ausschnittUm(_netz, fokus.id, [for (final p in _personen) p.id]);

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
                _reihe(eltern, a, bezug: _Bezug.elternteil),
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
                _reihe(kinder, a, bezug: _Bezug.kind),
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
    _Bezug bezug = _Bezug.keiner,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < personen.length; i++) ...[
          if (i > 0) const SizedBox(width: _karteAbstand),
          _karte(personen[i], a, bezug: bezug),
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
        _reihe(personen, a, bezug: verbunden ? _Bezug.partner : _Bezug.keiner),
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
    _Bezug bezug = _Bezug.keiner,
  }) {
    final art = _artFuer(person, bezug);
    return _Personenkarte(
      person: person,
      paths: widget.library.paths,
      istFokus: istFokus,
      bezeichnung: istFokus ? null : _bezeichnung(person),
      weitereOben: a.weitereOben[person.id] ?? false,
      weitereUnten: a.weitereUnten[person.id] ?? false,
      onTap: () => _ruecke(person.id),
      onMenue: (pos) => _karteMenue(pos, person,
          art: art, umgekehrt: bezug == _Bezug.kind),
    );
  }

  /// Wie [person] zur Mitte steht, aus dem Netz hergeleitet.
  ///
  /// Für die Sichten ohne feste Reihen – die Verwandtenliste zeigt auch
  /// eine Großtante, zu der es gar keine eigene Kante gibt. Dann
  /// [_Bezug.keiner], und das Menü bietet folgerichtig kein Lösen an.
  _Bezug _bezugZurMitte(String personId) {
    final fokus = _fokusId;
    if (fokus == null || personId == fokus) return _Bezug.keiner;
    if (_netz.eltern(fokus).contains(personId)) return _Bezug.elternteil;
    if (_netz.kinder(fokus).contains(personId)) return _Bezug.kind;
    if (_netz.partner(fokus).contains(personId)) return _Bezug.partner;
    return _Bezug.keiner;
  }

  /// Die tatsächlich gespeicherte Art der Verbindung zwischen [person] und
  /// der Person in der Mitte.
  ///
  /// Aus dem Netz nachgeschlagen statt aus der Reihe abgeleitet: Eine
  /// Elternreihe kann einen leiblichen und daneben einen Adoptivvater
  /// enthalten. Die Reihe weiß nur, dass es Eltern sind – welcher Art,
  /// weiß nur die Kante.
  ///
  /// Genau hier lag der Fehler: Beide Elternreihen übergaben fest
  /// „leiblich", und das Lösen einer Adoptivverbindung traf deshalb keine
  /// Zeile.
  Verwandtschaft? _artFuer(PersonData person, _Bezug bezug) {
    final fokus = _fokusId;
    if (fokus == null) return null;
    return switch (bezug) {
      _Bezug.elternteil => _netz.elternArt(fokus, person.id),
      _Bezug.kind => _netz.elternArt(person.id, fokus),
      _Bezug.partner => Verwandtschaft.partner,
      _Bezug.keiner => null,
    };
  }
}

/// Eine Personenkarte.
class _Personenkarte extends StatelessWidget {
  final PersonData person;
  final StoragePaths paths;
  final bool istFokus;

  /// Wie diese Person zur Person in der Mitte steht – „Schwester",
  /// „Schwiegervater". Bei der Person in der Mitte selbst `null`: „diese
  /// Person" auf der eigenen Karte wäre nur Füllsel.
  final String? bezeichnung;
  final bool weitereOben;
  final bool weitereUnten;
  final VoidCallback onTap;
  final void Function(Offset position) onMenue;

  const _Personenkarte({
    required this.person,
    required this.paths,
    required this.istFokus,
    required this.bezeichnung,
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
      child: Stack(
        children: [
          InkWell(
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
              if (bezeichnung != null)
                Text(
                  bezeichnung!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: farben.primary,
                  ),
                ),
              if (spanne != null)
                Text(
                  spanne,
                  // onSurfaceVariant statt outline – gegen die Kartenfläche
                  // gemessen kam outline auf 4,07:1, gefordert sind 4,5:1.
                  style: TextStyle(fontSize: 10, color: farben.onSurfaceVariant),
                ),
              _Mehrzeichen(sichtbar: weitereUnten, nachOben: false),
            ],
          ),
        ),
      ),
          // Das Menü gab es bisher nur über die rechte Maustaste und langes
          // Drücken – zwei Gesten, die niemand ausprobiert, wenn nichts
          // darauf hinweist. Ein sichtbares Zeichen in der Ecke, ruhig
          // gehalten, damit es die Karte nicht beherrscht; die beiden
          // Gesten bleiben zusätzlich.
          Positioned(
            top: 0,
            right: 0,
            child: Builder(
              builder: (knopfKontext) => IconButton(
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(AppSpacing.xs),
                constraints: const BoxConstraints(),
                tooltip: AppTexte.of(context).stammbaumMenue,
                icon: Icon(Icons.more_vert,
                    color: Theme.of(context).colorScheme.outline),
                onPressed: () {
                  // Das Menü öffnet an der Stelle des Knopfes, nicht am
                  // Mauszeiger: Bei einem Klick gibt es keinen.
                  final kasten =
                      knopfKontext.findRenderObject() as RenderBox;
                  onMenue(kasten.localToGlobal(kasten.size.bottomLeft(Offset.zero)));
                },
              ),
            ),
          ),
        ],
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

/// Geschlecht sowie Geburts- und Sterbedatum einer Person.
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
  late Geschlecht? _geschlecht = geschlechtAusText(widget.person.geschlecht);

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
      title: Text(t.stammbaumAngaben),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(width: 96, child: Text(t.stammbaumGeschlecht)),
              Expanded(
                child: DropdownButton<Geschlecht?>(
                  value: _geschlecht,
                  isExpanded: true,
                  isDense: true,
                  onChanged: (w) => setState(() => _geschlecht = w),
                  items: [
                    DropdownMenuItem(value: null, child: Text(t.stammbaumGeschlechtOffen)),
                    DropdownMenuItem(
                        value: Geschlecht.weiblich,
                        child: Text(t.stammbaumGeschlechtWeiblich)),
                    DropdownMenuItem(
                        value: Geschlecht.maennlich,
                        child: Text(t.stammbaumGeschlechtMaennlich)),
                    DropdownMenuItem(
                        value: Geschlecht.divers,
                        child: Text(t.stammbaumGeschlechtDivers)),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              t.stammbaumGeschlechtHinweis,
              style: TextStyle(
                  fontSize: 11, color: Theme.of(context).colorScheme.outline),
            ),
          ),
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
          onPressed: () => Navigator.pop(
              context, (geburt: _geburt, tod: _tod, geschlecht: _geschlecht)),
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
