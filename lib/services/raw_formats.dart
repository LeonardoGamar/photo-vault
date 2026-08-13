/// Dateiendungen, die macOS' ImageIO/CIRAWFilter systemweit als
/// Hersteller-RAW-Formate erkennt (unabhängig vom Kamerahersteller) – über
/// dieselbe API, mit der z.B. auch die Finder-Vorschau und Fotos.app RAW-
/// Dateien lesen. Einzige Quelle der Wahrheit für "welche Endungen gelten
/// als RAW" – wird von ImportService, NativeImageConverter und dem
/// Datei-Auswahldialog importiert, damit sie nicht auseinanderlaufen
/// können. Die Swift-Seite (ImageConverter.swift) muss diese Liste von
/// Hand gespiegelt halten, da sie nicht direkt importierbar ist.
const rawImageExtensions = {
  '.dng', '.cr2', '.cr3', '.crw', // Canon (+ Adobe DNG, iPhone DNG)
  '.nef', '.nrw', '.nefx', // Nikon
  '.arw', '.sr2', '.srf', '.axr', // Sony
  '.raf', // Fujifilm
  '.orf', // Olympus/OM System
  '.rw2', // Panasonic
  '.pef', // Pentax
  '.3fr', '.fff', // Hasselblad
  '.iiq', // Phase One
  '.dcr', // Kodak
  '.mrw', // Minolta
  '.mos', // Leaf
  '.srw', // Samsung
  '.erf', // Epson
  '.rwl', '.raw', // Leica
  '.dxo', // DxO
};
