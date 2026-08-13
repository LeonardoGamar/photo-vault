/// Bedeutung des freien Textfelds im Suchoptionen-Panel – exklusiv wählbar,
/// analog zu Immichs "Suche nach Typ". "Voller Ordnerpfad oder Ordner" fehlt
/// bewusst: passt nicht zu PhotoVaults Datenmodell (die App organisiert die
/// Bibliothek selbst, es gibt keine vom Nutzer sichtbaren Ordner).
enum SearchTextMode { context, filename, description, ocr, caption }

enum MediaTypeFilter { all, image, video }

/// Bündelt alle Filter des Suchoptionen-Panels. Unveränderlich – Änderungen
/// laufen über [copyWith], damit der Panel-Zustand sich wie ein einzelner
/// Wert handhaben lässt.
class SearchFilters {
  final List<String> personIds;
  final SearchTextMode textMode;
  final String query;
  final List<String> tagIds;
  final bool noTag;
  final String? cameraMake;
  final String? cameraModel;
  final String? lensModel;
  final String? locationCountry;
  final String? locationState;
  final String? locationCity;
  final DateTime? startDate;
  final DateTime? endDate;
  final MediaTypeFilter mediaType;
  final bool favoritesOnly;
  final bool notInAnyAlbum;
  final int? minRating;
  final Set<String> colorLabels;
  final int? minIso;
  final int? maxIso;
  final double? minFNumber;
  final double? maxFNumber;
  final double? minFocalLengthMm;
  final double? maxFocalLengthMm;

  /// "Nur unscharfe anzeigen" – Fotos mit `sharpnessScore <= maxSharpnessScore`.
  final double? maxSharpnessScore;

  const SearchFilters({
    this.personIds = const [],
    this.textMode = SearchTextMode.context,
    this.query = '',
    this.tagIds = const [],
    this.noTag = false,
    this.cameraMake,
    this.cameraModel,
    this.lensModel,
    this.locationCountry,
    this.locationState,
    this.locationCity,
    this.startDate,
    this.endDate,
    this.mediaType = MediaTypeFilter.all,
    this.favoritesOnly = false,
    this.notInAnyAlbum = false,
    this.minRating,
    this.colorLabels = const {},
    this.minIso,
    this.maxIso,
    this.minFNumber,
    this.maxFNumber,
    this.minFocalLengthMm,
    this.maxFocalLengthMm,
    this.maxSharpnessScore,
  });

  bool get isEmpty =>
      personIds.isEmpty &&
      query.trim().isEmpty &&
      tagIds.isEmpty &&
      !noTag &&
      cameraMake == null &&
      cameraModel == null &&
      lensModel == null &&
      locationCountry == null &&
      locationState == null &&
      locationCity == null &&
      startDate == null &&
      endDate == null &&
      mediaType == MediaTypeFilter.all &&
      !favoritesOnly &&
      !notInAnyAlbum &&
      minRating == null &&
      colorLabels.isEmpty &&
      minIso == null &&
      maxIso == null &&
      minFNumber == null &&
      maxFNumber == null &&
      minFocalLengthMm == null &&
      maxFocalLengthMm == null &&
      maxSharpnessScore == null;

  /// Da `null` bei den optionalen String-/Zahlen-Feldern eine gültige
  /// Bedeutung hat ("kein Filter"), braucht `copyWith` für sie explizite
  /// "soll gelöscht werden"-Flags statt einfach `value ?? oldValue` – sonst
  /// ließe sich ein einmal gesetzter Filter nie wieder entfernen.
  SearchFilters copyWith({
    List<String>? personIds,
    SearchTextMode? textMode,
    String? query,
    List<String>? tagIds,
    bool? noTag,
    String? cameraMake,
    bool clearCameraMake = false,
    String? cameraModel,
    bool clearCameraModel = false,
    String? lensModel,
    bool clearLensModel = false,
    String? locationCountry,
    bool clearLocationCountry = false,
    String? locationState,
    bool clearLocationState = false,
    String? locationCity,
    bool clearLocationCity = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    MediaTypeFilter? mediaType,
    bool? favoritesOnly,
    bool? notInAnyAlbum,
    int? minRating,
    bool clearMinRating = false,
    Set<String>? colorLabels,
    int? minIso,
    bool clearMinIso = false,
    int? maxIso,
    bool clearMaxIso = false,
    double? minFNumber,
    bool clearMinFNumber = false,
    double? maxFNumber,
    bool clearMaxFNumber = false,
    double? minFocalLengthMm,
    bool clearMinFocalLengthMm = false,
    double? maxFocalLengthMm,
    bool clearMaxFocalLengthMm = false,
    double? maxSharpnessScore,
    bool clearMaxSharpnessScore = false,
  }) {
    return SearchFilters(
      personIds: personIds ?? this.personIds,
      textMode: textMode ?? this.textMode,
      query: query ?? this.query,
      tagIds: tagIds ?? this.tagIds,
      noTag: noTag ?? this.noTag,
      cameraMake: clearCameraMake ? null : (cameraMake ?? this.cameraMake),
      cameraModel: clearCameraModel ? null : (cameraModel ?? this.cameraModel),
      lensModel: clearLensModel ? null : (lensModel ?? this.lensModel),
      locationCountry: clearLocationCountry ? null : (locationCountry ?? this.locationCountry),
      locationState: clearLocationState ? null : (locationState ?? this.locationState),
      locationCity: clearLocationCity ? null : (locationCity ?? this.locationCity),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      mediaType: mediaType ?? this.mediaType,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      notInAnyAlbum: notInAnyAlbum ?? this.notInAnyAlbum,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      colorLabels: colorLabels ?? this.colorLabels,
      minIso: clearMinIso ? null : (minIso ?? this.minIso),
      maxIso: clearMaxIso ? null : (maxIso ?? this.maxIso),
      minFNumber: clearMinFNumber ? null : (minFNumber ?? this.minFNumber),
      maxFNumber: clearMaxFNumber ? null : (maxFNumber ?? this.maxFNumber),
      minFocalLengthMm: clearMinFocalLengthMm ? null : (minFocalLengthMm ?? this.minFocalLengthMm),
      maxFocalLengthMm: clearMaxFocalLengthMm ? null : (maxFocalLengthMm ?? this.maxFocalLengthMm),
      maxSharpnessScore: clearMaxSharpnessScore ? null : (maxSharpnessScore ?? this.maxSharpnessScore),
    );
  }

  /// Für "Gespeicherte Suchen" (siehe AppDatabase.createSavedSearch): der
  /// komplette Filter-Zustand wird als JSON in der DB abgelegt, statt (wie
  /// ein normales Album) eine feste Foto-Liste zu speichern – beim erneuten
  /// Öffnen läuft die Suche live gegen die aktuelle Bibliothek.
  Map<String, dynamic> toJson() => {
        'personIds': personIds,
        'textMode': textMode.name,
        'query': query,
        'tagIds': tagIds,
        'noTag': noTag,
        'cameraMake': cameraMake,
        'cameraModel': cameraModel,
        'lensModel': lensModel,
        'locationCountry': locationCountry,
        'locationState': locationState,
        'locationCity': locationCity,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'mediaType': mediaType.name,
        'favoritesOnly': favoritesOnly,
        'notInAnyAlbum': notInAnyAlbum,
        'minRating': minRating,
        'colorLabels': colorLabels.toList(),
        'minIso': minIso,
        'maxIso': maxIso,
        'minFNumber': minFNumber,
        'maxFNumber': maxFNumber,
        'minFocalLengthMm': minFocalLengthMm,
        'maxFocalLengthMm': maxFocalLengthMm,
        'maxSharpnessScore': maxSharpnessScore,
      };

  factory SearchFilters.fromJson(Map<String, dynamic> json) => SearchFilters(
        personIds: (json['personIds'] as List<dynamic>? ?? const []).cast<String>(),
        textMode: SearchTextMode.values.byName(json['textMode'] as String? ?? 'context'),
        query: json['query'] as String? ?? '',
        tagIds: (json['tagIds'] as List<dynamic>? ?? const []).cast<String>(),
        noTag: json['noTag'] as bool? ?? false,
        cameraMake: json['cameraMake'] as String?,
        cameraModel: json['cameraModel'] as String?,
        lensModel: json['lensModel'] as String?,
        locationCountry: json['locationCountry'] as String?,
        locationState: json['locationState'] as String?,
        locationCity: json['locationCity'] as String?,
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        mediaType: MediaTypeFilter.values.byName(json['mediaType'] as String? ?? 'all'),
        favoritesOnly: json['favoritesOnly'] as bool? ?? false,
        notInAnyAlbum: json['notInAnyAlbum'] as bool? ?? false,
        minRating: json['minRating'] as int?,
        colorLabels: (json['colorLabels'] as List<dynamic>? ?? const []).cast<String>().toSet(),
        minIso: json['minIso'] as int?,
        maxIso: json['maxIso'] as int?,
        minFNumber: (json['minFNumber'] as num?)?.toDouble(),
        maxFNumber: (json['maxFNumber'] as num?)?.toDouble(),
        minFocalLengthMm: (json['minFocalLengthMm'] as num?)?.toDouble(),
        maxFocalLengthMm: (json['maxFocalLengthMm'] as num?)?.toDouble(),
        maxSharpnessScore: (json['maxSharpnessScore'] as num?)?.toDouble(),
      );
}
