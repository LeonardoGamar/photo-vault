# `HardSwish` liefert im Flutter-Prozess unter Linux nur Nullen

Ein ONNX-Modell mit **einem einzigen `HardSwish`-Knoten** gibt in einer
Flutter-Linux-Anwendung durchweg Nullen zurück. Dieselbe Modelldatei,
gerechnet von derselben `libonnxruntime.so` in einem gewöhnlichen
C++-Programm auf derselben Maschine, liefert das richtige Ergebnis.

```
Eingabe   -4      -3      -1      -0,5     0      0,5     1       3
Soll      -0      -0      -0,3333 -0,2083  0      0,2917  0,6667  3
Ist        0       0       0       0       0      0       0       0
```

## Nachstellen

```bash
python3 modelle_bauen.py            # legt nur_*.onnx an (braucht onnx)
flutter create probe && cd probe
flutter pub add flutter_onnxruntime
flutter pub add dev:integration_test --sdk flutter
cp ../hardswish_test.dart integration_test/
flutter test integration_test/hardswish_test.dart -d linux
```

Der Test legt die Modelle unter `$HOME/ocr_modelle/` ab und erwartet sie
dort.

## Umfang

Betroffen ist **nur** `HardSwish`. Im selben Prozess rechnen richtig:
`HardSigmoid`, `Sigmoid`, `Relu`, `Elu`, `Softplus`, `Celu`, `Mish` –
darunter mit `Celu` und `Mish` zwei, die in ONNX ebenfalls über eine
Funktionsdefinition beschrieben sind.

## Was ausgeschlossen wurde

| Verdacht | Prüfung | Ergebnis |
|---|---|---|
| Anbindung des Plugins | eigenständige C++-Inferenz *im* Flutter-Prozess, ohne Plugin-Code | gleicher Fehler |
| Umgebung, Grenzen, Verzeichnis | Kindprozess derselben App | rechnet richtig |
| die Anwendung selbst | blanke `flutter create`-App, nur dieses Plugin | gleicher Fehler |
| Symbolüberlagerung | alle 272 Bibliotheken des Prozesses vorgeladen, ORT zuletzt | ohne Wirkung |
| Rechenfäden | ein Faden, serielle Ausführung; frisch gestarteter Faden | gleicher Fehler |
| Speichermuster, Vorpacken | `DisableMemPattern`, `DisableCpuMemArena`, `session.disable_prepacking` | gleicher Fehler |
| Graphoptimierung | `ORT_DISABLE_ALL` | gleicher Fehler |
| ORT-Fassung | 1.22.0 und 1.23.0 | beide betroffen |
| Grösse des Tensors | 1 bis 1024 Werte | schon bei einem Wert falsch |
| Gleitkomma-Zustand | MXCSR gelesen | 0x1fa0, unauffällig |

## Umgebung

Ubuntu 25.10 (Kernel 7.0), x86-64, Flutter 3.44.8,
`flutter_onnxruntime` 1.8.3, ONNX Runtime 1.22.0 (Linux-x64-Paket des
Plugins), Modelle mit Opset 14.

## Auswirkung

Jedes Modell mit einem MobileNetV3-Stamm ist unbrauchbar. Konkret
betrifft es hier die Texterkennung: Das PP-OCR-Lesemodell enthält
27 `HardSwish`-Knoten; ab dem ersten ist die weitere Rechnung wertlos.
Der Ausgabewert hängt danach weder von den Bilddaten noch von der Form
des Eingabetensors ab – ein Fehlerbild, das leicht als „die Eingabe
kommt nicht an" fehlgedeutet wird.

## Umgehung in dieser App

`HardSwish(x)` ist per ONNX-Definition genau
`x · HardSigmoid(x; α = 1/6, β = 0,5)`, und beide Schritte rechnen
richtig. `lib/services/onnx_hardswish.dart` schreibt die Knoten beim
ersten Laden entsprechend um. Gegengerechnet mit `onnxruntime`: grösste
Abweichung 0,000.

Das behebt den Fehler nicht, es geht ihm aus dem Weg – und nur für dieses
eine Modell. Jedes andere Modell mit MobileNetV3-Stamm ist weiterhin
betroffen.
