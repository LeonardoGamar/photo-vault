import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  /// Gesetzt, sobald das Schliessen freigegeben ist – siehe
  /// [windowShouldClose].
  private var darfSchliessen = false

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
      ImageConverterChannel.register(with: flutterViewController.registrar(forPlugin: "ImageConverter"))
      LibraryLocationChannel.register(with: flutterViewController.registrar(forPlugin: "LibraryLocation"))
      BeendenChannel.register(with: flutterViewController.registrar(forPlugin: "Beenden"))

    // Das Fenster ist sein eigener Delegierter, damit der rote Schliessknopf
    // dieselbe Rückfrage auslöst wie Cmd-Q. Über
    // `applicationShouldTerminate` allein käme sie zu spät: Das Fenster wäre
    // dann bereits zu, und ein Abbrechen liesse die App ohne Fenster
    // zurück.
    self.delegate = self

    super.awakeFromNib()
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    if darfSchliessen { return true }
    BeendenChannel.frage { erlaubt in
      guard erlaubt else { return }
      self.darfSchliessen = true
      // Zurückgestellt, weil `frage` auch synchron antworten kann – ein
      // `close()` mitten in `windowShouldClose` wäre ein Aufruf in sich
      // selbst hinein.
      DispatchQueue.main.async { self.close() }
    }
    return false
  }
}
