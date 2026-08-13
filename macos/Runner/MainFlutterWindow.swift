import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
      ImageConverterChannel.register(with: flutterViewController.registrar(forPlugin: "ImageConverter"))
      LibraryLocationChannel.register(with: flutterViewController.registrar(forPlugin: "LibraryLocation"))
    super.awakeFromNib()
  }
}
