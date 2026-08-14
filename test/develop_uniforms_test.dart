import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/native_image_converter.dart';
import 'package:photo_vault/widgets/develop_preview.dart';

/// Prüft die Übersetzung der Regler in Shader-Uniforms. Reine Rechenlogik,
/// deshalb ohne GPU testbar – die tatsächliche Darstellung wird separat per
/// Pixelmessung geprüft.
void main() {
  test('neutrale Einstellungen ergeben neutrale Uniforms', () {
    final u = developUniforms(DevelopAdjustments.neutral);

    expect(u, hasLength(6));
    expect(u[0], 0.0, reason: 'Belichtung');
    expect(u[3], 0.0, reason: 'Kontrast');
    expect(u[4], 0.0, reason: 'Schatten');
  });

  test('automatischer Weißabgleich schaltet den Shader-Weißabgleich ab', () {
    // temperature == null bedeutet Automatik (siehe DevelopAdjustments).
    final u = developUniforms(const DevelopAdjustments(
      exposure: 0,
      temperature: null,
      tint: null,
      contrast: 0,
      shadows: 0,
      sharpness: 0,
      noiseReduction: 0,
    ));

    expect(u[5], 0.0, reason: 'Weißabgleich muss aus sein');
    // Der Platzhalterwert darf trotzdem gültig sein, damit der Shader nicht
    // mit NaN/0 Kelvin rechnet, falls das Flag je ignoriert würde.
    expect(u[1], 6500.0);
    expect(u[2], 0.0);
  });

  test('manueller Weißabgleich wird durchgereicht und aktiviert', () {
    final u = developUniforms(const DevelopAdjustments(
      exposure: 0,
      temperature: 3200,
      tint: -25,
      contrast: 0,
      shadows: 0,
      sharpness: 0,
      noiseReduction: 0,
    ));

    expect(u[1], 3200.0);
    expect(u[2], -25.0);
    expect(u[5], 1.0, reason: 'Weißabgleich muss an sein');
  });

  test('alle Regler landen an der richtigen Stelle', () {
    // Bewusst paarweise verschiedene Werte: eine vertauschte Zuordnung
    // fiele bei gleichen Werten nicht auf.
    final u = developUniforms(const DevelopAdjustments(
      exposure: 1.5,
      temperature: 8000,
      tint: 40,
      contrast: -0.25,
      shadows: 0.75,
      sharpness: 0.5,
      noiseReduction: 0.5,
    ));

    expect(u[0], 1.5, reason: 'Belichtung');
    expect(u[1], 8000.0, reason: 'Temperatur');
    expect(u[2], 40.0, reason: 'Tint');
    expect(u[3], -0.25, reason: 'Kontrast');
    expect(u[4], 0.75, reason: 'Schatten');
  });

  test('Schärfe und Rauschunterdrückung erscheinen NICHT in den Uniforms', () {
    // Sie sind bewusst nicht Teil der Live-Vorschau (siehe Shader-Kopf) –
    // dieser Test hält das fest, damit es nicht versehentlich "repariert"
    // wird, ohne den Shader anzupassen.
    final ohne = developUniforms(DevelopAdjustments.neutral);
    final mit = developUniforms(const DevelopAdjustments(
      exposure: 0,
      temperature: null,
      tint: null,
      contrast: 0,
      shadows: 0,
      sharpness: 1.0,
      noiseReduction: 1.0,
    ));

    expect(mit, ohne, reason: 'dürfen die Uniforms nicht verändern');
  });

  test('Grenzwerte werden unverändert weitergegeben', () {
    // Das Begrenzen übernimmt der Shader (clamp), nicht diese Funktion –
    // so bleibt eine Stelle dafür zuständig.
    final u = developUniforms(const DevelopAdjustments(
      exposure: -3,
      temperature: 12000,
      tint: 100,
      contrast: 1,
      shadows: -1,
      sharpness: 0,
      noiseReduction: 0,
    ));

    expect(u[0], -3.0);
    expect(u[1], 12000.0);
    expect(u[2], 100.0);
    expect(u[3], 1.0);
    expect(u[4], -1.0);
  });
}
