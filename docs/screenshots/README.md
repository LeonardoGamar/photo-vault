# Bildschirmfotos

## Regel

Auf Bildschirmfotos in diesem Repository dürfen **ausschließlich frei
lizenzierte Beispielbilder** zu sehen sein – niemals Fotos aus einer echten
Bibliothek. Ein einmal veröffentlichtes Bild lässt sich nicht
zurückholen, und eine Fotoverwaltung zeigt naturgemäß genau das, was privat
ist: Gesichter, Orte, Aufnahmedaten.

Das betrifft nicht nur das offensichtliche Foto in der Mitte, sondern auch:

- Vorschaubilder am Rand, Filmstreifen, Personen-Kacheln
- Dateinamen und Pfade in der Informationsleiste
- GPS-Orte in der Kartenansicht
- Namen echter Personen im Personen-Tab

## Vorgehen für neue Aufnahmen

1. **Eigene Demo-Bibliothek anlegen.** In den Einstellungen unter
   Speicherort einen leeren Ordner wählen (z.B. `~/PhotoVault-Demo`) – die
   eigene Bibliothek bleibt davon unberührt.
2. **Frei lizenzierte Fotos importieren.** Geeignete Quellen:
   - [Unsplash](https://unsplash.com/license) – kostenlos nutzbar
   - [Wikimedia Commons](https://commons.wikimedia.org/) – gemeinfrei/CC
   - [raw.pixls.us](https://raw.pixls.us/) – RAW-Beispiele, meist CC0
     (dieselbe Quelle nutzt `tool/fetch_format_samples.sh`)
3. **Aufnehmen.** Unter macOS mit `⇧⌘4`, dann Leertaste, dann auf das
   Fenster klicken – das erfasst nur das Fenster, nicht den Schreibtisch.
4. **Vor dem Commit prüfen:** Ist auf dem Bild irgendetwas zu sehen, das zu
   einer realen Person, einem realen Ort oder einem privaten Dateipfad
   gehört? Im Zweifel neu aufnehmen.

## Erwartete Dateien

| Datei | Inhalt |
|---|---|
| `timeline.png` | Timeline mit Monatsgruppierung |
| `entwickeln.png` | Entwickeln-Bildschirm mit Histogramm und Reglern |
| `personen.png` | Personen-Tab mit Gesichtsgruppen |
| `karte.png` | Kartenansicht mit Fotoorten |

Sind die Dateien vorhanden, können sie in der Haupt-README wieder als
Bildtabelle eingebunden werden:

```markdown
| Timeline | Entwickeln |
|---|---|
| ![Timeline](docs/screenshots/timeline.png) | ![Entwickeln](docs/screenshots/entwickeln.png) |
```
