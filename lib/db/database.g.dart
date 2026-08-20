// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AssetsTable extends Assets with TableInfo<$AssetsTable, AssetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalFileNameMeta =
      const VerificationMeta('originalFileName');
  @override
  late final GeneratedColumn<String> originalFileName = GeneratedColumn<String>(
      'original_file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relativePathMeta =
      const VerificationMeta('relativePath');
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
      'relative_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailRelativePathMeta =
      const VerificationMeta('thumbnailRelativePath');
  @override
  late final GeneratedColumn<String> thumbnailRelativePath =
      GeneratedColumn<String>('thumbnail_relative_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _previewRelativePathMeta =
      const VerificationMeta('previewRelativePath');
  @override
  late final GeneratedColumn<String> previewRelativePath =
      GeneratedColumn<String>('preview_relative_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _developedRelativePathMeta =
      const VerificationMeta('developedRelativePath');
  @override
  late final GeneratedColumn<String> developedRelativePath =
      GeneratedColumn<String>('developed_relative_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trimmedRelativePathMeta =
      const VerificationMeta('trimmedRelativePath');
  @override
  late final GeneratedColumn<String> trimmedRelativePath =
      GeneratedColumn<String>('trimmed_relative_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _restoredRelativePathMeta =
      const VerificationMeta('restoredRelativePath');
  @override
  late final GeneratedColumn<String> restoredRelativePath =
      GeneratedColumn<String>('restored_relative_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileCreatedAtMeta =
      const VerificationMeta('fileCreatedAt');
  @override
  late final GeneratedColumn<DateTime> fileCreatedAt =
      GeneratedColumn<DateTime>('file_created_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _importedAtMeta =
      const VerificationMeta('importedAt');
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
      'imported_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isTrashedMeta =
      const VerificationMeta('isTrashed');
  @override
  late final GeneratedColumn<bool> isTrashed = GeneratedColumn<bool>(
      'is_trashed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_trashed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _trashedAtMeta =
      const VerificationMeta('trashedAt');
  @override
  late final GeneratedColumn<DateTime> trashedAt = GeneratedColumn<DateTime>(
      'trashed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _widthPxMeta =
      const VerificationMeta('widthPx');
  @override
  late final GeneratedColumn<int> widthPx = GeneratedColumn<int>(
      'width_px', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightPxMeta =
      const VerificationMeta('heightPx');
  @override
  late final GeneratedColumn<int> heightPx = GeneratedColumn<int>(
      'height_px', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
      'duration_seconds', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _backedUpMeta =
      const VerificationMeta('backedUp');
  @override
  late final GeneratedColumn<bool> backedUp = GeneratedColumn<bool>(
      'backed_up', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("backed_up" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autoBackedUpMeta =
      const VerificationMeta('autoBackedUp');
  @override
  late final GeneratedColumn<bool> autoBackedUp = GeneratedColumn<bool>(
      'auto_backed_up', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_backed_up" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _facesScannedMeta =
      const VerificationMeta('facesScanned');
  @override
  late final GeneratedColumn<bool> facesScanned = GeneratedColumn<bool>(
      'faces_scanned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("faces_scanned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _linkedAssetIdMeta =
      const VerificationMeta('linkedAssetId');
  @override
  late final GeneratedColumn<String> linkedAssetId = GeneratedColumn<String>(
      'linked_asset_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _cameraMakeMeta =
      const VerificationMeta('cameraMake');
  @override
  late final GeneratedColumn<String> cameraMake = GeneratedColumn<String>(
      'camera_make', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cameraModelMeta =
      const VerificationMeta('cameraModel');
  @override
  late final GeneratedColumn<String> cameraModel = GeneratedColumn<String>(
      'camera_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lensModelMeta =
      const VerificationMeta('lensModel');
  @override
  late final GeneratedColumn<String> lensModel = GeneratedColumn<String>(
      'lens_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _focalLengthMmMeta =
      const VerificationMeta('focalLengthMm');
  @override
  late final GeneratedColumn<double> focalLengthMm = GeneratedColumn<double>(
      'focal_length_mm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fNumberMeta =
      const VerificationMeta('fNumber');
  @override
  late final GeneratedColumn<double> fNumber = GeneratedColumn<double>(
      'f_number', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isoMeta = const VerificationMeta('iso');
  @override
  late final GeneratedColumn<int> iso = GeneratedColumn<int>(
      'iso', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _exposureTimeSecondsMeta =
      const VerificationMeta('exposureTimeSeconds');
  @override
  late final GeneratedColumn<double> exposureTimeSeconds =
      GeneratedColumn<double>('exposure_time_seconds', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exposureBiasEvMeta =
      const VerificationMeta('exposureBiasEv');
  @override
  late final GeneratedColumn<double> exposureBiasEv = GeneratedColumn<double>(
      'exposure_bias_ev', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _focalLength35mmMeta =
      const VerificationMeta('focalLength35mm');
  @override
  late final GeneratedColumn<double> focalLength35mm = GeneratedColumn<double>(
      'focal_length35mm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _locationCountryMeta =
      const VerificationMeta('locationCountry');
  @override
  late final GeneratedColumn<String> locationCountry = GeneratedColumn<String>(
      'location_country', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationStateMeta =
      const VerificationMeta('locationState');
  @override
  late final GeneratedColumn<String> locationState = GeneratedColumn<String>(
      'location_state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationCityMeta =
      const VerificationMeta('locationCity');
  @override
  late final GeneratedColumn<String> locationCity = GeneratedColumn<String>(
      'location_city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _colorLabelMeta =
      const VerificationMeta('colorLabel');
  @override
  late final GeneratedColumn<String> colorLabel = GeneratedColumn<String>(
      'color_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ocrTextMeta =
      const VerificationMeta('ocrText');
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
      'ocr_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ocrScannedMeta =
      const VerificationMeta('ocrScanned');
  @override
  late final GeneratedColumn<bool> ocrScanned = GeneratedColumn<bool>(
      'ocr_scanned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ocr_scanned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _aiCaptionMeta =
      const VerificationMeta('aiCaption');
  @override
  late final GeneratedColumn<String> aiCaption = GeneratedColumn<String>(
      'ai_caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiCaptionDeMeta =
      const VerificationMeta('aiCaptionDe');
  @override
  late final GeneratedColumn<String> aiCaptionDe = GeneratedColumn<String>(
      'ai_caption_de', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiCaptionScannedMeta =
      const VerificationMeta('aiCaptionScanned');
  @override
  late final GeneratedColumn<bool> aiCaptionScanned = GeneratedColumn<bool>(
      'ai_caption_scanned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ai_caption_scanned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _aiCaptionEditedMeta =
      const VerificationMeta('aiCaptionEdited');
  @override
  late final GeneratedColumn<bool> aiCaptionEdited = GeneratedColumn<bool>(
      'ai_caption_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ai_caption_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _aiTagsScannedMeta =
      const VerificationMeta('aiTagsScanned');
  @override
  late final GeneratedColumn<bool> aiTagsScanned = GeneratedColumn<bool>(
      'ai_tags_scanned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ai_tags_scanned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sharpnessScoreMeta =
      const VerificationMeta('sharpnessScore');
  @override
  late final GeneratedColumn<double> sharpnessScore = GeneratedColumn<double>(
      'sharpness_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _stackIdMeta =
      const VerificationMeta('stackId');
  @override
  late final GeneratedColumn<String> stackId = GeneratedColumn<String>(
      'stack_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isStackCoverMeta =
      const VerificationMeta('isStackCover');
  @override
  late final GeneratedColumn<bool> isStackCover = GeneratedColumn<bool>(
      'is_stack_cover', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_stack_cover" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _stackSizeMeta =
      const VerificationMeta('stackSize');
  @override
  late final GeneratedColumn<int> stackSize = GeneratedColumn<int>(
      'stack_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        originalFileName,
        relativePath,
        thumbnailRelativePath,
        previewRelativePath,
        developedRelativePath,
        trimmedRelativePath,
        restoredRelativePath,
        checksum,
        type,
        fileCreatedAt,
        importedAt,
        isFavorite,
        isTrashed,
        trashedAt,
        isLocked,
        description,
        widthPx,
        heightPx,
        durationSeconds,
        fileSizeBytes,
        backedUp,
        autoBackedUp,
        facesScanned,
        linkedAssetId,
        latitude,
        longitude,
        cameraMake,
        cameraModel,
        lensModel,
        focalLengthMm,
        fNumber,
        iso,
        exposureTimeSeconds,
        exposureBiasEv,
        focalLength35mm,
        locationCountry,
        locationState,
        locationCity,
        rating,
        colorLabel,
        ocrText,
        ocrScanned,
        aiCaption,
        aiCaptionDe,
        aiCaptionScanned,
        aiCaptionEdited,
        aiTagsScanned,
        sharpnessScore,
        stackId,
        isStackCover,
        stackSize
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(Insertable<AssetData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('original_file_name')) {
      context.handle(
          _originalFileNameMeta,
          originalFileName.isAcceptableOrUnknown(
              data['original_file_name']!, _originalFileNameMeta));
    } else if (isInserting) {
      context.missing(_originalFileNameMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
          _relativePathMeta,
          relativePath.isAcceptableOrUnknown(
              data['relative_path']!, _relativePathMeta));
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('thumbnail_relative_path')) {
      context.handle(
          _thumbnailRelativePathMeta,
          thumbnailRelativePath.isAcceptableOrUnknown(
              data['thumbnail_relative_path']!, _thumbnailRelativePathMeta));
    }
    if (data.containsKey('preview_relative_path')) {
      context.handle(
          _previewRelativePathMeta,
          previewRelativePath.isAcceptableOrUnknown(
              data['preview_relative_path']!, _previewRelativePathMeta));
    }
    if (data.containsKey('developed_relative_path')) {
      context.handle(
          _developedRelativePathMeta,
          developedRelativePath.isAcceptableOrUnknown(
              data['developed_relative_path']!, _developedRelativePathMeta));
    }
    if (data.containsKey('trimmed_relative_path')) {
      context.handle(
          _trimmedRelativePathMeta,
          trimmedRelativePath.isAcceptableOrUnknown(
              data['trimmed_relative_path']!, _trimmedRelativePathMeta));
    }
    if (data.containsKey('restored_relative_path')) {
      context.handle(
          _restoredRelativePathMeta,
          restoredRelativePath.isAcceptableOrUnknown(
              data['restored_relative_path']!, _restoredRelativePathMeta));
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_created_at')) {
      context.handle(
          _fileCreatedAtMeta,
          fileCreatedAt.isAcceptableOrUnknown(
              data['file_created_at']!, _fileCreatedAtMeta));
    } else if (isInserting) {
      context.missing(_fileCreatedAtMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
          _importedAtMeta,
          importedAt.isAcceptableOrUnknown(
              data['imported_at']!, _importedAtMeta));
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_trashed')) {
      context.handle(_isTrashedMeta,
          isTrashed.isAcceptableOrUnknown(data['is_trashed']!, _isTrashedMeta));
    }
    if (data.containsKey('trashed_at')) {
      context.handle(_trashedAtMeta,
          trashedAt.isAcceptableOrUnknown(data['trashed_at']!, _trashedAtMeta));
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('width_px')) {
      context.handle(_widthPxMeta,
          widthPx.isAcceptableOrUnknown(data['width_px']!, _widthPxMeta));
    }
    if (data.containsKey('height_px')) {
      context.handle(_heightPxMeta,
          heightPx.isAcceptableOrUnknown(data['height_px']!, _heightPxMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('backed_up')) {
      context.handle(_backedUpMeta,
          backedUp.isAcceptableOrUnknown(data['backed_up']!, _backedUpMeta));
    }
    if (data.containsKey('auto_backed_up')) {
      context.handle(
          _autoBackedUpMeta,
          autoBackedUp.isAcceptableOrUnknown(
              data['auto_backed_up']!, _autoBackedUpMeta));
    }
    if (data.containsKey('faces_scanned')) {
      context.handle(
          _facesScannedMeta,
          facesScanned.isAcceptableOrUnknown(
              data['faces_scanned']!, _facesScannedMeta));
    }
    if (data.containsKey('linked_asset_id')) {
      context.handle(
          _linkedAssetIdMeta,
          linkedAssetId.isAcceptableOrUnknown(
              data['linked_asset_id']!, _linkedAssetIdMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('camera_make')) {
      context.handle(
          _cameraMakeMeta,
          cameraMake.isAcceptableOrUnknown(
              data['camera_make']!, _cameraMakeMeta));
    }
    if (data.containsKey('camera_model')) {
      context.handle(
          _cameraModelMeta,
          cameraModel.isAcceptableOrUnknown(
              data['camera_model']!, _cameraModelMeta));
    }
    if (data.containsKey('lens_model')) {
      context.handle(_lensModelMeta,
          lensModel.isAcceptableOrUnknown(data['lens_model']!, _lensModelMeta));
    }
    if (data.containsKey('focal_length_mm')) {
      context.handle(
          _focalLengthMmMeta,
          focalLengthMm.isAcceptableOrUnknown(
              data['focal_length_mm']!, _focalLengthMmMeta));
    }
    if (data.containsKey('f_number')) {
      context.handle(_fNumberMeta,
          fNumber.isAcceptableOrUnknown(data['f_number']!, _fNumberMeta));
    }
    if (data.containsKey('iso')) {
      context.handle(
          _isoMeta, iso.isAcceptableOrUnknown(data['iso']!, _isoMeta));
    }
    if (data.containsKey('exposure_time_seconds')) {
      context.handle(
          _exposureTimeSecondsMeta,
          exposureTimeSeconds.isAcceptableOrUnknown(
              data['exposure_time_seconds']!, _exposureTimeSecondsMeta));
    }
    if (data.containsKey('exposure_bias_ev')) {
      context.handle(
          _exposureBiasEvMeta,
          exposureBiasEv.isAcceptableOrUnknown(
              data['exposure_bias_ev']!, _exposureBiasEvMeta));
    }
    if (data.containsKey('focal_length35mm')) {
      context.handle(
          _focalLength35mmMeta,
          focalLength35mm.isAcceptableOrUnknown(
              data['focal_length35mm']!, _focalLength35mmMeta));
    }
    if (data.containsKey('location_country')) {
      context.handle(
          _locationCountryMeta,
          locationCountry.isAcceptableOrUnknown(
              data['location_country']!, _locationCountryMeta));
    }
    if (data.containsKey('location_state')) {
      context.handle(
          _locationStateMeta,
          locationState.isAcceptableOrUnknown(
              data['location_state']!, _locationStateMeta));
    }
    if (data.containsKey('location_city')) {
      context.handle(
          _locationCityMeta,
          locationCity.isAcceptableOrUnknown(
              data['location_city']!, _locationCityMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('color_label')) {
      context.handle(
          _colorLabelMeta,
          colorLabel.isAcceptableOrUnknown(
              data['color_label']!, _colorLabelMeta));
    }
    if (data.containsKey('ocr_text')) {
      context.handle(_ocrTextMeta,
          ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta));
    }
    if (data.containsKey('ocr_scanned')) {
      context.handle(
          _ocrScannedMeta,
          ocrScanned.isAcceptableOrUnknown(
              data['ocr_scanned']!, _ocrScannedMeta));
    }
    if (data.containsKey('ai_caption')) {
      context.handle(_aiCaptionMeta,
          aiCaption.isAcceptableOrUnknown(data['ai_caption']!, _aiCaptionMeta));
    }
    if (data.containsKey('ai_caption_de')) {
      context.handle(
          _aiCaptionDeMeta,
          aiCaptionDe.isAcceptableOrUnknown(
              data['ai_caption_de']!, _aiCaptionDeMeta));
    }
    if (data.containsKey('ai_caption_scanned')) {
      context.handle(
          _aiCaptionScannedMeta,
          aiCaptionScanned.isAcceptableOrUnknown(
              data['ai_caption_scanned']!, _aiCaptionScannedMeta));
    }
    if (data.containsKey('ai_caption_edited')) {
      context.handle(
          _aiCaptionEditedMeta,
          aiCaptionEdited.isAcceptableOrUnknown(
              data['ai_caption_edited']!, _aiCaptionEditedMeta));
    }
    if (data.containsKey('ai_tags_scanned')) {
      context.handle(
          _aiTagsScannedMeta,
          aiTagsScanned.isAcceptableOrUnknown(
              data['ai_tags_scanned']!, _aiTagsScannedMeta));
    }
    if (data.containsKey('sharpness_score')) {
      context.handle(
          _sharpnessScoreMeta,
          sharpnessScore.isAcceptableOrUnknown(
              data['sharpness_score']!, _sharpnessScoreMeta));
    }
    if (data.containsKey('stack_id')) {
      context.handle(_stackIdMeta,
          stackId.isAcceptableOrUnknown(data['stack_id']!, _stackIdMeta));
    }
    if (data.containsKey('is_stack_cover')) {
      context.handle(
          _isStackCoverMeta,
          isStackCover.isAcceptableOrUnknown(
              data['is_stack_cover']!, _isStackCoverMeta));
    }
    if (data.containsKey('stack_size')) {
      context.handle(_stackSizeMeta,
          stackSize.isAcceptableOrUnknown(data['stack_size']!, _stackSizeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      originalFileName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_file_name'])!,
      relativePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relative_path'])!,
      thumbnailRelativePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}thumbnail_relative_path']),
      previewRelativePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preview_relative_path']),
      developedRelativePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}developed_relative_path']),
      trimmedRelativePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}trimmed_relative_path']),
      restoredRelativePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}restored_relative_path']),
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      fileCreatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}file_created_at'])!,
      importedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}imported_at'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isTrashed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_trashed'])!,
      trashedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}trashed_at']),
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      widthPx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width_px']),
      heightPx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height_px']),
      durationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}duration_seconds']),
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      backedUp: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}backed_up'])!,
      autoBackedUp: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_backed_up'])!,
      facesScanned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}faces_scanned'])!,
      linkedAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_asset_id']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      cameraMake: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}camera_make']),
      cameraModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}camera_model']),
      lensModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lens_model']),
      focalLengthMm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}focal_length_mm']),
      fNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}f_number']),
      iso: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}iso']),
      exposureTimeSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}exposure_time_seconds']),
      exposureBiasEv: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}exposure_bias_ev']),
      focalLength35mm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}focal_length35mm']),
      locationCountry: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}location_country']),
      locationState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_state']),
      locationCity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_city']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      colorLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_label']),
      ocrText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ocr_text']),
      ocrScanned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ocr_scanned'])!,
      aiCaption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_caption']),
      aiCaptionDe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_caption_de']),
      aiCaptionScanned: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}ai_caption_scanned'])!,
      aiCaptionEdited: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}ai_caption_edited'])!,
      aiTagsScanned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ai_tags_scanned'])!,
      sharpnessScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sharpness_score']),
      stackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stack_id']),
      isStackCover: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_stack_cover'])!,
      stackSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stack_size']),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class AssetData extends DataClass implements Insertable<AssetData> {
  final String id;
  final String originalFileName;
  final String relativePath;
  final String? thumbnailRelativePath;
  final String? previewRelativePath;

  /// Ergebnis der nicht-destruktiven Entwicklung (siehe DevelopSettings) –
  /// nur gesetzt, solange der Nutzer tatsächlich Anpassungen vorgenommen
  /// hat. Null bedeutet "unverändert", nicht "fehlt" – dann wird
  /// [previewRelativePath] bzw. [relativePath] angezeigt. Bewusst NICHT für
  /// Gesichtserkennung/CLIP verwendet (siehe LibraryState._decodableFile) –
  /// KI-Verarbeitung soll immer das unveränderte Bild sehen.
  final String? developedRelativePath;

  /// Ergebnis des nicht-destruktiven Video-Zuschnitts (siehe VideoTrims) –
  /// analog zu [developedRelativePath]: null bedeutet "unverändert", die
  /// Original-Videodatei wird nie angetastet. Für IMAGE-Assets stets null,
  /// da sich die beiden Felder gegenseitig ausschließen (ein Asset ist
  /// entweder Foto oder Video).
  final String? trimmedRelativePath;

  /// Ergebnis einer KI-Restaurierung (Hochskalieren/Entrauschen, siehe
  /// RestoreJobs/RestoreQueueService) – analog zu [developedRelativePath]:
  /// null bedeutet "keine Restaurierung vorhanden". Höchste Priorität in
  /// displayRelativePath (siehe asset_display_path.dart), da sie – anders
  /// als [developedRelativePath] – ein bewusst einmalig angestoßenes,
  /// abgeschlossenes Ergebnis ist, kein live nachregelbarer Zustand.
  final String? restoredRelativePath;
  final String checksum;
  final String type;
  final DateTime fileCreatedAt;
  final DateTime importedAt;
  final bool isFavorite;
  final bool isTrashed;
  final DateTime? trashedAt;

  /// In den gesperrten (PIN-geschützten) Ordner verschoben – solche Assets
  /// werden aus Timeline, Kalender, Karte, Suche, Alben, Personen und
  /// Backup-Export herausgefiltert und sind nur über den gesperrten Ordner
  /// (nach PIN-Eingabe) erreichbar. Siehe [PrivacySettings].
  final bool isLocked;
  final String? description;
  final int? widthPx;
  final int? heightPx;
  final double? durationSeconds;
  final int fileSizeBytes;
  final bool backedUp;

  /// Separat von [backedUp] getrackt, damit sich manuelles Backup (eigener
  /// Zielordner) und automatisches Backup (eigener Zielordner, siehe
  /// [BackupSettings]) nicht gegenseitig den "schon gesichert"-Status
  /// stehlen, wenn beide gleichzeitig genutzt werden.
  final bool autoBackedUp;
  final bool facesScanned;
  final String? linkedAssetId;

  /// Aus EXIF-GPS-Daten übernommen (nur Fotos) oder manuell in der
  /// Info-Ansicht der Vollbildvorschau gesetzt/korrigiert. Beide null,
  /// solange kein Ort bekannt ist.
  final double? latitude;
  final double? longitude;

  /// Kamera-/Objektiv-/Aufnahme-Angaben aus den EXIF-Daten (nur Fotos) –
  /// rein informativ für die Info-Ansicht, siehe ExifCamera.parseExifCameraInfo.
  final String? cameraMake;
  final String? cameraModel;
  final String? lensModel;
  final double? focalLengthMm;
  final double? fNumber;
  final int? iso;
  final double? exposureTimeSeconds;

  /// Belichtungskorrektur in Blendenstufen (EXIF `ExposureBiasValue`) – der
  /// „0 ev"-Wert, den auch die macOS-Fotos-Informationen zeigen.
  ///
  /// Eigene Spalte statt „0 annehmen, wenn nichts dasteht": Ein Foto ohne
  /// diese Angabe (Screenshot, Scan) hat keine Belichtungskorrektur von
  /// null, es hat gar keine. Der Unterschied ist derselbe wie zwischen
  /// „ISO 0" und „ISO unbekannt".
  final double? exposureBiasEv;

  /// Kleinbild-äquivalente Brennweite (EXIF `FocalLengthIn35mmFilm`).
  ///
  /// Bei Telefonen ist das der Wert, den alle nennen: Die iPhone-Hauptkamera
  /// schreibt 5,7 mm echte Brennweite, gemeint und überall angezeigt sind
  /// 26 mm. Ohne diese Spalte stünde in der Info-Ansicht eine Zahl, die zu
  /// nichts passt, was der Nutzer über sein Gerät weiss.
  final double? focalLength35mm;

  /// Aus [latitude]/[longitude] abgeleitet über die lokale/offline
  /// Umkehr-Geokodierung (siehe ReverseGeocoder – nächstgelegene bekannte
  /// Stadt, keine Anfrage an einen Online-Dienst). Bleibt `null`, solange
  /// entweder kein Ort bekannt ist oder der GeoNames-Datensatz noch nicht
  /// heruntergeladen wurde.
  final String? locationCountry;
  final String? locationState;
  final String? locationCity;

  /// Sternebewertung 0-5 (0 = unbewertet), analog zu Photo Mechanic/
  /// Lightroom – für schnelle Sichtung großer Importstapel.
  final int rating;

  /// 'red'|'yellow'|'green'|'blue'|'purple', null = keine Markierung.
  final String? colorLabel;

  /// Per Vision-Framework erkannter Text im Bild (siehe ImageConverter.swift
  /// `recognizeText`), durchsuchbar über SearchTextMode.ocr.
  final String? ocrText;

  /// Eigenes Flag statt "ocrText == null" als "noch nicht gescannt"-Signal,
  /// da ein leerer erkannter Text (kein Text im Bild gefunden) ein gültiges
  /// Ergebnis ist – analog zu [facesScanned].
  final bool ocrScanned;

  /// Automatisch erzeugte (englische) Bildunterschrift (siehe
  /// FlorenceCaptioningService), durchsuchbar über SearchTextMode.caption. Bewusst
  /// NICHT [description] wiederverwendet – das ist Nutzer-Freitext.
  final String? aiCaption;

  /// Deutsche Fassung von [aiCaption] (siehe TranslationService).
  ///
  /// Als eigene Spalte, nicht als Ersatz: Das englische Original bleibt
  /// erhalten, damit ein Abschalten der Übersetzung nicht bedeutet, das
  /// Beschreibungsmodell über die ganze Bibliothek erneut laufen zu
  /// lassen. Die Suche durchsucht beide.
  final String? aiCaptionDe;

  /// Eigenes Flag statt "aiCaption == null" als "noch nicht erzeugt"-Signal,
  /// analog zu [ocrScanned].
  final bool aiCaptionScanned;

  /// Ob jemand die Bildunterschrift von Hand geändert hat.
  ///
  /// Ohne dieses Merkmal wäre das Bearbeiten eine Falle: Ein „Alle Fotos"
  /// bei den Bildbeschreibungen – gedacht für einen Modellwechsel – würde
  /// den mühsam getippten Satz kommentarlos überschreiben. Ist es gesetzt,
  /// fassen weder die Nachholvorgänge noch die Hintergrundanalyse den
  /// Eintrag noch an; er verhält sich damit wie der Freitext des Nutzers.
  ///
  /// Zurücknehmen lässt es sich, indem das Feld geleert wird – dann ist das
  /// Foto wieder Kandidat für das Modell.
  final bool aiCaptionEdited;

  /// Eigenes Flag statt "hat keine Tags" als "noch nicht verschlagwortet"-
  /// Signal, aus demselben Grund wie [ocrScanned]: Dass CLIP zu keinem
  /// Vokabelbegriff eine ausreichende Ähnlichkeit findet, ist ein GÜLTIGES
  /// Ergebnis, kein offener Posten. Ohne dieses Flag blieben solche Fotos
  /// dauerhaft Kandidaten und die Tagging-Stufe lud bei JEDEM Programmstart
  /// beide CLIP-Encoder (577 MB), rechnete sie durch und erzeugte wieder
  /// nichts (Audit-Fund: gemessen 1066 MB Grundlast statt 214 MB).
  final bool aiTagsScanned;

  /// Laplace-Varianz des Bilds (siehe blur_detection.dart) – höher = schärfer.
  /// Null, solange noch nicht berechnet.
  final double? sharpnessScore;

  /// Serien-/Burst-Gruppierung (siehe StackReviewScreen, findBurstGroups):
  /// alle Mitglieder einer Serie teilen dieselbe [stackId], analog zu
  /// [linkedAssetId] bei Live Photos. `null` = kein Stapel.
  final String? stackId;

  /// Genau ein Mitglied pro Stapel ist Titelbild – nur dieses erscheint in
  /// Timeline/Kalender/Karte & Co. (siehe die `stackId`/`isStackCover`-Filter
  /// dort, exakt wie bei [linkedAssetId] für Live Photos).
  final bool isStackCover;

  /// Gesamtzahl der Fotos im Stapel – NUR auf der Titelbild-Zeile gesetzt
  /// (sonst `null`), damit die Rasteransicht die Zahl fürs Abzeichen ohne
  /// zusätzliche COUNT-Abfrage pro Kachel anzeigen kann.
  final int? stackSize;
  const AssetData(
      {required this.id,
      required this.originalFileName,
      required this.relativePath,
      this.thumbnailRelativePath,
      this.previewRelativePath,
      this.developedRelativePath,
      this.trimmedRelativePath,
      this.restoredRelativePath,
      required this.checksum,
      required this.type,
      required this.fileCreatedAt,
      required this.importedAt,
      required this.isFavorite,
      required this.isTrashed,
      this.trashedAt,
      required this.isLocked,
      this.description,
      this.widthPx,
      this.heightPx,
      this.durationSeconds,
      required this.fileSizeBytes,
      required this.backedUp,
      required this.autoBackedUp,
      required this.facesScanned,
      this.linkedAssetId,
      this.latitude,
      this.longitude,
      this.cameraMake,
      this.cameraModel,
      this.lensModel,
      this.focalLengthMm,
      this.fNumber,
      this.iso,
      this.exposureTimeSeconds,
      this.exposureBiasEv,
      this.focalLength35mm,
      this.locationCountry,
      this.locationState,
      this.locationCity,
      required this.rating,
      this.colorLabel,
      this.ocrText,
      required this.ocrScanned,
      this.aiCaption,
      this.aiCaptionDe,
      required this.aiCaptionScanned,
      required this.aiCaptionEdited,
      required this.aiTagsScanned,
      this.sharpnessScore,
      this.stackId,
      required this.isStackCover,
      this.stackSize});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['original_file_name'] = Variable<String>(originalFileName);
    map['relative_path'] = Variable<String>(relativePath);
    if (!nullToAbsent || thumbnailRelativePath != null) {
      map['thumbnail_relative_path'] = Variable<String>(thumbnailRelativePath);
    }
    if (!nullToAbsent || previewRelativePath != null) {
      map['preview_relative_path'] = Variable<String>(previewRelativePath);
    }
    if (!nullToAbsent || developedRelativePath != null) {
      map['developed_relative_path'] = Variable<String>(developedRelativePath);
    }
    if (!nullToAbsent || trimmedRelativePath != null) {
      map['trimmed_relative_path'] = Variable<String>(trimmedRelativePath);
    }
    if (!nullToAbsent || restoredRelativePath != null) {
      map['restored_relative_path'] = Variable<String>(restoredRelativePath);
    }
    map['checksum'] = Variable<String>(checksum);
    map['type'] = Variable<String>(type);
    map['file_created_at'] = Variable<DateTime>(fileCreatedAt);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_trashed'] = Variable<bool>(isTrashed);
    if (!nullToAbsent || trashedAt != null) {
      map['trashed_at'] = Variable<DateTime>(trashedAt);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || widthPx != null) {
      map['width_px'] = Variable<int>(widthPx);
    }
    if (!nullToAbsent || heightPx != null) {
      map['height_px'] = Variable<int>(heightPx);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<double>(durationSeconds);
    }
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['backed_up'] = Variable<bool>(backedUp);
    map['auto_backed_up'] = Variable<bool>(autoBackedUp);
    map['faces_scanned'] = Variable<bool>(facesScanned);
    if (!nullToAbsent || linkedAssetId != null) {
      map['linked_asset_id'] = Variable<String>(linkedAssetId);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || cameraMake != null) {
      map['camera_make'] = Variable<String>(cameraMake);
    }
    if (!nullToAbsent || cameraModel != null) {
      map['camera_model'] = Variable<String>(cameraModel);
    }
    if (!nullToAbsent || lensModel != null) {
      map['lens_model'] = Variable<String>(lensModel);
    }
    if (!nullToAbsent || focalLengthMm != null) {
      map['focal_length_mm'] = Variable<double>(focalLengthMm);
    }
    if (!nullToAbsent || fNumber != null) {
      map['f_number'] = Variable<double>(fNumber);
    }
    if (!nullToAbsent || iso != null) {
      map['iso'] = Variable<int>(iso);
    }
    if (!nullToAbsent || exposureTimeSeconds != null) {
      map['exposure_time_seconds'] = Variable<double>(exposureTimeSeconds);
    }
    if (!nullToAbsent || exposureBiasEv != null) {
      map['exposure_bias_ev'] = Variable<double>(exposureBiasEv);
    }
    if (!nullToAbsent || focalLength35mm != null) {
      map['focal_length35mm'] = Variable<double>(focalLength35mm);
    }
    if (!nullToAbsent || locationCountry != null) {
      map['location_country'] = Variable<String>(locationCountry);
    }
    if (!nullToAbsent || locationState != null) {
      map['location_state'] = Variable<String>(locationState);
    }
    if (!nullToAbsent || locationCity != null) {
      map['location_city'] = Variable<String>(locationCity);
    }
    map['rating'] = Variable<int>(rating);
    if (!nullToAbsent || colorLabel != null) {
      map['color_label'] = Variable<String>(colorLabel);
    }
    if (!nullToAbsent || ocrText != null) {
      map['ocr_text'] = Variable<String>(ocrText);
    }
    map['ocr_scanned'] = Variable<bool>(ocrScanned);
    if (!nullToAbsent || aiCaption != null) {
      map['ai_caption'] = Variable<String>(aiCaption);
    }
    if (!nullToAbsent || aiCaptionDe != null) {
      map['ai_caption_de'] = Variable<String>(aiCaptionDe);
    }
    map['ai_caption_scanned'] = Variable<bool>(aiCaptionScanned);
    map['ai_caption_edited'] = Variable<bool>(aiCaptionEdited);
    map['ai_tags_scanned'] = Variable<bool>(aiTagsScanned);
    if (!nullToAbsent || sharpnessScore != null) {
      map['sharpness_score'] = Variable<double>(sharpnessScore);
    }
    if (!nullToAbsent || stackId != null) {
      map['stack_id'] = Variable<String>(stackId);
    }
    map['is_stack_cover'] = Variable<bool>(isStackCover);
    if (!nullToAbsent || stackSize != null) {
      map['stack_size'] = Variable<int>(stackSize);
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      originalFileName: Value(originalFileName),
      relativePath: Value(relativePath),
      thumbnailRelativePath: thumbnailRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailRelativePath),
      previewRelativePath: previewRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(previewRelativePath),
      developedRelativePath: developedRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(developedRelativePath),
      trimmedRelativePath: trimmedRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(trimmedRelativePath),
      restoredRelativePath: restoredRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredRelativePath),
      checksum: Value(checksum),
      type: Value(type),
      fileCreatedAt: Value(fileCreatedAt),
      importedAt: Value(importedAt),
      isFavorite: Value(isFavorite),
      isTrashed: Value(isTrashed),
      trashedAt: trashedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(trashedAt),
      isLocked: Value(isLocked),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      widthPx: widthPx == null && nullToAbsent
          ? const Value.absent()
          : Value(widthPx),
      heightPx: heightPx == null && nullToAbsent
          ? const Value.absent()
          : Value(heightPx),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      fileSizeBytes: Value(fileSizeBytes),
      backedUp: Value(backedUp),
      autoBackedUp: Value(autoBackedUp),
      facesScanned: Value(facesScanned),
      linkedAssetId: linkedAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAssetId),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      cameraMake: cameraMake == null && nullToAbsent
          ? const Value.absent()
          : Value(cameraMake),
      cameraModel: cameraModel == null && nullToAbsent
          ? const Value.absent()
          : Value(cameraModel),
      lensModel: lensModel == null && nullToAbsent
          ? const Value.absent()
          : Value(lensModel),
      focalLengthMm: focalLengthMm == null && nullToAbsent
          ? const Value.absent()
          : Value(focalLengthMm),
      fNumber: fNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(fNumber),
      iso: iso == null && nullToAbsent ? const Value.absent() : Value(iso),
      exposureTimeSeconds: exposureTimeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(exposureTimeSeconds),
      exposureBiasEv: exposureBiasEv == null && nullToAbsent
          ? const Value.absent()
          : Value(exposureBiasEv),
      focalLength35mm: focalLength35mm == null && nullToAbsent
          ? const Value.absent()
          : Value(focalLength35mm),
      locationCountry: locationCountry == null && nullToAbsent
          ? const Value.absent()
          : Value(locationCountry),
      locationState: locationState == null && nullToAbsent
          ? const Value.absent()
          : Value(locationState),
      locationCity: locationCity == null && nullToAbsent
          ? const Value.absent()
          : Value(locationCity),
      rating: Value(rating),
      colorLabel: colorLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(colorLabel),
      ocrText: ocrText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrText),
      ocrScanned: Value(ocrScanned),
      aiCaption: aiCaption == null && nullToAbsent
          ? const Value.absent()
          : Value(aiCaption),
      aiCaptionDe: aiCaptionDe == null && nullToAbsent
          ? const Value.absent()
          : Value(aiCaptionDe),
      aiCaptionScanned: Value(aiCaptionScanned),
      aiCaptionEdited: Value(aiCaptionEdited),
      aiTagsScanned: Value(aiTagsScanned),
      sharpnessScore: sharpnessScore == null && nullToAbsent
          ? const Value.absent()
          : Value(sharpnessScore),
      stackId: stackId == null && nullToAbsent
          ? const Value.absent()
          : Value(stackId),
      isStackCover: Value(isStackCover),
      stackSize: stackSize == null && nullToAbsent
          ? const Value.absent()
          : Value(stackSize),
    );
  }

  factory AssetData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetData(
      id: serializer.fromJson<String>(json['id']),
      originalFileName: serializer.fromJson<String>(json['originalFileName']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      thumbnailRelativePath:
          serializer.fromJson<String?>(json['thumbnailRelativePath']),
      previewRelativePath:
          serializer.fromJson<String?>(json['previewRelativePath']),
      developedRelativePath:
          serializer.fromJson<String?>(json['developedRelativePath']),
      trimmedRelativePath:
          serializer.fromJson<String?>(json['trimmedRelativePath']),
      restoredRelativePath:
          serializer.fromJson<String?>(json['restoredRelativePath']),
      checksum: serializer.fromJson<String>(json['checksum']),
      type: serializer.fromJson<String>(json['type']),
      fileCreatedAt: serializer.fromJson<DateTime>(json['fileCreatedAt']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isTrashed: serializer.fromJson<bool>(json['isTrashed']),
      trashedAt: serializer.fromJson<DateTime?>(json['trashedAt']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      description: serializer.fromJson<String?>(json['description']),
      widthPx: serializer.fromJson<int?>(json['widthPx']),
      heightPx: serializer.fromJson<int?>(json['heightPx']),
      durationSeconds: serializer.fromJson<double?>(json['durationSeconds']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      backedUp: serializer.fromJson<bool>(json['backedUp']),
      autoBackedUp: serializer.fromJson<bool>(json['autoBackedUp']),
      facesScanned: serializer.fromJson<bool>(json['facesScanned']),
      linkedAssetId: serializer.fromJson<String?>(json['linkedAssetId']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      cameraMake: serializer.fromJson<String?>(json['cameraMake']),
      cameraModel: serializer.fromJson<String?>(json['cameraModel']),
      lensModel: serializer.fromJson<String?>(json['lensModel']),
      focalLengthMm: serializer.fromJson<double?>(json['focalLengthMm']),
      fNumber: serializer.fromJson<double?>(json['fNumber']),
      iso: serializer.fromJson<int?>(json['iso']),
      exposureTimeSeconds:
          serializer.fromJson<double?>(json['exposureTimeSeconds']),
      exposureBiasEv: serializer.fromJson<double?>(json['exposureBiasEv']),
      focalLength35mm: serializer.fromJson<double?>(json['focalLength35mm']),
      locationCountry: serializer.fromJson<String?>(json['locationCountry']),
      locationState: serializer.fromJson<String?>(json['locationState']),
      locationCity: serializer.fromJson<String?>(json['locationCity']),
      rating: serializer.fromJson<int>(json['rating']),
      colorLabel: serializer.fromJson<String?>(json['colorLabel']),
      ocrText: serializer.fromJson<String?>(json['ocrText']),
      ocrScanned: serializer.fromJson<bool>(json['ocrScanned']),
      aiCaption: serializer.fromJson<String?>(json['aiCaption']),
      aiCaptionDe: serializer.fromJson<String?>(json['aiCaptionDe']),
      aiCaptionScanned: serializer.fromJson<bool>(json['aiCaptionScanned']),
      aiCaptionEdited: serializer.fromJson<bool>(json['aiCaptionEdited']),
      aiTagsScanned: serializer.fromJson<bool>(json['aiTagsScanned']),
      sharpnessScore: serializer.fromJson<double?>(json['sharpnessScore']),
      stackId: serializer.fromJson<String?>(json['stackId']),
      isStackCover: serializer.fromJson<bool>(json['isStackCover']),
      stackSize: serializer.fromJson<int?>(json['stackSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'originalFileName': serializer.toJson<String>(originalFileName),
      'relativePath': serializer.toJson<String>(relativePath),
      'thumbnailRelativePath':
          serializer.toJson<String?>(thumbnailRelativePath),
      'previewRelativePath': serializer.toJson<String?>(previewRelativePath),
      'developedRelativePath':
          serializer.toJson<String?>(developedRelativePath),
      'trimmedRelativePath': serializer.toJson<String?>(trimmedRelativePath),
      'restoredRelativePath': serializer.toJson<String?>(restoredRelativePath),
      'checksum': serializer.toJson<String>(checksum),
      'type': serializer.toJson<String>(type),
      'fileCreatedAt': serializer.toJson<DateTime>(fileCreatedAt),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isTrashed': serializer.toJson<bool>(isTrashed),
      'trashedAt': serializer.toJson<DateTime?>(trashedAt),
      'isLocked': serializer.toJson<bool>(isLocked),
      'description': serializer.toJson<String?>(description),
      'widthPx': serializer.toJson<int?>(widthPx),
      'heightPx': serializer.toJson<int?>(heightPx),
      'durationSeconds': serializer.toJson<double?>(durationSeconds),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'backedUp': serializer.toJson<bool>(backedUp),
      'autoBackedUp': serializer.toJson<bool>(autoBackedUp),
      'facesScanned': serializer.toJson<bool>(facesScanned),
      'linkedAssetId': serializer.toJson<String?>(linkedAssetId),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'cameraMake': serializer.toJson<String?>(cameraMake),
      'cameraModel': serializer.toJson<String?>(cameraModel),
      'lensModel': serializer.toJson<String?>(lensModel),
      'focalLengthMm': serializer.toJson<double?>(focalLengthMm),
      'fNumber': serializer.toJson<double?>(fNumber),
      'iso': serializer.toJson<int?>(iso),
      'exposureTimeSeconds': serializer.toJson<double?>(exposureTimeSeconds),
      'exposureBiasEv': serializer.toJson<double?>(exposureBiasEv),
      'focalLength35mm': serializer.toJson<double?>(focalLength35mm),
      'locationCountry': serializer.toJson<String?>(locationCountry),
      'locationState': serializer.toJson<String?>(locationState),
      'locationCity': serializer.toJson<String?>(locationCity),
      'rating': serializer.toJson<int>(rating),
      'colorLabel': serializer.toJson<String?>(colorLabel),
      'ocrText': serializer.toJson<String?>(ocrText),
      'ocrScanned': serializer.toJson<bool>(ocrScanned),
      'aiCaption': serializer.toJson<String?>(aiCaption),
      'aiCaptionDe': serializer.toJson<String?>(aiCaptionDe),
      'aiCaptionScanned': serializer.toJson<bool>(aiCaptionScanned),
      'aiCaptionEdited': serializer.toJson<bool>(aiCaptionEdited),
      'aiTagsScanned': serializer.toJson<bool>(aiTagsScanned),
      'sharpnessScore': serializer.toJson<double?>(sharpnessScore),
      'stackId': serializer.toJson<String?>(stackId),
      'isStackCover': serializer.toJson<bool>(isStackCover),
      'stackSize': serializer.toJson<int?>(stackSize),
    };
  }

  AssetData copyWith(
          {String? id,
          String? originalFileName,
          String? relativePath,
          Value<String?> thumbnailRelativePath = const Value.absent(),
          Value<String?> previewRelativePath = const Value.absent(),
          Value<String?> developedRelativePath = const Value.absent(),
          Value<String?> trimmedRelativePath = const Value.absent(),
          Value<String?> restoredRelativePath = const Value.absent(),
          String? checksum,
          String? type,
          DateTime? fileCreatedAt,
          DateTime? importedAt,
          bool? isFavorite,
          bool? isTrashed,
          Value<DateTime?> trashedAt = const Value.absent(),
          bool? isLocked,
          Value<String?> description = const Value.absent(),
          Value<int?> widthPx = const Value.absent(),
          Value<int?> heightPx = const Value.absent(),
          Value<double?> durationSeconds = const Value.absent(),
          int? fileSizeBytes,
          bool? backedUp,
          bool? autoBackedUp,
          bool? facesScanned,
          Value<String?> linkedAssetId = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> cameraMake = const Value.absent(),
          Value<String?> cameraModel = const Value.absent(),
          Value<String?> lensModel = const Value.absent(),
          Value<double?> focalLengthMm = const Value.absent(),
          Value<double?> fNumber = const Value.absent(),
          Value<int?> iso = const Value.absent(),
          Value<double?> exposureTimeSeconds = const Value.absent(),
          Value<double?> exposureBiasEv = const Value.absent(),
          Value<double?> focalLength35mm = const Value.absent(),
          Value<String?> locationCountry = const Value.absent(),
          Value<String?> locationState = const Value.absent(),
          Value<String?> locationCity = const Value.absent(),
          int? rating,
          Value<String?> colorLabel = const Value.absent(),
          Value<String?> ocrText = const Value.absent(),
          bool? ocrScanned,
          Value<String?> aiCaption = const Value.absent(),
          Value<String?> aiCaptionDe = const Value.absent(),
          bool? aiCaptionScanned,
          bool? aiCaptionEdited,
          bool? aiTagsScanned,
          Value<double?> sharpnessScore = const Value.absent(),
          Value<String?> stackId = const Value.absent(),
          bool? isStackCover,
          Value<int?> stackSize = const Value.absent()}) =>
      AssetData(
        id: id ?? this.id,
        originalFileName: originalFileName ?? this.originalFileName,
        relativePath: relativePath ?? this.relativePath,
        thumbnailRelativePath: thumbnailRelativePath.present
            ? thumbnailRelativePath.value
            : this.thumbnailRelativePath,
        previewRelativePath: previewRelativePath.present
            ? previewRelativePath.value
            : this.previewRelativePath,
        developedRelativePath: developedRelativePath.present
            ? developedRelativePath.value
            : this.developedRelativePath,
        trimmedRelativePath: trimmedRelativePath.present
            ? trimmedRelativePath.value
            : this.trimmedRelativePath,
        restoredRelativePath: restoredRelativePath.present
            ? restoredRelativePath.value
            : this.restoredRelativePath,
        checksum: checksum ?? this.checksum,
        type: type ?? this.type,
        fileCreatedAt: fileCreatedAt ?? this.fileCreatedAt,
        importedAt: importedAt ?? this.importedAt,
        isFavorite: isFavorite ?? this.isFavorite,
        isTrashed: isTrashed ?? this.isTrashed,
        trashedAt: trashedAt.present ? trashedAt.value : this.trashedAt,
        isLocked: isLocked ?? this.isLocked,
        description: description.present ? description.value : this.description,
        widthPx: widthPx.present ? widthPx.value : this.widthPx,
        heightPx: heightPx.present ? heightPx.value : this.heightPx,
        durationSeconds: durationSeconds.present
            ? durationSeconds.value
            : this.durationSeconds,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        backedUp: backedUp ?? this.backedUp,
        autoBackedUp: autoBackedUp ?? this.autoBackedUp,
        facesScanned: facesScanned ?? this.facesScanned,
        linkedAssetId:
            linkedAssetId.present ? linkedAssetId.value : this.linkedAssetId,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        cameraMake: cameraMake.present ? cameraMake.value : this.cameraMake,
        cameraModel: cameraModel.present ? cameraModel.value : this.cameraModel,
        lensModel: lensModel.present ? lensModel.value : this.lensModel,
        focalLengthMm:
            focalLengthMm.present ? focalLengthMm.value : this.focalLengthMm,
        fNumber: fNumber.present ? fNumber.value : this.fNumber,
        iso: iso.present ? iso.value : this.iso,
        exposureTimeSeconds: exposureTimeSeconds.present
            ? exposureTimeSeconds.value
            : this.exposureTimeSeconds,
        exposureBiasEv:
            exposureBiasEv.present ? exposureBiasEv.value : this.exposureBiasEv,
        focalLength35mm: focalLength35mm.present
            ? focalLength35mm.value
            : this.focalLength35mm,
        locationCountry: locationCountry.present
            ? locationCountry.value
            : this.locationCountry,
        locationState:
            locationState.present ? locationState.value : this.locationState,
        locationCity:
            locationCity.present ? locationCity.value : this.locationCity,
        rating: rating ?? this.rating,
        colorLabel: colorLabel.present ? colorLabel.value : this.colorLabel,
        ocrText: ocrText.present ? ocrText.value : this.ocrText,
        ocrScanned: ocrScanned ?? this.ocrScanned,
        aiCaption: aiCaption.present ? aiCaption.value : this.aiCaption,
        aiCaptionDe: aiCaptionDe.present ? aiCaptionDe.value : this.aiCaptionDe,
        aiCaptionScanned: aiCaptionScanned ?? this.aiCaptionScanned,
        aiCaptionEdited: aiCaptionEdited ?? this.aiCaptionEdited,
        aiTagsScanned: aiTagsScanned ?? this.aiTagsScanned,
        sharpnessScore:
            sharpnessScore.present ? sharpnessScore.value : this.sharpnessScore,
        stackId: stackId.present ? stackId.value : this.stackId,
        isStackCover: isStackCover ?? this.isStackCover,
        stackSize: stackSize.present ? stackSize.value : this.stackSize,
      );
  AssetData copyWithCompanion(AssetsCompanion data) {
    return AssetData(
      id: data.id.present ? data.id.value : this.id,
      originalFileName: data.originalFileName.present
          ? data.originalFileName.value
          : this.originalFileName,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      thumbnailRelativePath: data.thumbnailRelativePath.present
          ? data.thumbnailRelativePath.value
          : this.thumbnailRelativePath,
      previewRelativePath: data.previewRelativePath.present
          ? data.previewRelativePath.value
          : this.previewRelativePath,
      developedRelativePath: data.developedRelativePath.present
          ? data.developedRelativePath.value
          : this.developedRelativePath,
      trimmedRelativePath: data.trimmedRelativePath.present
          ? data.trimmedRelativePath.value
          : this.trimmedRelativePath,
      restoredRelativePath: data.restoredRelativePath.present
          ? data.restoredRelativePath.value
          : this.restoredRelativePath,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      type: data.type.present ? data.type.value : this.type,
      fileCreatedAt: data.fileCreatedAt.present
          ? data.fileCreatedAt.value
          : this.fileCreatedAt,
      importedAt:
          data.importedAt.present ? data.importedAt.value : this.importedAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isTrashed: data.isTrashed.present ? data.isTrashed.value : this.isTrashed,
      trashedAt: data.trashedAt.present ? data.trashedAt.value : this.trashedAt,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      description:
          data.description.present ? data.description.value : this.description,
      widthPx: data.widthPx.present ? data.widthPx.value : this.widthPx,
      heightPx: data.heightPx.present ? data.heightPx.value : this.heightPx,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      backedUp: data.backedUp.present ? data.backedUp.value : this.backedUp,
      autoBackedUp: data.autoBackedUp.present
          ? data.autoBackedUp.value
          : this.autoBackedUp,
      facesScanned: data.facesScanned.present
          ? data.facesScanned.value
          : this.facesScanned,
      linkedAssetId: data.linkedAssetId.present
          ? data.linkedAssetId.value
          : this.linkedAssetId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      cameraMake:
          data.cameraMake.present ? data.cameraMake.value : this.cameraMake,
      cameraModel:
          data.cameraModel.present ? data.cameraModel.value : this.cameraModel,
      lensModel: data.lensModel.present ? data.lensModel.value : this.lensModel,
      focalLengthMm: data.focalLengthMm.present
          ? data.focalLengthMm.value
          : this.focalLengthMm,
      fNumber: data.fNumber.present ? data.fNumber.value : this.fNumber,
      iso: data.iso.present ? data.iso.value : this.iso,
      exposureTimeSeconds: data.exposureTimeSeconds.present
          ? data.exposureTimeSeconds.value
          : this.exposureTimeSeconds,
      exposureBiasEv: data.exposureBiasEv.present
          ? data.exposureBiasEv.value
          : this.exposureBiasEv,
      focalLength35mm: data.focalLength35mm.present
          ? data.focalLength35mm.value
          : this.focalLength35mm,
      locationCountry: data.locationCountry.present
          ? data.locationCountry.value
          : this.locationCountry,
      locationState: data.locationState.present
          ? data.locationState.value
          : this.locationState,
      locationCity: data.locationCity.present
          ? data.locationCity.value
          : this.locationCity,
      rating: data.rating.present ? data.rating.value : this.rating,
      colorLabel:
          data.colorLabel.present ? data.colorLabel.value : this.colorLabel,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      ocrScanned:
          data.ocrScanned.present ? data.ocrScanned.value : this.ocrScanned,
      aiCaption: data.aiCaption.present ? data.aiCaption.value : this.aiCaption,
      aiCaptionDe:
          data.aiCaptionDe.present ? data.aiCaptionDe.value : this.aiCaptionDe,
      aiCaptionScanned: data.aiCaptionScanned.present
          ? data.aiCaptionScanned.value
          : this.aiCaptionScanned,
      aiCaptionEdited: data.aiCaptionEdited.present
          ? data.aiCaptionEdited.value
          : this.aiCaptionEdited,
      aiTagsScanned: data.aiTagsScanned.present
          ? data.aiTagsScanned.value
          : this.aiTagsScanned,
      sharpnessScore: data.sharpnessScore.present
          ? data.sharpnessScore.value
          : this.sharpnessScore,
      stackId: data.stackId.present ? data.stackId.value : this.stackId,
      isStackCover: data.isStackCover.present
          ? data.isStackCover.value
          : this.isStackCover,
      stackSize: data.stackSize.present ? data.stackSize.value : this.stackSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetData(')
          ..write('id: $id, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('previewRelativePath: $previewRelativePath, ')
          ..write('developedRelativePath: $developedRelativePath, ')
          ..write('trimmedRelativePath: $trimmedRelativePath, ')
          ..write('restoredRelativePath: $restoredRelativePath, ')
          ..write('checksum: $checksum, ')
          ..write('type: $type, ')
          ..write('fileCreatedAt: $fileCreatedAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isTrashed: $isTrashed, ')
          ..write('trashedAt: $trashedAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('description: $description, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('backedUp: $backedUp, ')
          ..write('autoBackedUp: $autoBackedUp, ')
          ..write('facesScanned: $facesScanned, ')
          ..write('linkedAssetId: $linkedAssetId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('cameraMake: $cameraMake, ')
          ..write('cameraModel: $cameraModel, ')
          ..write('lensModel: $lensModel, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('fNumber: $fNumber, ')
          ..write('iso: $iso, ')
          ..write('exposureTimeSeconds: $exposureTimeSeconds, ')
          ..write('exposureBiasEv: $exposureBiasEv, ')
          ..write('focalLength35mm: $focalLength35mm, ')
          ..write('locationCountry: $locationCountry, ')
          ..write('locationState: $locationState, ')
          ..write('locationCity: $locationCity, ')
          ..write('rating: $rating, ')
          ..write('colorLabel: $colorLabel, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrScanned: $ocrScanned, ')
          ..write('aiCaption: $aiCaption, ')
          ..write('aiCaptionDe: $aiCaptionDe, ')
          ..write('aiCaptionScanned: $aiCaptionScanned, ')
          ..write('aiCaptionEdited: $aiCaptionEdited, ')
          ..write('aiTagsScanned: $aiTagsScanned, ')
          ..write('sharpnessScore: $sharpnessScore, ')
          ..write('stackId: $stackId, ')
          ..write('isStackCover: $isStackCover, ')
          ..write('stackSize: $stackSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        originalFileName,
        relativePath,
        thumbnailRelativePath,
        previewRelativePath,
        developedRelativePath,
        trimmedRelativePath,
        restoredRelativePath,
        checksum,
        type,
        fileCreatedAt,
        importedAt,
        isFavorite,
        isTrashed,
        trashedAt,
        isLocked,
        description,
        widthPx,
        heightPx,
        durationSeconds,
        fileSizeBytes,
        backedUp,
        autoBackedUp,
        facesScanned,
        linkedAssetId,
        latitude,
        longitude,
        cameraMake,
        cameraModel,
        lensModel,
        focalLengthMm,
        fNumber,
        iso,
        exposureTimeSeconds,
        exposureBiasEv,
        focalLength35mm,
        locationCountry,
        locationState,
        locationCity,
        rating,
        colorLabel,
        ocrText,
        ocrScanned,
        aiCaption,
        aiCaptionDe,
        aiCaptionScanned,
        aiCaptionEdited,
        aiTagsScanned,
        sharpnessScore,
        stackId,
        isStackCover,
        stackSize
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetData &&
          other.id == this.id &&
          other.originalFileName == this.originalFileName &&
          other.relativePath == this.relativePath &&
          other.thumbnailRelativePath == this.thumbnailRelativePath &&
          other.previewRelativePath == this.previewRelativePath &&
          other.developedRelativePath == this.developedRelativePath &&
          other.trimmedRelativePath == this.trimmedRelativePath &&
          other.restoredRelativePath == this.restoredRelativePath &&
          other.checksum == this.checksum &&
          other.type == this.type &&
          other.fileCreatedAt == this.fileCreatedAt &&
          other.importedAt == this.importedAt &&
          other.isFavorite == this.isFavorite &&
          other.isTrashed == this.isTrashed &&
          other.trashedAt == this.trashedAt &&
          other.isLocked == this.isLocked &&
          other.description == this.description &&
          other.widthPx == this.widthPx &&
          other.heightPx == this.heightPx &&
          other.durationSeconds == this.durationSeconds &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.backedUp == this.backedUp &&
          other.autoBackedUp == this.autoBackedUp &&
          other.facesScanned == this.facesScanned &&
          other.linkedAssetId == this.linkedAssetId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.cameraMake == this.cameraMake &&
          other.cameraModel == this.cameraModel &&
          other.lensModel == this.lensModel &&
          other.focalLengthMm == this.focalLengthMm &&
          other.fNumber == this.fNumber &&
          other.iso == this.iso &&
          other.exposureTimeSeconds == this.exposureTimeSeconds &&
          other.exposureBiasEv == this.exposureBiasEv &&
          other.focalLength35mm == this.focalLength35mm &&
          other.locationCountry == this.locationCountry &&
          other.locationState == this.locationState &&
          other.locationCity == this.locationCity &&
          other.rating == this.rating &&
          other.colorLabel == this.colorLabel &&
          other.ocrText == this.ocrText &&
          other.ocrScanned == this.ocrScanned &&
          other.aiCaption == this.aiCaption &&
          other.aiCaptionDe == this.aiCaptionDe &&
          other.aiCaptionScanned == this.aiCaptionScanned &&
          other.aiCaptionEdited == this.aiCaptionEdited &&
          other.aiTagsScanned == this.aiTagsScanned &&
          other.sharpnessScore == this.sharpnessScore &&
          other.stackId == this.stackId &&
          other.isStackCover == this.isStackCover &&
          other.stackSize == this.stackSize);
}

class AssetsCompanion extends UpdateCompanion<AssetData> {
  final Value<String> id;
  final Value<String> originalFileName;
  final Value<String> relativePath;
  final Value<String?> thumbnailRelativePath;
  final Value<String?> previewRelativePath;
  final Value<String?> developedRelativePath;
  final Value<String?> trimmedRelativePath;
  final Value<String?> restoredRelativePath;
  final Value<String> checksum;
  final Value<String> type;
  final Value<DateTime> fileCreatedAt;
  final Value<DateTime> importedAt;
  final Value<bool> isFavorite;
  final Value<bool> isTrashed;
  final Value<DateTime?> trashedAt;
  final Value<bool> isLocked;
  final Value<String?> description;
  final Value<int?> widthPx;
  final Value<int?> heightPx;
  final Value<double?> durationSeconds;
  final Value<int> fileSizeBytes;
  final Value<bool> backedUp;
  final Value<bool> autoBackedUp;
  final Value<bool> facesScanned;
  final Value<String?> linkedAssetId;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> cameraMake;
  final Value<String?> cameraModel;
  final Value<String?> lensModel;
  final Value<double?> focalLengthMm;
  final Value<double?> fNumber;
  final Value<int?> iso;
  final Value<double?> exposureTimeSeconds;
  final Value<double?> exposureBiasEv;
  final Value<double?> focalLength35mm;
  final Value<String?> locationCountry;
  final Value<String?> locationState;
  final Value<String?> locationCity;
  final Value<int> rating;
  final Value<String?> colorLabel;
  final Value<String?> ocrText;
  final Value<bool> ocrScanned;
  final Value<String?> aiCaption;
  final Value<String?> aiCaptionDe;
  final Value<bool> aiCaptionScanned;
  final Value<bool> aiCaptionEdited;
  final Value<bool> aiTagsScanned;
  final Value<double?> sharpnessScore;
  final Value<String?> stackId;
  final Value<bool> isStackCover;
  final Value<int?> stackSize;
  final Value<int> rowid;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.originalFileName = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.thumbnailRelativePath = const Value.absent(),
    this.previewRelativePath = const Value.absent(),
    this.developedRelativePath = const Value.absent(),
    this.trimmedRelativePath = const Value.absent(),
    this.restoredRelativePath = const Value.absent(),
    this.checksum = const Value.absent(),
    this.type = const Value.absent(),
    this.fileCreatedAt = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isTrashed = const Value.absent(),
    this.trashedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.description = const Value.absent(),
    this.widthPx = const Value.absent(),
    this.heightPx = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.backedUp = const Value.absent(),
    this.autoBackedUp = const Value.absent(),
    this.facesScanned = const Value.absent(),
    this.linkedAssetId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.cameraMake = const Value.absent(),
    this.cameraModel = const Value.absent(),
    this.lensModel = const Value.absent(),
    this.focalLengthMm = const Value.absent(),
    this.fNumber = const Value.absent(),
    this.iso = const Value.absent(),
    this.exposureTimeSeconds = const Value.absent(),
    this.exposureBiasEv = const Value.absent(),
    this.focalLength35mm = const Value.absent(),
    this.locationCountry = const Value.absent(),
    this.locationState = const Value.absent(),
    this.locationCity = const Value.absent(),
    this.rating = const Value.absent(),
    this.colorLabel = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrScanned = const Value.absent(),
    this.aiCaption = const Value.absent(),
    this.aiCaptionDe = const Value.absent(),
    this.aiCaptionScanned = const Value.absent(),
    this.aiCaptionEdited = const Value.absent(),
    this.aiTagsScanned = const Value.absent(),
    this.sharpnessScore = const Value.absent(),
    this.stackId = const Value.absent(),
    this.isStackCover = const Value.absent(),
    this.stackSize = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String id,
    required String originalFileName,
    required String relativePath,
    this.thumbnailRelativePath = const Value.absent(),
    this.previewRelativePath = const Value.absent(),
    this.developedRelativePath = const Value.absent(),
    this.trimmedRelativePath = const Value.absent(),
    this.restoredRelativePath = const Value.absent(),
    required String checksum,
    required String type,
    required DateTime fileCreatedAt,
    required DateTime importedAt,
    this.isFavorite = const Value.absent(),
    this.isTrashed = const Value.absent(),
    this.trashedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.description = const Value.absent(),
    this.widthPx = const Value.absent(),
    this.heightPx = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.backedUp = const Value.absent(),
    this.autoBackedUp = const Value.absent(),
    this.facesScanned = const Value.absent(),
    this.linkedAssetId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.cameraMake = const Value.absent(),
    this.cameraModel = const Value.absent(),
    this.lensModel = const Value.absent(),
    this.focalLengthMm = const Value.absent(),
    this.fNumber = const Value.absent(),
    this.iso = const Value.absent(),
    this.exposureTimeSeconds = const Value.absent(),
    this.exposureBiasEv = const Value.absent(),
    this.focalLength35mm = const Value.absent(),
    this.locationCountry = const Value.absent(),
    this.locationState = const Value.absent(),
    this.locationCity = const Value.absent(),
    this.rating = const Value.absent(),
    this.colorLabel = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.ocrScanned = const Value.absent(),
    this.aiCaption = const Value.absent(),
    this.aiCaptionDe = const Value.absent(),
    this.aiCaptionScanned = const Value.absent(),
    this.aiCaptionEdited = const Value.absent(),
    this.aiTagsScanned = const Value.absent(),
    this.sharpnessScore = const Value.absent(),
    this.stackId = const Value.absent(),
    this.isStackCover = const Value.absent(),
    this.stackSize = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        originalFileName = Value(originalFileName),
        relativePath = Value(relativePath),
        checksum = Value(checksum),
        type = Value(type),
        fileCreatedAt = Value(fileCreatedAt),
        importedAt = Value(importedAt);
  static Insertable<AssetData> custom({
    Expression<String>? id,
    Expression<String>? originalFileName,
    Expression<String>? relativePath,
    Expression<String>? thumbnailRelativePath,
    Expression<String>? previewRelativePath,
    Expression<String>? developedRelativePath,
    Expression<String>? trimmedRelativePath,
    Expression<String>? restoredRelativePath,
    Expression<String>? checksum,
    Expression<String>? type,
    Expression<DateTime>? fileCreatedAt,
    Expression<DateTime>? importedAt,
    Expression<bool>? isFavorite,
    Expression<bool>? isTrashed,
    Expression<DateTime>? trashedAt,
    Expression<bool>? isLocked,
    Expression<String>? description,
    Expression<int>? widthPx,
    Expression<int>? heightPx,
    Expression<double>? durationSeconds,
    Expression<int>? fileSizeBytes,
    Expression<bool>? backedUp,
    Expression<bool>? autoBackedUp,
    Expression<bool>? facesScanned,
    Expression<String>? linkedAssetId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? cameraMake,
    Expression<String>? cameraModel,
    Expression<String>? lensModel,
    Expression<double>? focalLengthMm,
    Expression<double>? fNumber,
    Expression<int>? iso,
    Expression<double>? exposureTimeSeconds,
    Expression<double>? exposureBiasEv,
    Expression<double>? focalLength35mm,
    Expression<String>? locationCountry,
    Expression<String>? locationState,
    Expression<String>? locationCity,
    Expression<int>? rating,
    Expression<String>? colorLabel,
    Expression<String>? ocrText,
    Expression<bool>? ocrScanned,
    Expression<String>? aiCaption,
    Expression<String>? aiCaptionDe,
    Expression<bool>? aiCaptionScanned,
    Expression<bool>? aiCaptionEdited,
    Expression<bool>? aiTagsScanned,
    Expression<double>? sharpnessScore,
    Expression<String>? stackId,
    Expression<bool>? isStackCover,
    Expression<int>? stackSize,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalFileName != null) 'original_file_name': originalFileName,
      if (relativePath != null) 'relative_path': relativePath,
      if (thumbnailRelativePath != null)
        'thumbnail_relative_path': thumbnailRelativePath,
      if (previewRelativePath != null)
        'preview_relative_path': previewRelativePath,
      if (developedRelativePath != null)
        'developed_relative_path': developedRelativePath,
      if (trimmedRelativePath != null)
        'trimmed_relative_path': trimmedRelativePath,
      if (restoredRelativePath != null)
        'restored_relative_path': restoredRelativePath,
      if (checksum != null) 'checksum': checksum,
      if (type != null) 'type': type,
      if (fileCreatedAt != null) 'file_created_at': fileCreatedAt,
      if (importedAt != null) 'imported_at': importedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isTrashed != null) 'is_trashed': isTrashed,
      if (trashedAt != null) 'trashed_at': trashedAt,
      if (isLocked != null) 'is_locked': isLocked,
      if (description != null) 'description': description,
      if (widthPx != null) 'width_px': widthPx,
      if (heightPx != null) 'height_px': heightPx,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (backedUp != null) 'backed_up': backedUp,
      if (autoBackedUp != null) 'auto_backed_up': autoBackedUp,
      if (facesScanned != null) 'faces_scanned': facesScanned,
      if (linkedAssetId != null) 'linked_asset_id': linkedAssetId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (cameraMake != null) 'camera_make': cameraMake,
      if (cameraModel != null) 'camera_model': cameraModel,
      if (lensModel != null) 'lens_model': lensModel,
      if (focalLengthMm != null) 'focal_length_mm': focalLengthMm,
      if (fNumber != null) 'f_number': fNumber,
      if (iso != null) 'iso': iso,
      if (exposureTimeSeconds != null)
        'exposure_time_seconds': exposureTimeSeconds,
      if (exposureBiasEv != null) 'exposure_bias_ev': exposureBiasEv,
      if (focalLength35mm != null) 'focal_length35mm': focalLength35mm,
      if (locationCountry != null) 'location_country': locationCountry,
      if (locationState != null) 'location_state': locationState,
      if (locationCity != null) 'location_city': locationCity,
      if (rating != null) 'rating': rating,
      if (colorLabel != null) 'color_label': colorLabel,
      if (ocrText != null) 'ocr_text': ocrText,
      if (ocrScanned != null) 'ocr_scanned': ocrScanned,
      if (aiCaption != null) 'ai_caption': aiCaption,
      if (aiCaptionDe != null) 'ai_caption_de': aiCaptionDe,
      if (aiCaptionScanned != null) 'ai_caption_scanned': aiCaptionScanned,
      if (aiCaptionEdited != null) 'ai_caption_edited': aiCaptionEdited,
      if (aiTagsScanned != null) 'ai_tags_scanned': aiTagsScanned,
      if (sharpnessScore != null) 'sharpness_score': sharpnessScore,
      if (stackId != null) 'stack_id': stackId,
      if (isStackCover != null) 'is_stack_cover': isStackCover,
      if (stackSize != null) 'stack_size': stackSize,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? originalFileName,
      Value<String>? relativePath,
      Value<String?>? thumbnailRelativePath,
      Value<String?>? previewRelativePath,
      Value<String?>? developedRelativePath,
      Value<String?>? trimmedRelativePath,
      Value<String?>? restoredRelativePath,
      Value<String>? checksum,
      Value<String>? type,
      Value<DateTime>? fileCreatedAt,
      Value<DateTime>? importedAt,
      Value<bool>? isFavorite,
      Value<bool>? isTrashed,
      Value<DateTime?>? trashedAt,
      Value<bool>? isLocked,
      Value<String?>? description,
      Value<int?>? widthPx,
      Value<int?>? heightPx,
      Value<double?>? durationSeconds,
      Value<int>? fileSizeBytes,
      Value<bool>? backedUp,
      Value<bool>? autoBackedUp,
      Value<bool>? facesScanned,
      Value<String?>? linkedAssetId,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? cameraMake,
      Value<String?>? cameraModel,
      Value<String?>? lensModel,
      Value<double?>? focalLengthMm,
      Value<double?>? fNumber,
      Value<int?>? iso,
      Value<double?>? exposureTimeSeconds,
      Value<double?>? exposureBiasEv,
      Value<double?>? focalLength35mm,
      Value<String?>? locationCountry,
      Value<String?>? locationState,
      Value<String?>? locationCity,
      Value<int>? rating,
      Value<String?>? colorLabel,
      Value<String?>? ocrText,
      Value<bool>? ocrScanned,
      Value<String?>? aiCaption,
      Value<String?>? aiCaptionDe,
      Value<bool>? aiCaptionScanned,
      Value<bool>? aiCaptionEdited,
      Value<bool>? aiTagsScanned,
      Value<double?>? sharpnessScore,
      Value<String?>? stackId,
      Value<bool>? isStackCover,
      Value<int?>? stackSize,
      Value<int>? rowid}) {
    return AssetsCompanion(
      id: id ?? this.id,
      originalFileName: originalFileName ?? this.originalFileName,
      relativePath: relativePath ?? this.relativePath,
      thumbnailRelativePath:
          thumbnailRelativePath ?? this.thumbnailRelativePath,
      previewRelativePath: previewRelativePath ?? this.previewRelativePath,
      developedRelativePath:
          developedRelativePath ?? this.developedRelativePath,
      trimmedRelativePath: trimmedRelativePath ?? this.trimmedRelativePath,
      restoredRelativePath: restoredRelativePath ?? this.restoredRelativePath,
      checksum: checksum ?? this.checksum,
      type: type ?? this.type,
      fileCreatedAt: fileCreatedAt ?? this.fileCreatedAt,
      importedAt: importedAt ?? this.importedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isTrashed: isTrashed ?? this.isTrashed,
      trashedAt: trashedAt ?? this.trashedAt,
      isLocked: isLocked ?? this.isLocked,
      description: description ?? this.description,
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      backedUp: backedUp ?? this.backedUp,
      autoBackedUp: autoBackedUp ?? this.autoBackedUp,
      facesScanned: facesScanned ?? this.facesScanned,
      linkedAssetId: linkedAssetId ?? this.linkedAssetId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cameraMake: cameraMake ?? this.cameraMake,
      cameraModel: cameraModel ?? this.cameraModel,
      lensModel: lensModel ?? this.lensModel,
      focalLengthMm: focalLengthMm ?? this.focalLengthMm,
      fNumber: fNumber ?? this.fNumber,
      iso: iso ?? this.iso,
      exposureTimeSeconds: exposureTimeSeconds ?? this.exposureTimeSeconds,
      exposureBiasEv: exposureBiasEv ?? this.exposureBiasEv,
      focalLength35mm: focalLength35mm ?? this.focalLength35mm,
      locationCountry: locationCountry ?? this.locationCountry,
      locationState: locationState ?? this.locationState,
      locationCity: locationCity ?? this.locationCity,
      rating: rating ?? this.rating,
      colorLabel: colorLabel ?? this.colorLabel,
      ocrText: ocrText ?? this.ocrText,
      ocrScanned: ocrScanned ?? this.ocrScanned,
      aiCaption: aiCaption ?? this.aiCaption,
      aiCaptionDe: aiCaptionDe ?? this.aiCaptionDe,
      aiCaptionScanned: aiCaptionScanned ?? this.aiCaptionScanned,
      aiCaptionEdited: aiCaptionEdited ?? this.aiCaptionEdited,
      aiTagsScanned: aiTagsScanned ?? this.aiTagsScanned,
      sharpnessScore: sharpnessScore ?? this.sharpnessScore,
      stackId: stackId ?? this.stackId,
      isStackCover: isStackCover ?? this.isStackCover,
      stackSize: stackSize ?? this.stackSize,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (originalFileName.present) {
      map['original_file_name'] = Variable<String>(originalFileName.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (thumbnailRelativePath.present) {
      map['thumbnail_relative_path'] =
          Variable<String>(thumbnailRelativePath.value);
    }
    if (previewRelativePath.present) {
      map['preview_relative_path'] =
          Variable<String>(previewRelativePath.value);
    }
    if (developedRelativePath.present) {
      map['developed_relative_path'] =
          Variable<String>(developedRelativePath.value);
    }
    if (trimmedRelativePath.present) {
      map['trimmed_relative_path'] =
          Variable<String>(trimmedRelativePath.value);
    }
    if (restoredRelativePath.present) {
      map['restored_relative_path'] =
          Variable<String>(restoredRelativePath.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (fileCreatedAt.present) {
      map['file_created_at'] = Variable<DateTime>(fileCreatedAt.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isTrashed.present) {
      map['is_trashed'] = Variable<bool>(isTrashed.value);
    }
    if (trashedAt.present) {
      map['trashed_at'] = Variable<DateTime>(trashedAt.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (widthPx.present) {
      map['width_px'] = Variable<int>(widthPx.value);
    }
    if (heightPx.present) {
      map['height_px'] = Variable<int>(heightPx.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (backedUp.present) {
      map['backed_up'] = Variable<bool>(backedUp.value);
    }
    if (autoBackedUp.present) {
      map['auto_backed_up'] = Variable<bool>(autoBackedUp.value);
    }
    if (facesScanned.present) {
      map['faces_scanned'] = Variable<bool>(facesScanned.value);
    }
    if (linkedAssetId.present) {
      map['linked_asset_id'] = Variable<String>(linkedAssetId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (cameraMake.present) {
      map['camera_make'] = Variable<String>(cameraMake.value);
    }
    if (cameraModel.present) {
      map['camera_model'] = Variable<String>(cameraModel.value);
    }
    if (lensModel.present) {
      map['lens_model'] = Variable<String>(lensModel.value);
    }
    if (focalLengthMm.present) {
      map['focal_length_mm'] = Variable<double>(focalLengthMm.value);
    }
    if (fNumber.present) {
      map['f_number'] = Variable<double>(fNumber.value);
    }
    if (iso.present) {
      map['iso'] = Variable<int>(iso.value);
    }
    if (exposureTimeSeconds.present) {
      map['exposure_time_seconds'] =
          Variable<double>(exposureTimeSeconds.value);
    }
    if (exposureBiasEv.present) {
      map['exposure_bias_ev'] = Variable<double>(exposureBiasEv.value);
    }
    if (focalLength35mm.present) {
      map['focal_length35mm'] = Variable<double>(focalLength35mm.value);
    }
    if (locationCountry.present) {
      map['location_country'] = Variable<String>(locationCountry.value);
    }
    if (locationState.present) {
      map['location_state'] = Variable<String>(locationState.value);
    }
    if (locationCity.present) {
      map['location_city'] = Variable<String>(locationCity.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (colorLabel.present) {
      map['color_label'] = Variable<String>(colorLabel.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (ocrScanned.present) {
      map['ocr_scanned'] = Variable<bool>(ocrScanned.value);
    }
    if (aiCaption.present) {
      map['ai_caption'] = Variable<String>(aiCaption.value);
    }
    if (aiCaptionDe.present) {
      map['ai_caption_de'] = Variable<String>(aiCaptionDe.value);
    }
    if (aiCaptionScanned.present) {
      map['ai_caption_scanned'] = Variable<bool>(aiCaptionScanned.value);
    }
    if (aiCaptionEdited.present) {
      map['ai_caption_edited'] = Variable<bool>(aiCaptionEdited.value);
    }
    if (aiTagsScanned.present) {
      map['ai_tags_scanned'] = Variable<bool>(aiTagsScanned.value);
    }
    if (sharpnessScore.present) {
      map['sharpness_score'] = Variable<double>(sharpnessScore.value);
    }
    if (stackId.present) {
      map['stack_id'] = Variable<String>(stackId.value);
    }
    if (isStackCover.present) {
      map['is_stack_cover'] = Variable<bool>(isStackCover.value);
    }
    if (stackSize.present) {
      map['stack_size'] = Variable<int>(stackSize.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('previewRelativePath: $previewRelativePath, ')
          ..write('developedRelativePath: $developedRelativePath, ')
          ..write('trimmedRelativePath: $trimmedRelativePath, ')
          ..write('restoredRelativePath: $restoredRelativePath, ')
          ..write('checksum: $checksum, ')
          ..write('type: $type, ')
          ..write('fileCreatedAt: $fileCreatedAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isTrashed: $isTrashed, ')
          ..write('trashedAt: $trashedAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('description: $description, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('backedUp: $backedUp, ')
          ..write('autoBackedUp: $autoBackedUp, ')
          ..write('facesScanned: $facesScanned, ')
          ..write('linkedAssetId: $linkedAssetId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('cameraMake: $cameraMake, ')
          ..write('cameraModel: $cameraModel, ')
          ..write('lensModel: $lensModel, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('fNumber: $fNumber, ')
          ..write('iso: $iso, ')
          ..write('exposureTimeSeconds: $exposureTimeSeconds, ')
          ..write('exposureBiasEv: $exposureBiasEv, ')
          ..write('focalLength35mm: $focalLength35mm, ')
          ..write('locationCountry: $locationCountry, ')
          ..write('locationState: $locationState, ')
          ..write('locationCity: $locationCity, ')
          ..write('rating: $rating, ')
          ..write('colorLabel: $colorLabel, ')
          ..write('ocrText: $ocrText, ')
          ..write('ocrScanned: $ocrScanned, ')
          ..write('aiCaption: $aiCaption, ')
          ..write('aiCaptionDe: $aiCaptionDe, ')
          ..write('aiCaptionScanned: $aiCaptionScanned, ')
          ..write('aiCaptionEdited: $aiCaptionEdited, ')
          ..write('aiTagsScanned: $aiTagsScanned, ')
          ..write('sharpnessScore: $sharpnessScore, ')
          ..write('stackId: $stackId, ')
          ..write('isStackCover: $isStackCover, ')
          ..write('stackSize: $stackSize, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, AlbumData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _coverAssetIdMeta =
      const VerificationMeta('coverAssetId');
  @override
  late final GeneratedColumn<String> coverAssetId = GeneratedColumn<String>(
      'cover_asset_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, coverAssetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(Insertable<AlbumData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('cover_asset_id')) {
      context.handle(
          _coverAssetIdMeta,
          coverAssetId.isAcceptableOrUnknown(
              data['cover_asset_id']!, _coverAssetIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      coverAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_asset_id']),
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class AlbumData extends DataClass implements Insertable<AlbumData> {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? coverAssetId;
  const AlbumData(
      {required this.id,
      required this.name,
      required this.createdAt,
      this.coverAssetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || coverAssetId != null) {
      map['cover_asset_id'] = Variable<String>(coverAssetId);
    }
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      coverAssetId: coverAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverAssetId),
    );
  }

  factory AlbumData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      coverAssetId: serializer.fromJson<String?>(json['coverAssetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'coverAssetId': serializer.toJson<String?>(coverAssetId),
    };
  }

  AlbumData copyWith(
          {String? id,
          String? name,
          DateTime? createdAt,
          Value<String?> coverAssetId = const Value.absent()}) =>
      AlbumData(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        coverAssetId:
            coverAssetId.present ? coverAssetId.value : this.coverAssetId,
      );
  AlbumData copyWithCompanion(AlbumsCompanion data) {
    return AlbumData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      coverAssetId: data.coverAssetId.present
          ? data.coverAssetId.value
          : this.coverAssetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('coverAssetId: $coverAssetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, coverAssetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.coverAssetId == this.coverAssetId);
}

class AlbumsCompanion extends UpdateCompanion<AlbumData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<String?> coverAssetId;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.coverAssetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.coverAssetId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<AlbumData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<String>? coverAssetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (coverAssetId != null) 'cover_asset_id': coverAssetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<String?>? coverAssetId,
      Value<int>? rowid}) {
    return AlbumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      coverAssetId: coverAssetId ?? this.coverAssetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (coverAssetId.present) {
      map['cover_asset_id'] = Variable<String>(coverAssetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('coverAssetId: $coverAssetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumAssetsTable extends AlbumAssets
    with TableInfo<$AlbumAssetsTable, AlbumAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [albumId, assetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album_assets';
  @override
  VerificationContext validateIntegrity(Insertable<AlbumAsset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {albumId, assetId};
  @override
  AlbumAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumAsset(
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
    );
  }

  @override
  $AlbumAssetsTable createAlias(String alias) {
    return $AlbumAssetsTable(attachedDatabase, alias);
  }
}

class AlbumAsset extends DataClass implements Insertable<AlbumAsset> {
  final String albumId;
  final String assetId;
  const AlbumAsset({required this.albumId, required this.assetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['album_id'] = Variable<String>(albumId);
    map['asset_id'] = Variable<String>(assetId);
    return map;
  }

  AlbumAssetsCompanion toCompanion(bool nullToAbsent) {
    return AlbumAssetsCompanion(
      albumId: Value(albumId),
      assetId: Value(assetId),
    );
  }

  factory AlbumAsset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumAsset(
      albumId: serializer.fromJson<String>(json['albumId']),
      assetId: serializer.fromJson<String>(json['assetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'albumId': serializer.toJson<String>(albumId),
      'assetId': serializer.toJson<String>(assetId),
    };
  }

  AlbumAsset copyWith({String? albumId, String? assetId}) => AlbumAsset(
        albumId: albumId ?? this.albumId,
        assetId: assetId ?? this.assetId,
      );
  AlbumAsset copyWithCompanion(AlbumAssetsCompanion data) {
    return AlbumAsset(
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumAsset(')
          ..write('albumId: $albumId, ')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(albumId, assetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumAsset &&
          other.albumId == this.albumId &&
          other.assetId == this.assetId);
}

class AlbumAssetsCompanion extends UpdateCompanion<AlbumAsset> {
  final Value<String> albumId;
  final Value<String> assetId;
  final Value<int> rowid;
  const AlbumAssetsCompanion({
    this.albumId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumAssetsCompanion.insert({
    required String albumId,
    required String assetId,
    this.rowid = const Value.absent(),
  })  : albumId = Value(albumId),
        assetId = Value(assetId);
  static Insertable<AlbumAsset> custom({
    Expression<String>? albumId,
    Expression<String>? assetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (albumId != null) 'album_id': albumId,
      if (assetId != null) 'asset_id': assetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumAssetsCompanion copyWith(
      {Value<String>? albumId, Value<String>? assetId, Value<int>? rowid}) {
    return AlbumAssetsCompanion(
      albumId: albumId ?? this.albumId,
      assetId: assetId ?? this.assetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumAssetsCompanion(')
          ..write('albumId: $albumId, ')
          ..write('assetId: $assetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<TagData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagData extends DataClass implements Insertable<TagData> {
  final String id;
  final String name;
  const TagData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory TagData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TagData copyWith({String? id, String? name}) => TagData(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  TagData copyWithCompanion(TagsCompanion data) {
    return TagData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagData && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<TagData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<TagData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetTagsTable extends AssetTags
    with TableInfo<$AssetTagsTable, AssetTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [assetId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_tags';
  @override
  VerificationContext validateIntegrity(Insertable<AssetTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId, tagId};
  @override
  AssetTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetTag(
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $AssetTagsTable createAlias(String alias) {
    return $AssetTagsTable(attachedDatabase, alias);
  }
}

class AssetTag extends DataClass implements Insertable<AssetTag> {
  final String assetId;
  final String tagId;
  const AssetTag({required this.assetId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  AssetTagsCompanion toCompanion(bool nullToAbsent) {
    return AssetTagsCompanion(
      assetId: Value(assetId),
      tagId: Value(tagId),
    );
  }

  factory AssetTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetTag(
      assetId: serializer.fromJson<String>(json['assetId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  AssetTag copyWith({String? assetId, String? tagId}) => AssetTag(
        assetId: assetId ?? this.assetId,
        tagId: tagId ?? this.tagId,
      );
  AssetTag copyWithCompanion(AssetTagsCompanion data) {
    return AssetTag(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetTag(')
          ..write('assetId: $assetId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetTag &&
          other.assetId == this.assetId &&
          other.tagId == this.tagId);
}

class AssetTagsCompanion extends UpdateCompanion<AssetTag> {
  final Value<String> assetId;
  final Value<String> tagId;
  final Value<int> rowid;
  const AssetTagsCompanion({
    this.assetId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetTagsCompanion.insert({
    required String assetId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : assetId = Value(assetId),
        tagId = Value(tagId);
  static Insertable<AssetTag> custom({
    Expression<String>? assetId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetTagsCompanion copyWith(
      {Value<String>? assetId, Value<String>? tagId, Value<int>? rowid}) {
    return AssetTagsCompanion(
      assetId: assetId ?? this.assetId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetTagsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, PersonData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverFaceCropPathMeta =
      const VerificationMeta('coverFaceCropPath');
  @override
  late final GeneratedColumn<String> coverFaceCropPath =
      GeneratedColumn<String>('cover_face_crop_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _similarityThresholdMeta =
      const VerificationMeta('similarityThreshold');
  @override
  late final GeneratedColumn<double> similarityThreshold =
      GeneratedColumn<double>('similarity_threshold', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _geburtsdatumMeta =
      const VerificationMeta('geburtsdatum');
  @override
  late final GeneratedColumn<DateTime> geburtsdatum = GeneratedColumn<DateTime>(
      'geburtsdatum', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sterbedatumMeta =
      const VerificationMeta('sterbedatum');
  @override
  late final GeneratedColumn<DateTime> sterbedatum = GeneratedColumn<DateTime>(
      'sterbedatum', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _geschlechtMeta =
      const VerificationMeta('geschlecht');
  @override
  late final GeneratedColumn<String> geschlecht = GeneratedColumn<String>(
      'geschlecht', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        coverFaceCropPath,
        similarityThreshold,
        geburtsdatum,
        sterbedatum,
        geschlecht
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(Insertable<PersonData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_face_crop_path')) {
      context.handle(
          _coverFaceCropPathMeta,
          coverFaceCropPath.isAcceptableOrUnknown(
              data['cover_face_crop_path']!, _coverFaceCropPathMeta));
    }
    if (data.containsKey('similarity_threshold')) {
      context.handle(
          _similarityThresholdMeta,
          similarityThreshold.isAcceptableOrUnknown(
              data['similarity_threshold']!, _similarityThresholdMeta));
    }
    if (data.containsKey('geburtsdatum')) {
      context.handle(
          _geburtsdatumMeta,
          geburtsdatum.isAcceptableOrUnknown(
              data['geburtsdatum']!, _geburtsdatumMeta));
    }
    if (data.containsKey('sterbedatum')) {
      context.handle(
          _sterbedatumMeta,
          sterbedatum.isAcceptableOrUnknown(
              data['sterbedatum']!, _sterbedatumMeta));
    }
    if (data.containsKey('geschlecht')) {
      context.handle(
          _geschlechtMeta,
          geschlecht.isAcceptableOrUnknown(
              data['geschlecht']!, _geschlechtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      coverFaceCropPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cover_face_crop_path']),
      similarityThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}similarity_threshold']),
      geburtsdatum: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}geburtsdatum']),
      sterbedatum: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sterbedatum']),
      geschlecht: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}geschlecht']),
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PersonData extends DataClass implements Insertable<PersonData> {
  final String id;
  final String name;
  final String? coverFaceCropPath;

  /// Persönliche Wiedererkennungs-Schwelle, abgeleitet aus den bisherigen
  /// Entscheidungen des Nutzers (siehe [FaceMatchFeedback] und
  /// face_threshold.dart). `null` = die allgemeine Schwelle gilt.
  ///
  /// Als gespeicherter Wert statt bei jedem Vorschlag neu gerechnet, damit
  /// die Zahl im Personen-Bildschirm dieselbe ist, nach der tatsächlich
  /// entschieden wurde – eine Schwelle, die sich zwischen Anzeige und
  /// Anwendung unterscheidet, wäre nicht erklärbar.
  final double? similarityThreshold;

  /// Lebensdaten – nur für den Stammbaum, und beide freiwillig.
  ///
  /// Als volles Datum und nicht als Jahreszahl: Bei Verwandten aus der
  /// eigenen Zeit kennt man den Tag, bei den Urgroßeltern oft nur das
  /// Jahr. Ein Feld, das nur Jahre aufnimmt, verlöre die genaue Angabe;
  /// eines für den Tag lässt sich mit dem 1. Januar füllen, wenn mehr
  /// nicht bekannt ist. Was davon angezeigt wird, entscheidet die
  /// Darstellung, nicht die Speicherung.
  final DateTime? geburtsdatum;
  final DateTime? sterbedatum;

  /// Geschlecht – ausschließlich für die Verwandtschaftsbezeichnungen.
  ///
  /// Ohne diese Angabe gibt es kein „Schwester", nur „Geschwister": Fast
  /// jede Bezeichnung im Deutschen wie im Englischen ist geschlechtsgebunden.
  /// `null` ist deshalb kein Mangel, sondern ein gültiger Zustand – dann
  /// erscheint die geschlechtsneutrale Form, und niemand muss eine Angabe
  /// machen, die er nicht kennt oder nicht machen will. Werte siehe
  /// `Geschlecht` in services/verwandtschaftsgrad.dart.
  final String? geschlecht;
  const PersonData(
      {required this.id,
      required this.name,
      this.coverFaceCropPath,
      this.similarityThreshold,
      this.geburtsdatum,
      this.sterbedatum,
      this.geschlecht});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverFaceCropPath != null) {
      map['cover_face_crop_path'] = Variable<String>(coverFaceCropPath);
    }
    if (!nullToAbsent || similarityThreshold != null) {
      map['similarity_threshold'] = Variable<double>(similarityThreshold);
    }
    if (!nullToAbsent || geburtsdatum != null) {
      map['geburtsdatum'] = Variable<DateTime>(geburtsdatum);
    }
    if (!nullToAbsent || sterbedatum != null) {
      map['sterbedatum'] = Variable<DateTime>(sterbedatum);
    }
    if (!nullToAbsent || geschlecht != null) {
      map['geschlecht'] = Variable<String>(geschlecht);
    }
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      name: Value(name),
      coverFaceCropPath: coverFaceCropPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverFaceCropPath),
      similarityThreshold: similarityThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(similarityThreshold),
      geburtsdatum: geburtsdatum == null && nullToAbsent
          ? const Value.absent()
          : Value(geburtsdatum),
      sterbedatum: sterbedatum == null && nullToAbsent
          ? const Value.absent()
          : Value(sterbedatum),
      geschlecht: geschlecht == null && nullToAbsent
          ? const Value.absent()
          : Value(geschlecht),
    );
  }

  factory PersonData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coverFaceCropPath:
          serializer.fromJson<String?>(json['coverFaceCropPath']),
      similarityThreshold:
          serializer.fromJson<double?>(json['similarityThreshold']),
      geburtsdatum: serializer.fromJson<DateTime?>(json['geburtsdatum']),
      sterbedatum: serializer.fromJson<DateTime?>(json['sterbedatum']),
      geschlecht: serializer.fromJson<String?>(json['geschlecht']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'coverFaceCropPath': serializer.toJson<String?>(coverFaceCropPath),
      'similarityThreshold': serializer.toJson<double?>(similarityThreshold),
      'geburtsdatum': serializer.toJson<DateTime?>(geburtsdatum),
      'sterbedatum': serializer.toJson<DateTime?>(sterbedatum),
      'geschlecht': serializer.toJson<String?>(geschlecht),
    };
  }

  PersonData copyWith(
          {String? id,
          String? name,
          Value<String?> coverFaceCropPath = const Value.absent(),
          Value<double?> similarityThreshold = const Value.absent(),
          Value<DateTime?> geburtsdatum = const Value.absent(),
          Value<DateTime?> sterbedatum = const Value.absent(),
          Value<String?> geschlecht = const Value.absent()}) =>
      PersonData(
        id: id ?? this.id,
        name: name ?? this.name,
        coverFaceCropPath: coverFaceCropPath.present
            ? coverFaceCropPath.value
            : this.coverFaceCropPath,
        similarityThreshold: similarityThreshold.present
            ? similarityThreshold.value
            : this.similarityThreshold,
        geburtsdatum:
            geburtsdatum.present ? geburtsdatum.value : this.geburtsdatum,
        sterbedatum: sterbedatum.present ? sterbedatum.value : this.sterbedatum,
        geschlecht: geschlecht.present ? geschlecht.value : this.geschlecht,
      );
  PersonData copyWithCompanion(PeopleCompanion data) {
    return PersonData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coverFaceCropPath: data.coverFaceCropPath.present
          ? data.coverFaceCropPath.value
          : this.coverFaceCropPath,
      similarityThreshold: data.similarityThreshold.present
          ? data.similarityThreshold.value
          : this.similarityThreshold,
      geburtsdatum: data.geburtsdatum.present
          ? data.geburtsdatum.value
          : this.geburtsdatum,
      sterbedatum:
          data.sterbedatum.present ? data.sterbedatum.value : this.sterbedatum,
      geschlecht:
          data.geschlecht.present ? data.geschlecht.value : this.geschlecht,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverFaceCropPath: $coverFaceCropPath, ')
          ..write('similarityThreshold: $similarityThreshold, ')
          ..write('geburtsdatum: $geburtsdatum, ')
          ..write('sterbedatum: $sterbedatum, ')
          ..write('geschlecht: $geschlecht')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, coverFaceCropPath,
      similarityThreshold, geburtsdatum, sterbedatum, geschlecht);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonData &&
          other.id == this.id &&
          other.name == this.name &&
          other.coverFaceCropPath == this.coverFaceCropPath &&
          other.similarityThreshold == this.similarityThreshold &&
          other.geburtsdatum == this.geburtsdatum &&
          other.sterbedatum == this.sterbedatum &&
          other.geschlecht == this.geschlecht);
}

class PeopleCompanion extends UpdateCompanion<PersonData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> coverFaceCropPath;
  final Value<double?> similarityThreshold;
  final Value<DateTime?> geburtsdatum;
  final Value<DateTime?> sterbedatum;
  final Value<String?> geschlecht;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.coverFaceCropPath = const Value.absent(),
    this.similarityThreshold = const Value.absent(),
    this.geburtsdatum = const Value.absent(),
    this.sterbedatum = const Value.absent(),
    this.geschlecht = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required String name,
    this.coverFaceCropPath = const Value.absent(),
    this.similarityThreshold = const Value.absent(),
    this.geburtsdatum = const Value.absent(),
    this.sterbedatum = const Value.absent(),
    this.geschlecht = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<PersonData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? coverFaceCropPath,
    Expression<double>? similarityThreshold,
    Expression<DateTime>? geburtsdatum,
    Expression<DateTime>? sterbedatum,
    Expression<String>? geschlecht,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coverFaceCropPath != null) 'cover_face_crop_path': coverFaceCropPath,
      if (similarityThreshold != null)
        'similarity_threshold': similarityThreshold,
      if (geburtsdatum != null) 'geburtsdatum': geburtsdatum,
      if (sterbedatum != null) 'sterbedatum': sterbedatum,
      if (geschlecht != null) 'geschlecht': geschlecht,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? coverFaceCropPath,
      Value<double?>? similarityThreshold,
      Value<DateTime?>? geburtsdatum,
      Value<DateTime?>? sterbedatum,
      Value<String?>? geschlecht,
      Value<int>? rowid}) {
    return PeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coverFaceCropPath: coverFaceCropPath ?? this.coverFaceCropPath,
      similarityThreshold: similarityThreshold ?? this.similarityThreshold,
      geburtsdatum: geburtsdatum ?? this.geburtsdatum,
      sterbedatum: sterbedatum ?? this.sterbedatum,
      geschlecht: geschlecht ?? this.geschlecht,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverFaceCropPath.present) {
      map['cover_face_crop_path'] = Variable<String>(coverFaceCropPath.value);
    }
    if (similarityThreshold.present) {
      map['similarity_threshold'] = Variable<double>(similarityThreshold.value);
    }
    if (geburtsdatum.present) {
      map['geburtsdatum'] = Variable<DateTime>(geburtsdatum.value);
    }
    if (sterbedatum.present) {
      map['sterbedatum'] = Variable<DateTime>(sterbedatum.value);
    }
    if (geschlecht.present) {
      map['geschlecht'] = Variable<String>(geschlecht.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverFaceCropPath: $coverFaceCropPath, ')
          ..write('similarityThreshold: $similarityThreshold, ')
          ..write('geburtsdatum: $geburtsdatum, ')
          ..write('sterbedatum: $sterbedatum, ')
          ..write('geschlecht: $geschlecht, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FacesTable extends Faces with TableInfo<$FacesTable, FaceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boxXMeta = const VerificationMeta('boxX');
  @override
  late final GeneratedColumn<double> boxX = GeneratedColumn<double>(
      'box_x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boxYMeta = const VerificationMeta('boxY');
  @override
  late final GeneratedColumn<double> boxY = GeneratedColumn<double>(
      'box_y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boxWMeta = const VerificationMeta('boxW');
  @override
  late final GeneratedColumn<double> boxW = GeneratedColumn<double>(
      'box_w', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boxHMeta = const VerificationMeta('boxH');
  @override
  late final GeneratedColumn<double> boxH = GeneratedColumn<double>(
      'box_h', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _cropRelativePathMeta =
      const VerificationMeta('cropRelativePath');
  @override
  late final GeneratedColumn<String> cropRelativePath = GeneratedColumn<String>(
      'crop_relative_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _embeddingMeta =
      const VerificationMeta('embedding');
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
      'embedding', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _eyeOpenScoreMeta =
      const VerificationMeta('eyeOpenScore');
  @override
  late final GeneratedColumn<double> eyeOpenScore = GeneratedColumn<double>(
      'eye_open_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isIgnoredMeta =
      const VerificationMeta('isIgnored');
  @override
  late final GeneratedColumn<bool> isIgnored = GeneratedColumn<bool>(
      'is_ignored', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_ignored" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        assetId,
        personId,
        boxX,
        boxY,
        boxW,
        boxH,
        cropRelativePath,
        embedding,
        eyeOpenScore,
        isIgnored
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faces';
  @override
  VerificationContext validateIntegrity(Insertable<FaceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    }
    if (data.containsKey('box_x')) {
      context.handle(
          _boxXMeta, boxX.isAcceptableOrUnknown(data['box_x']!, _boxXMeta));
    } else if (isInserting) {
      context.missing(_boxXMeta);
    }
    if (data.containsKey('box_y')) {
      context.handle(
          _boxYMeta, boxY.isAcceptableOrUnknown(data['box_y']!, _boxYMeta));
    } else if (isInserting) {
      context.missing(_boxYMeta);
    }
    if (data.containsKey('box_w')) {
      context.handle(
          _boxWMeta, boxW.isAcceptableOrUnknown(data['box_w']!, _boxWMeta));
    } else if (isInserting) {
      context.missing(_boxWMeta);
    }
    if (data.containsKey('box_h')) {
      context.handle(
          _boxHMeta, boxH.isAcceptableOrUnknown(data['box_h']!, _boxHMeta));
    } else if (isInserting) {
      context.missing(_boxHMeta);
    }
    if (data.containsKey('crop_relative_path')) {
      context.handle(
          _cropRelativePathMeta,
          cropRelativePath.isAcceptableOrUnknown(
              data['crop_relative_path']!, _cropRelativePathMeta));
    }
    if (data.containsKey('embedding')) {
      context.handle(_embeddingMeta,
          embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta));
    }
    if (data.containsKey('eye_open_score')) {
      context.handle(
          _eyeOpenScoreMeta,
          eyeOpenScore.isAcceptableOrUnknown(
              data['eye_open_score']!, _eyeOpenScoreMeta));
    }
    if (data.containsKey('is_ignored')) {
      context.handle(_isIgnoredMeta,
          isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FaceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FaceData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id']),
      boxX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}box_x'])!,
      boxY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}box_y'])!,
      boxW: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}box_w'])!,
      boxH: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}box_h'])!,
      cropRelativePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}crop_relative_path']),
      embedding: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}embedding']),
      eyeOpenScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}eye_open_score']),
      isIgnored: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_ignored'])!,
    );
  }

  @override
  $FacesTable createAlias(String alias) {
    return $FacesTable(attachedDatabase, alias);
  }
}

class FaceData extends DataClass implements Insertable<FaceData> {
  final String id;
  final String assetId;
  final String? personId;
  final double boxX;
  final double boxY;
  final double boxW;
  final double boxH;
  final String? cropRelativePath;
  final Uint8List? embedding;

  /// Wahrscheinlichkeit "Augen offen" (0..1, siehe EyeStateService) – `null`
  /// heißt "noch nicht berechnet" (kein Landmark verfügbar, oder das
  /// Augen-Modell war zum Scan-Zeitpunkt nicht installiert), NICHT "Augen
  /// geschlossen". Für die Sichtungs-Warnung erst ab einem gesetzten Wert
  /// unter dem Schwellenwert auswerten.
  final double? eyeOpenScore;

  /// Vom Nutzer beiseitegelegt: kein Gesicht (Plakat, Spiegelung, Statue)
  /// oder eine Person, die er nicht benennen will.
  ///
  /// Bewusst ein Merkmal statt eines Löschens. Löschen wäre endgültig und
  /// obendrein wirkungslos: Der nächste Gesichts-Scan fände dieselbe Stelle
  /// erneut und legte den Eintrag neu an. Ein beiseitegelegtes Gesicht
  /// verschwindet aus dem Raster und aus der automatischen Gruppierung,
  /// bleibt aber unter „Ignoriert" auffindbar und rückholbar.
  final bool isIgnored;
  const FaceData(
      {required this.id,
      required this.assetId,
      this.personId,
      required this.boxX,
      required this.boxY,
      required this.boxW,
      required this.boxH,
      this.cropRelativePath,
      this.embedding,
      this.eyeOpenScore,
      required this.isIgnored});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['asset_id'] = Variable<String>(assetId);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['box_x'] = Variable<double>(boxX);
    map['box_y'] = Variable<double>(boxY);
    map['box_w'] = Variable<double>(boxW);
    map['box_h'] = Variable<double>(boxH);
    if (!nullToAbsent || cropRelativePath != null) {
      map['crop_relative_path'] = Variable<String>(cropRelativePath);
    }
    if (!nullToAbsent || embedding != null) {
      map['embedding'] = Variable<Uint8List>(embedding);
    }
    if (!nullToAbsent || eyeOpenScore != null) {
      map['eye_open_score'] = Variable<double>(eyeOpenScore);
    }
    map['is_ignored'] = Variable<bool>(isIgnored);
    return map;
  }

  FacesCompanion toCompanion(bool nullToAbsent) {
    return FacesCompanion(
      id: Value(id),
      assetId: Value(assetId),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      boxX: Value(boxX),
      boxY: Value(boxY),
      boxW: Value(boxW),
      boxH: Value(boxH),
      cropRelativePath: cropRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(cropRelativePath),
      embedding: embedding == null && nullToAbsent
          ? const Value.absent()
          : Value(embedding),
      eyeOpenScore: eyeOpenScore == null && nullToAbsent
          ? const Value.absent()
          : Value(eyeOpenScore),
      isIgnored: Value(isIgnored),
    );
  }

  factory FaceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FaceData(
      id: serializer.fromJson<String>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      personId: serializer.fromJson<String?>(json['personId']),
      boxX: serializer.fromJson<double>(json['boxX']),
      boxY: serializer.fromJson<double>(json['boxY']),
      boxW: serializer.fromJson<double>(json['boxW']),
      boxH: serializer.fromJson<double>(json['boxH']),
      cropRelativePath: serializer.fromJson<String?>(json['cropRelativePath']),
      embedding: serializer.fromJson<Uint8List?>(json['embedding']),
      eyeOpenScore: serializer.fromJson<double?>(json['eyeOpenScore']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assetId': serializer.toJson<String>(assetId),
      'personId': serializer.toJson<String?>(personId),
      'boxX': serializer.toJson<double>(boxX),
      'boxY': serializer.toJson<double>(boxY),
      'boxW': serializer.toJson<double>(boxW),
      'boxH': serializer.toJson<double>(boxH),
      'cropRelativePath': serializer.toJson<String?>(cropRelativePath),
      'embedding': serializer.toJson<Uint8List?>(embedding),
      'eyeOpenScore': serializer.toJson<double?>(eyeOpenScore),
      'isIgnored': serializer.toJson<bool>(isIgnored),
    };
  }

  FaceData copyWith(
          {String? id,
          String? assetId,
          Value<String?> personId = const Value.absent(),
          double? boxX,
          double? boxY,
          double? boxW,
          double? boxH,
          Value<String?> cropRelativePath = const Value.absent(),
          Value<Uint8List?> embedding = const Value.absent(),
          Value<double?> eyeOpenScore = const Value.absent(),
          bool? isIgnored}) =>
      FaceData(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        personId: personId.present ? personId.value : this.personId,
        boxX: boxX ?? this.boxX,
        boxY: boxY ?? this.boxY,
        boxW: boxW ?? this.boxW,
        boxH: boxH ?? this.boxH,
        cropRelativePath: cropRelativePath.present
            ? cropRelativePath.value
            : this.cropRelativePath,
        embedding: embedding.present ? embedding.value : this.embedding,
        eyeOpenScore:
            eyeOpenScore.present ? eyeOpenScore.value : this.eyeOpenScore,
        isIgnored: isIgnored ?? this.isIgnored,
      );
  FaceData copyWithCompanion(FacesCompanion data) {
    return FaceData(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      personId: data.personId.present ? data.personId.value : this.personId,
      boxX: data.boxX.present ? data.boxX.value : this.boxX,
      boxY: data.boxY.present ? data.boxY.value : this.boxY,
      boxW: data.boxW.present ? data.boxW.value : this.boxW,
      boxH: data.boxH.present ? data.boxH.value : this.boxH,
      cropRelativePath: data.cropRelativePath.present
          ? data.cropRelativePath.value
          : this.cropRelativePath,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      eyeOpenScore: data.eyeOpenScore.present
          ? data.eyeOpenScore.value
          : this.eyeOpenScore,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FaceData(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('personId: $personId, ')
          ..write('boxX: $boxX, ')
          ..write('boxY: $boxY, ')
          ..write('boxW: $boxW, ')
          ..write('boxH: $boxH, ')
          ..write('cropRelativePath: $cropRelativePath, ')
          ..write('embedding: $embedding, ')
          ..write('eyeOpenScore: $eyeOpenScore, ')
          ..write('isIgnored: $isIgnored')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      assetId,
      personId,
      boxX,
      boxY,
      boxW,
      boxH,
      cropRelativePath,
      $driftBlobEquality.hash(embedding),
      eyeOpenScore,
      isIgnored);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaceData &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.personId == this.personId &&
          other.boxX == this.boxX &&
          other.boxY == this.boxY &&
          other.boxW == this.boxW &&
          other.boxH == this.boxH &&
          other.cropRelativePath == this.cropRelativePath &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.eyeOpenScore == this.eyeOpenScore &&
          other.isIgnored == this.isIgnored);
}

class FacesCompanion extends UpdateCompanion<FaceData> {
  final Value<String> id;
  final Value<String> assetId;
  final Value<String?> personId;
  final Value<double> boxX;
  final Value<double> boxY;
  final Value<double> boxW;
  final Value<double> boxH;
  final Value<String?> cropRelativePath;
  final Value<Uint8List?> embedding;
  final Value<double?> eyeOpenScore;
  final Value<bool> isIgnored;
  final Value<int> rowid;
  const FacesCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.personId = const Value.absent(),
    this.boxX = const Value.absent(),
    this.boxY = const Value.absent(),
    this.boxW = const Value.absent(),
    this.boxH = const Value.absent(),
    this.cropRelativePath = const Value.absent(),
    this.embedding = const Value.absent(),
    this.eyeOpenScore = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacesCompanion.insert({
    required String id,
    required String assetId,
    this.personId = const Value.absent(),
    required double boxX,
    required double boxY,
    required double boxW,
    required double boxH,
    this.cropRelativePath = const Value.absent(),
    this.embedding = const Value.absent(),
    this.eyeOpenScore = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        assetId = Value(assetId),
        boxX = Value(boxX),
        boxY = Value(boxY),
        boxW = Value(boxW),
        boxH = Value(boxH);
  static Insertable<FaceData> custom({
    Expression<String>? id,
    Expression<String>? assetId,
    Expression<String>? personId,
    Expression<double>? boxX,
    Expression<double>? boxY,
    Expression<double>? boxW,
    Expression<double>? boxH,
    Expression<String>? cropRelativePath,
    Expression<Uint8List>? embedding,
    Expression<double>? eyeOpenScore,
    Expression<bool>? isIgnored,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (personId != null) 'person_id': personId,
      if (boxX != null) 'box_x': boxX,
      if (boxY != null) 'box_y': boxY,
      if (boxW != null) 'box_w': boxW,
      if (boxH != null) 'box_h': boxH,
      if (cropRelativePath != null) 'crop_relative_path': cropRelativePath,
      if (embedding != null) 'embedding': embedding,
      if (eyeOpenScore != null) 'eye_open_score': eyeOpenScore,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacesCompanion copyWith(
      {Value<String>? id,
      Value<String>? assetId,
      Value<String?>? personId,
      Value<double>? boxX,
      Value<double>? boxY,
      Value<double>? boxW,
      Value<double>? boxH,
      Value<String?>? cropRelativePath,
      Value<Uint8List?>? embedding,
      Value<double?>? eyeOpenScore,
      Value<bool>? isIgnored,
      Value<int>? rowid}) {
    return FacesCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      personId: personId ?? this.personId,
      boxX: boxX ?? this.boxX,
      boxY: boxY ?? this.boxY,
      boxW: boxW ?? this.boxW,
      boxH: boxH ?? this.boxH,
      cropRelativePath: cropRelativePath ?? this.cropRelativePath,
      embedding: embedding ?? this.embedding,
      eyeOpenScore: eyeOpenScore ?? this.eyeOpenScore,
      isIgnored: isIgnored ?? this.isIgnored,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (boxX.present) {
      map['box_x'] = Variable<double>(boxX.value);
    }
    if (boxY.present) {
      map['box_y'] = Variable<double>(boxY.value);
    }
    if (boxW.present) {
      map['box_w'] = Variable<double>(boxW.value);
    }
    if (boxH.present) {
      map['box_h'] = Variable<double>(boxH.value);
    }
    if (cropRelativePath.present) {
      map['crop_relative_path'] = Variable<String>(cropRelativePath.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (eyeOpenScore.present) {
      map['eye_open_score'] = Variable<double>(eyeOpenScore.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacesCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('personId: $personId, ')
          ..write('boxX: $boxX, ')
          ..write('boxY: $boxY, ')
          ..write('boxW: $boxW, ')
          ..write('boxH: $boxH, ')
          ..write('cropRelativePath: $cropRelativePath, ')
          ..write('embedding: $embedding, ')
          ..write('eyeOpenScore: $eyeOpenScore, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FaceMatchFeedbackTable extends FaceMatchFeedback
    with TableInfo<$FaceMatchFeedbackTable, FaceMatchFeedbackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaceMatchFeedbackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _faceIdMeta = const VerificationMeta('faceId');
  @override
  late final GeneratedColumn<String> faceId = GeneratedColumn<String>(
      'face_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acceptedMeta =
      const VerificationMeta('accepted');
  @override
  late final GeneratedColumn<bool> accepted = GeneratedColumn<bool>(
      'accepted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("accepted" IN (0, 1))'));
  static const VerificationMeta _similarityMeta =
      const VerificationMeta('similarity');
  @override
  late final GeneratedColumn<double> similarity = GeneratedColumn<double>(
      'similarity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, personId, faceId, accepted, similarity, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'face_match_feedback';
  @override
  VerificationContext validateIntegrity(
      Insertable<FaceMatchFeedbackData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('face_id')) {
      context.handle(_faceIdMeta,
          faceId.isAcceptableOrUnknown(data['face_id']!, _faceIdMeta));
    } else if (isInserting) {
      context.missing(_faceIdMeta);
    }
    if (data.containsKey('accepted')) {
      context.handle(_acceptedMeta,
          accepted.isAcceptableOrUnknown(data['accepted']!, _acceptedMeta));
    } else if (isInserting) {
      context.missing(_acceptedMeta);
    }
    if (data.containsKey('similarity')) {
      context.handle(
          _similarityMeta,
          similarity.isAcceptableOrUnknown(
              data['similarity']!, _similarityMeta));
    } else if (isInserting) {
      context.missing(_similarityMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FaceMatchFeedbackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FaceMatchFeedbackData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      faceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}face_id'])!,
      accepted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}accepted'])!,
      similarity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}similarity'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FaceMatchFeedbackTable createAlias(String alias) {
    return $FaceMatchFeedbackTable(attachedDatabase, alias);
  }
}

class FaceMatchFeedbackData extends DataClass
    implements Insertable<FaceMatchFeedbackData> {
  final int id;
  final String personId;
  final String faceId;
  final bool accepted;
  final double similarity;
  final DateTime createdAt;
  const FaceMatchFeedbackData(
      {required this.id,
      required this.personId,
      required this.faceId,
      required this.accepted,
      required this.similarity,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<String>(personId);
    map['face_id'] = Variable<String>(faceId);
    map['accepted'] = Variable<bool>(accepted);
    map['similarity'] = Variable<double>(similarity);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FaceMatchFeedbackCompanion toCompanion(bool nullToAbsent) {
    return FaceMatchFeedbackCompanion(
      id: Value(id),
      personId: Value(personId),
      faceId: Value(faceId),
      accepted: Value(accepted),
      similarity: Value(similarity),
      createdAt: Value(createdAt),
    );
  }

  factory FaceMatchFeedbackData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FaceMatchFeedbackData(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      faceId: serializer.fromJson<String>(json['faceId']),
      accepted: serializer.fromJson<bool>(json['accepted']),
      similarity: serializer.fromJson<double>(json['similarity']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<String>(personId),
      'faceId': serializer.toJson<String>(faceId),
      'accepted': serializer.toJson<bool>(accepted),
      'similarity': serializer.toJson<double>(similarity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FaceMatchFeedbackData copyWith(
          {int? id,
          String? personId,
          String? faceId,
          bool? accepted,
          double? similarity,
          DateTime? createdAt}) =>
      FaceMatchFeedbackData(
        id: id ?? this.id,
        personId: personId ?? this.personId,
        faceId: faceId ?? this.faceId,
        accepted: accepted ?? this.accepted,
        similarity: similarity ?? this.similarity,
        createdAt: createdAt ?? this.createdAt,
      );
  FaceMatchFeedbackData copyWithCompanion(FaceMatchFeedbackCompanion data) {
    return FaceMatchFeedbackData(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      faceId: data.faceId.present ? data.faceId.value : this.faceId,
      accepted: data.accepted.present ? data.accepted.value : this.accepted,
      similarity:
          data.similarity.present ? data.similarity.value : this.similarity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FaceMatchFeedbackData(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('faceId: $faceId, ')
          ..write('accepted: $accepted, ')
          ..write('similarity: $similarity, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personId, faceId, accepted, similarity, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaceMatchFeedbackData &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.faceId == this.faceId &&
          other.accepted == this.accepted &&
          other.similarity == this.similarity &&
          other.createdAt == this.createdAt);
}

class FaceMatchFeedbackCompanion
    extends UpdateCompanion<FaceMatchFeedbackData> {
  final Value<int> id;
  final Value<String> personId;
  final Value<String> faceId;
  final Value<bool> accepted;
  final Value<double> similarity;
  final Value<DateTime> createdAt;
  const FaceMatchFeedbackCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.faceId = const Value.absent(),
    this.accepted = const Value.absent(),
    this.similarity = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FaceMatchFeedbackCompanion.insert({
    this.id = const Value.absent(),
    required String personId,
    required String faceId,
    required bool accepted,
    required double similarity,
    required DateTime createdAt,
  })  : personId = Value(personId),
        faceId = Value(faceId),
        accepted = Value(accepted),
        similarity = Value(similarity),
        createdAt = Value(createdAt);
  static Insertable<FaceMatchFeedbackData> custom({
    Expression<int>? id,
    Expression<String>? personId,
    Expression<String>? faceId,
    Expression<bool>? accepted,
    Expression<double>? similarity,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (faceId != null) 'face_id': faceId,
      if (accepted != null) 'accepted': accepted,
      if (similarity != null) 'similarity': similarity,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FaceMatchFeedbackCompanion copyWith(
      {Value<int>? id,
      Value<String>? personId,
      Value<String>? faceId,
      Value<bool>? accepted,
      Value<double>? similarity,
      Value<DateTime>? createdAt}) {
    return FaceMatchFeedbackCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      faceId: faceId ?? this.faceId,
      accepted: accepted ?? this.accepted,
      similarity: similarity ?? this.similarity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (faceId.present) {
      map['face_id'] = Variable<String>(faceId.value);
    }
    if (accepted.present) {
      map['accepted'] = Variable<bool>(accepted.value);
    }
    if (similarity.present) {
      map['similarity'] = Variable<double>(similarity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaceMatchFeedbackCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('faceId: $faceId, ')
          ..write('accepted: $accepted, ')
          ..write('similarity: $similarity, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ImageEmbeddingsTable extends ImageEmbeddings
    with TableInfo<$ImageEmbeddingsTable, ImageEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
      'vector', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [assetId, vector];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_embeddings';
  @override
  VerificationContext validateIntegrity(Insertable<ImageEmbedding> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(_vectorMeta,
          vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta));
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  ImageEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageEmbedding(
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      vector: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}vector'])!,
    );
  }

  @override
  $ImageEmbeddingsTable createAlias(String alias) {
    return $ImageEmbeddingsTable(attachedDatabase, alias);
  }
}

class ImageEmbedding extends DataClass implements Insertable<ImageEmbedding> {
  final String assetId;
  final Uint8List vector;
  const ImageEmbedding({required this.assetId, required this.vector});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['vector'] = Variable<Uint8List>(vector);
    return map;
  }

  ImageEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return ImageEmbeddingsCompanion(
      assetId: Value(assetId),
      vector: Value(vector),
    );
  }

  factory ImageEmbedding.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageEmbedding(
      assetId: serializer.fromJson<String>(json['assetId']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'vector': serializer.toJson<Uint8List>(vector),
    };
  }

  ImageEmbedding copyWith({String? assetId, Uint8List? vector}) =>
      ImageEmbedding(
        assetId: assetId ?? this.assetId,
        vector: vector ?? this.vector,
      );
  ImageEmbedding copyWithCompanion(ImageEmbeddingsCompanion data) {
    return ImageEmbedding(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      vector: data.vector.present ? data.vector.value : this.vector,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageEmbedding(')
          ..write('assetId: $assetId, ')
          ..write('vector: $vector')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetId, $driftBlobEquality.hash(vector));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageEmbedding &&
          other.assetId == this.assetId &&
          $driftBlobEquality.equals(other.vector, this.vector));
}

class ImageEmbeddingsCompanion extends UpdateCompanion<ImageEmbedding> {
  final Value<String> assetId;
  final Value<Uint8List> vector;
  final Value<int> rowid;
  const ImageEmbeddingsCompanion({
    this.assetId = const Value.absent(),
    this.vector = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageEmbeddingsCompanion.insert({
    required String assetId,
    required Uint8List vector,
    this.rowid = const Value.absent(),
  })  : assetId = Value(assetId),
        vector = Value(vector);
  static Insertable<ImageEmbedding> custom({
    Expression<String>? assetId,
    Expression<Uint8List>? vector,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (vector != null) 'vector': vector,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageEmbeddingsCompanion copyWith(
      {Value<String>? assetId, Value<Uint8List>? vector, Value<int>? rowid}) {
    return ImageEmbeddingsCompanion(
      assetId: assetId ?? this.assetId,
      vector: vector ?? this.vector,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageEmbeddingsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('vector: $vector, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupRecordsTable extends BackupRecords
    with TableInfo<$BackupRecordsTable, BackupRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _performedAtMeta =
      const VerificationMeta('performedAt');
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
      'performed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _destinationPathMeta =
      const VerificationMeta('destinationPath');
  @override
  late final GeneratedColumn<String> destinationPath = GeneratedColumn<String>(
      'destination_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileCountMeta =
      const VerificationMeta('fileCount');
  @override
  late final GeneratedColumn<int> fileCount = GeneratedColumn<int>(
      'file_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalBytesMeta =
      const VerificationMeta('totalBytes');
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
      'total_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, performedAt, destinationPath, fileCount, totalBytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_records';
  @override
  VerificationContext validateIntegrity(Insertable<BackupRecordData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
          _performedAtMeta,
          performedAt.isAcceptableOrUnknown(
              data['performed_at']!, _performedAtMeta));
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    if (data.containsKey('destination_path')) {
      context.handle(
          _destinationPathMeta,
          destinationPath.isAcceptableOrUnknown(
              data['destination_path']!, _destinationPathMeta));
    } else if (isInserting) {
      context.missing(_destinationPathMeta);
    }
    if (data.containsKey('file_count')) {
      context.handle(_fileCountMeta,
          fileCount.isAcceptableOrUnknown(data['file_count']!, _fileCountMeta));
    } else if (isInserting) {
      context.missing(_fileCountMeta);
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
          _totalBytesMeta,
          totalBytes.isAcceptableOrUnknown(
              data['total_bytes']!, _totalBytesMeta));
    } else if (isInserting) {
      context.missing(_totalBytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRecordData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      performedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}performed_at'])!,
      destinationPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_path'])!,
      fileCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_count'])!,
      totalBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_bytes'])!,
    );
  }

  @override
  $BackupRecordsTable createAlias(String alias) {
    return $BackupRecordsTable(attachedDatabase, alias);
  }
}

class BackupRecordData extends DataClass
    implements Insertable<BackupRecordData> {
  final String id;
  final DateTime performedAt;
  final String destinationPath;
  final int fileCount;
  final int totalBytes;
  const BackupRecordData(
      {required this.id,
      required this.performedAt,
      required this.destinationPath,
      required this.fileCount,
      required this.totalBytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['performed_at'] = Variable<DateTime>(performedAt);
    map['destination_path'] = Variable<String>(destinationPath);
    map['file_count'] = Variable<int>(fileCount);
    map['total_bytes'] = Variable<int>(totalBytes);
    return map;
  }

  BackupRecordsCompanion toCompanion(bool nullToAbsent) {
    return BackupRecordsCompanion(
      id: Value(id),
      performedAt: Value(performedAt),
      destinationPath: Value(destinationPath),
      fileCount: Value(fileCount),
      totalBytes: Value(totalBytes),
    );
  }

  factory BackupRecordData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRecordData(
      id: serializer.fromJson<String>(json['id']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      destinationPath: serializer.fromJson<String>(json['destinationPath']),
      fileCount: serializer.fromJson<int>(json['fileCount']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'destinationPath': serializer.toJson<String>(destinationPath),
      'fileCount': serializer.toJson<int>(fileCount),
      'totalBytes': serializer.toJson<int>(totalBytes),
    };
  }

  BackupRecordData copyWith(
          {String? id,
          DateTime? performedAt,
          String? destinationPath,
          int? fileCount,
          int? totalBytes}) =>
      BackupRecordData(
        id: id ?? this.id,
        performedAt: performedAt ?? this.performedAt,
        destinationPath: destinationPath ?? this.destinationPath,
        fileCount: fileCount ?? this.fileCount,
        totalBytes: totalBytes ?? this.totalBytes,
      );
  BackupRecordData copyWithCompanion(BackupRecordsCompanion data) {
    return BackupRecordData(
      id: data.id.present ? data.id.value : this.id,
      performedAt:
          data.performedAt.present ? data.performedAt.value : this.performedAt,
      destinationPath: data.destinationPath.present
          ? data.destinationPath.value
          : this.destinationPath,
      fileCount: data.fileCount.present ? data.fileCount.value : this.fileCount,
      totalBytes:
          data.totalBytes.present ? data.totalBytes.value : this.totalBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecordData(')
          ..write('id: $id, ')
          ..write('performedAt: $performedAt, ')
          ..write('destinationPath: $destinationPath, ')
          ..write('fileCount: $fileCount, ')
          ..write('totalBytes: $totalBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, performedAt, destinationPath, fileCount, totalBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRecordData &&
          other.id == this.id &&
          other.performedAt == this.performedAt &&
          other.destinationPath == this.destinationPath &&
          other.fileCount == this.fileCount &&
          other.totalBytes == this.totalBytes);
}

class BackupRecordsCompanion extends UpdateCompanion<BackupRecordData> {
  final Value<String> id;
  final Value<DateTime> performedAt;
  final Value<String> destinationPath;
  final Value<int> fileCount;
  final Value<int> totalBytes;
  final Value<int> rowid;
  const BackupRecordsCompanion({
    this.id = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.destinationPath = const Value.absent(),
    this.fileCount = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupRecordsCompanion.insert({
    required String id,
    required DateTime performedAt,
    required String destinationPath,
    required int fileCount,
    required int totalBytes,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        performedAt = Value(performedAt),
        destinationPath = Value(destinationPath),
        fileCount = Value(fileCount),
        totalBytes = Value(totalBytes);
  static Insertable<BackupRecordData> custom({
    Expression<String>? id,
    Expression<DateTime>? performedAt,
    Expression<String>? destinationPath,
    Expression<int>? fileCount,
    Expression<int>? totalBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (performedAt != null) 'performed_at': performedAt,
      if (destinationPath != null) 'destination_path': destinationPath,
      if (fileCount != null) 'file_count': fileCount,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupRecordsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? performedAt,
      Value<String>? destinationPath,
      Value<int>? fileCount,
      Value<int>? totalBytes,
      Value<int>? rowid}) {
    return BackupRecordsCompanion(
      id: id ?? this.id,
      performedAt: performedAt ?? this.performedAt,
      destinationPath: destinationPath ?? this.destinationPath,
      fileCount: fileCount ?? this.fileCount,
      totalBytes: totalBytes ?? this.totalBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (destinationPath.present) {
      map['destination_path'] = Variable<String>(destinationPath.value);
    }
    if (fileCount.present) {
      map['file_count'] = Variable<int>(fileCount.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecordsCompanion(')
          ..write('id: $id, ')
          ..write('performedAt: $performedAt, ')
          ..write('destinationPath: $destinationPath, ')
          ..write('fileCount: $fileCount, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrivacySettingsTable extends PrivacySettings
    with TableInfo<$PrivacySettingsTable, PrivacySettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrivacySettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pinHashMeta =
      const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
      'pin_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pinSaltMeta =
      const VerificationMeta('pinSalt');
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
      'pin_salt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kdfSaltMeta =
      const VerificationMeta('kdfSalt');
  @override
  late final GeneratedColumn<Uint8List> kdfSalt = GeneratedColumn<Uint8List>(
      'kdf_salt', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _wrappedMasterKeyNonceMeta =
      const VerificationMeta('wrappedMasterKeyNonce');
  @override
  late final GeneratedColumn<Uint8List> wrappedMasterKeyNonce =
      GeneratedColumn<Uint8List>('wrapped_master_key_nonce', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _wrappedMasterKeyMeta =
      const VerificationMeta('wrappedMasterKey');
  @override
  late final GeneratedColumn<Uint8List> wrappedMasterKey =
      GeneratedColumn<Uint8List>('wrapped_master_key', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, pinHash, pinSalt, kdfSalt, wrappedMasterKeyNonce, wrappedMasterKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'privacy_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<PrivacySettingsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta,
          pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    }
    if (data.containsKey('pin_salt')) {
      context.handle(_pinSaltMeta,
          pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta));
    }
    if (data.containsKey('kdf_salt')) {
      context.handle(_kdfSaltMeta,
          kdfSalt.isAcceptableOrUnknown(data['kdf_salt']!, _kdfSaltMeta));
    }
    if (data.containsKey('wrapped_master_key_nonce')) {
      context.handle(
          _wrappedMasterKeyNonceMeta,
          wrappedMasterKeyNonce.isAcceptableOrUnknown(
              data['wrapped_master_key_nonce']!, _wrappedMasterKeyNonceMeta));
    }
    if (data.containsKey('wrapped_master_key')) {
      context.handle(
          _wrappedMasterKeyMeta,
          wrappedMasterKey.isAcceptableOrUnknown(
              data['wrapped_master_key']!, _wrappedMasterKeyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrivacySettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrivacySettingsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pinHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_hash']),
      pinSalt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_salt']),
      kdfSalt: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}kdf_salt']),
      wrappedMasterKeyNonce: attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}wrapped_master_key_nonce']),
      wrappedMasterKey: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}wrapped_master_key']),
    );
  }

  @override
  $PrivacySettingsTable createAlias(String alias) {
    return $PrivacySettingsTable(attachedDatabase, alias);
  }
}

class PrivacySettingsData extends DataClass
    implements Insertable<PrivacySettingsData> {
  final int id;
  final String? pinHash;
  final String? pinSalt;
  final Uint8List? kdfSalt;
  final Uint8List? wrappedMasterKeyNonce;
  final Uint8List? wrappedMasterKey;
  const PrivacySettingsData(
      {required this.id,
      this.pinHash,
      this.pinSalt,
      this.kdfSalt,
      this.wrappedMasterKeyNonce,
      this.wrappedMasterKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    if (!nullToAbsent || pinSalt != null) {
      map['pin_salt'] = Variable<String>(pinSalt);
    }
    if (!nullToAbsent || kdfSalt != null) {
      map['kdf_salt'] = Variable<Uint8List>(kdfSalt);
    }
    if (!nullToAbsent || wrappedMasterKeyNonce != null) {
      map['wrapped_master_key_nonce'] =
          Variable<Uint8List>(wrappedMasterKeyNonce);
    }
    if (!nullToAbsent || wrappedMasterKey != null) {
      map['wrapped_master_key'] = Variable<Uint8List>(wrappedMasterKey);
    }
    return map;
  }

  PrivacySettingsCompanion toCompanion(bool nullToAbsent) {
    return PrivacySettingsCompanion(
      id: Value(id),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      pinSalt: pinSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinSalt),
      kdfSalt: kdfSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(kdfSalt),
      wrappedMasterKeyNonce: wrappedMasterKeyNonce == null && nullToAbsent
          ? const Value.absent()
          : Value(wrappedMasterKeyNonce),
      wrappedMasterKey: wrappedMasterKey == null && nullToAbsent
          ? const Value.absent()
          : Value(wrappedMasterKey),
    );
  }

  factory PrivacySettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrivacySettingsData(
      id: serializer.fromJson<int>(json['id']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      pinSalt: serializer.fromJson<String?>(json['pinSalt']),
      kdfSalt: serializer.fromJson<Uint8List?>(json['kdfSalt']),
      wrappedMasterKeyNonce:
          serializer.fromJson<Uint8List?>(json['wrappedMasterKeyNonce']),
      wrappedMasterKey:
          serializer.fromJson<Uint8List?>(json['wrappedMasterKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pinHash': serializer.toJson<String?>(pinHash),
      'pinSalt': serializer.toJson<String?>(pinSalt),
      'kdfSalt': serializer.toJson<Uint8List?>(kdfSalt),
      'wrappedMasterKeyNonce':
          serializer.toJson<Uint8List?>(wrappedMasterKeyNonce),
      'wrappedMasterKey': serializer.toJson<Uint8List?>(wrappedMasterKey),
    };
  }

  PrivacySettingsData copyWith(
          {int? id,
          Value<String?> pinHash = const Value.absent(),
          Value<String?> pinSalt = const Value.absent(),
          Value<Uint8List?> kdfSalt = const Value.absent(),
          Value<Uint8List?> wrappedMasterKeyNonce = const Value.absent(),
          Value<Uint8List?> wrappedMasterKey = const Value.absent()}) =>
      PrivacySettingsData(
        id: id ?? this.id,
        pinHash: pinHash.present ? pinHash.value : this.pinHash,
        pinSalt: pinSalt.present ? pinSalt.value : this.pinSalt,
        kdfSalt: kdfSalt.present ? kdfSalt.value : this.kdfSalt,
        wrappedMasterKeyNonce: wrappedMasterKeyNonce.present
            ? wrappedMasterKeyNonce.value
            : this.wrappedMasterKeyNonce,
        wrappedMasterKey: wrappedMasterKey.present
            ? wrappedMasterKey.value
            : this.wrappedMasterKey,
      );
  PrivacySettingsData copyWithCompanion(PrivacySettingsCompanion data) {
    return PrivacySettingsData(
      id: data.id.present ? data.id.value : this.id,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      kdfSalt: data.kdfSalt.present ? data.kdfSalt.value : this.kdfSalt,
      wrappedMasterKeyNonce: data.wrappedMasterKeyNonce.present
          ? data.wrappedMasterKeyNonce.value
          : this.wrappedMasterKeyNonce,
      wrappedMasterKey: data.wrappedMasterKey.present
          ? data.wrappedMasterKey.value
          : this.wrappedMasterKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrivacySettingsData(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('kdfSalt: $kdfSalt, ')
          ..write('wrappedMasterKeyNonce: $wrappedMasterKeyNonce, ')
          ..write('wrappedMasterKey: $wrappedMasterKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      pinHash,
      pinSalt,
      $driftBlobEquality.hash(kdfSalt),
      $driftBlobEquality.hash(wrappedMasterKeyNonce),
      $driftBlobEquality.hash(wrappedMasterKey));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrivacySettingsData &&
          other.id == this.id &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          $driftBlobEquality.equals(other.kdfSalt, this.kdfSalt) &&
          $driftBlobEquality.equals(
              other.wrappedMasterKeyNonce, this.wrappedMasterKeyNonce) &&
          $driftBlobEquality.equals(
              other.wrappedMasterKey, this.wrappedMasterKey));
}

class PrivacySettingsCompanion extends UpdateCompanion<PrivacySettingsData> {
  final Value<int> id;
  final Value<String?> pinHash;
  final Value<String?> pinSalt;
  final Value<Uint8List?> kdfSalt;
  final Value<Uint8List?> wrappedMasterKeyNonce;
  final Value<Uint8List?> wrappedMasterKey;
  const PrivacySettingsCompanion({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.kdfSalt = const Value.absent(),
    this.wrappedMasterKeyNonce = const Value.absent(),
    this.wrappedMasterKey = const Value.absent(),
  });
  PrivacySettingsCompanion.insert({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.kdfSalt = const Value.absent(),
    this.wrappedMasterKeyNonce = const Value.absent(),
    this.wrappedMasterKey = const Value.absent(),
  });
  static Insertable<PrivacySettingsData> custom({
    Expression<int>? id,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<Uint8List>? kdfSalt,
    Expression<Uint8List>? wrappedMasterKeyNonce,
    Expression<Uint8List>? wrappedMasterKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (kdfSalt != null) 'kdf_salt': kdfSalt,
      if (wrappedMasterKeyNonce != null)
        'wrapped_master_key_nonce': wrappedMasterKeyNonce,
      if (wrappedMasterKey != null) 'wrapped_master_key': wrappedMasterKey,
    });
  }

  PrivacySettingsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? pinHash,
      Value<String?>? pinSalt,
      Value<Uint8List?>? kdfSalt,
      Value<Uint8List?>? wrappedMasterKeyNonce,
      Value<Uint8List?>? wrappedMasterKey}) {
    return PrivacySettingsCompanion(
      id: id ?? this.id,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      kdfSalt: kdfSalt ?? this.kdfSalt,
      wrappedMasterKeyNonce:
          wrappedMasterKeyNonce ?? this.wrappedMasterKeyNonce,
      wrappedMasterKey: wrappedMasterKey ?? this.wrappedMasterKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (kdfSalt.present) {
      map['kdf_salt'] = Variable<Uint8List>(kdfSalt.value);
    }
    if (wrappedMasterKeyNonce.present) {
      map['wrapped_master_key_nonce'] =
          Variable<Uint8List>(wrappedMasterKeyNonce.value);
    }
    if (wrappedMasterKey.present) {
      map['wrapped_master_key'] = Variable<Uint8List>(wrappedMasterKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrivacySettingsCompanion(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('kdfSalt: $kdfSalt, ')
          ..write('wrappedMasterKeyNonce: $wrappedMasterKeyNonce, ')
          ..write('wrappedMasterKey: $wrappedMasterKey')
          ..write(')'))
        .toString();
  }
}

class $BackupSettingsTable extends BackupSettings
    with TableInfo<$BackupSettingsTable, BackupSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _kdfSaltMeta =
      const VerificationMeta('kdfSalt');
  @override
  late final GeneratedColumn<Uint8List> kdfSalt = GeneratedColumn<Uint8List>(
      'kdf_salt', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _wrappedMasterKeyNonceMeta =
      const VerificationMeta('wrappedMasterKeyNonce');
  @override
  late final GeneratedColumn<Uint8List> wrappedMasterKeyNonce =
      GeneratedColumn<Uint8List>('wrapped_master_key_nonce', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _wrappedMasterKeyMeta =
      const VerificationMeta('wrappedMasterKey');
  @override
  late final GeneratedColumn<Uint8List> wrappedMasterKey =
      GeneratedColumn<Uint8List>('wrapped_master_key', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _autoBackupEnabledMeta =
      const VerificationMeta('autoBackupEnabled');
  @override
  late final GeneratedColumn<bool> autoBackupEnabled = GeneratedColumn<bool>(
      'auto_backup_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_backup_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autoBackupDestinationMeta =
      const VerificationMeta('autoBackupDestination');
  @override
  late final GeneratedColumn<String> autoBackupDestination =
      GeneratedColumn<String>('auto_backup_destination', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _autoBackupIntervalHoursMeta =
      const VerificationMeta('autoBackupIntervalHours');
  @override
  late final GeneratedColumn<int> autoBackupIntervalHours =
      GeneratedColumn<int>('auto_backup_interval_hours', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(24));
  static const VerificationMeta _lastAutoBackupAtMeta =
      const VerificationMeta('lastAutoBackupAt');
  @override
  late final GeneratedColumn<DateTime> lastAutoBackupAt =
      GeneratedColumn<DateTime>('last_auto_backup_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _autoBackupMaxMbPerRunMeta =
      const VerificationMeta('autoBackupMaxMbPerRun');
  @override
  late final GeneratedColumn<int> autoBackupMaxMbPerRun = GeneratedColumn<int>(
      'auto_backup_max_mb_per_run', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kdfSalt,
        wrappedMasterKeyNonce,
        wrappedMasterKey,
        autoBackupEnabled,
        autoBackupDestination,
        autoBackupIntervalHours,
        lastAutoBackupAt,
        autoBackupMaxMbPerRun
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_settings';
  @override
  VerificationContext validateIntegrity(Insertable<BackupSettingsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kdf_salt')) {
      context.handle(_kdfSaltMeta,
          kdfSalt.isAcceptableOrUnknown(data['kdf_salt']!, _kdfSaltMeta));
    }
    if (data.containsKey('wrapped_master_key_nonce')) {
      context.handle(
          _wrappedMasterKeyNonceMeta,
          wrappedMasterKeyNonce.isAcceptableOrUnknown(
              data['wrapped_master_key_nonce']!, _wrappedMasterKeyNonceMeta));
    }
    if (data.containsKey('wrapped_master_key')) {
      context.handle(
          _wrappedMasterKeyMeta,
          wrappedMasterKey.isAcceptableOrUnknown(
              data['wrapped_master_key']!, _wrappedMasterKeyMeta));
    }
    if (data.containsKey('auto_backup_enabled')) {
      context.handle(
          _autoBackupEnabledMeta,
          autoBackupEnabled.isAcceptableOrUnknown(
              data['auto_backup_enabled']!, _autoBackupEnabledMeta));
    }
    if (data.containsKey('auto_backup_destination')) {
      context.handle(
          _autoBackupDestinationMeta,
          autoBackupDestination.isAcceptableOrUnknown(
              data['auto_backup_destination']!, _autoBackupDestinationMeta));
    }
    if (data.containsKey('auto_backup_interval_hours')) {
      context.handle(
          _autoBackupIntervalHoursMeta,
          autoBackupIntervalHours.isAcceptableOrUnknown(
              data['auto_backup_interval_hours']!,
              _autoBackupIntervalHoursMeta));
    }
    if (data.containsKey('last_auto_backup_at')) {
      context.handle(
          _lastAutoBackupAtMeta,
          lastAutoBackupAt.isAcceptableOrUnknown(
              data['last_auto_backup_at']!, _lastAutoBackupAtMeta));
    }
    if (data.containsKey('auto_backup_max_mb_per_run')) {
      context.handle(
          _autoBackupMaxMbPerRunMeta,
          autoBackupMaxMbPerRun.isAcceptableOrUnknown(
              data['auto_backup_max_mb_per_run']!, _autoBackupMaxMbPerRunMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupSettingsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kdfSalt: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}kdf_salt']),
      wrappedMasterKeyNonce: attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}wrapped_master_key_nonce']),
      wrappedMasterKey: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}wrapped_master_key']),
      autoBackupEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_backup_enabled'])!,
      autoBackupDestination: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}auto_backup_destination']),
      autoBackupIntervalHours: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}auto_backup_interval_hours'])!,
      lastAutoBackupAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_auto_backup_at']),
      autoBackupMaxMbPerRun: attachedDatabase.typeMapping.read(DriftSqlType.int,
          data['${effectivePrefix}auto_backup_max_mb_per_run'])!,
    );
  }

  @override
  $BackupSettingsTable createAlias(String alias) {
    return $BackupSettingsTable(attachedDatabase, alias);
  }
}

class BackupSettingsData extends DataClass
    implements Insertable<BackupSettingsData> {
  final int id;
  final Uint8List? kdfSalt;
  final Uint8List? wrappedMasterKeyNonce;
  final Uint8List? wrappedMasterKey;
  final bool autoBackupEnabled;
  final String? autoBackupDestination;
  final int autoBackupIntervalHours;
  final DateTime? lastAutoBackupAt;

  /// Obergrenze je Sicherungslauf in Megabyte, 0 = unbegrenzt.
  ///
  /// Gedacht für Cloud-Ordner: Ohne Grenze landen bei der ersten Sicherung
  /// zigtausend Dateien auf einmal im Sync-Ordner, und der Upload läuft
  /// danach stunden- bis tagelang. Mit Grenze wird portionsweise gesichert,
  /// der Rest folgt beim nächsten Intervall.
  final int autoBackupMaxMbPerRun;
  const BackupSettingsData(
      {required this.id,
      this.kdfSalt,
      this.wrappedMasterKeyNonce,
      this.wrappedMasterKey,
      required this.autoBackupEnabled,
      this.autoBackupDestination,
      required this.autoBackupIntervalHours,
      this.lastAutoBackupAt,
      required this.autoBackupMaxMbPerRun});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || kdfSalt != null) {
      map['kdf_salt'] = Variable<Uint8List>(kdfSalt);
    }
    if (!nullToAbsent || wrappedMasterKeyNonce != null) {
      map['wrapped_master_key_nonce'] =
          Variable<Uint8List>(wrappedMasterKeyNonce);
    }
    if (!nullToAbsent || wrappedMasterKey != null) {
      map['wrapped_master_key'] = Variable<Uint8List>(wrappedMasterKey);
    }
    map['auto_backup_enabled'] = Variable<bool>(autoBackupEnabled);
    if (!nullToAbsent || autoBackupDestination != null) {
      map['auto_backup_destination'] = Variable<String>(autoBackupDestination);
    }
    map['auto_backup_interval_hours'] = Variable<int>(autoBackupIntervalHours);
    if (!nullToAbsent || lastAutoBackupAt != null) {
      map['last_auto_backup_at'] = Variable<DateTime>(lastAutoBackupAt);
    }
    map['auto_backup_max_mb_per_run'] = Variable<int>(autoBackupMaxMbPerRun);
    return map;
  }

  BackupSettingsCompanion toCompanion(bool nullToAbsent) {
    return BackupSettingsCompanion(
      id: Value(id),
      kdfSalt: kdfSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(kdfSalt),
      wrappedMasterKeyNonce: wrappedMasterKeyNonce == null && nullToAbsent
          ? const Value.absent()
          : Value(wrappedMasterKeyNonce),
      wrappedMasterKey: wrappedMasterKey == null && nullToAbsent
          ? const Value.absent()
          : Value(wrappedMasterKey),
      autoBackupEnabled: Value(autoBackupEnabled),
      autoBackupDestination: autoBackupDestination == null && nullToAbsent
          ? const Value.absent()
          : Value(autoBackupDestination),
      autoBackupIntervalHours: Value(autoBackupIntervalHours),
      lastAutoBackupAt: lastAutoBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAutoBackupAt),
      autoBackupMaxMbPerRun: Value(autoBackupMaxMbPerRun),
    );
  }

  factory BackupSettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupSettingsData(
      id: serializer.fromJson<int>(json['id']),
      kdfSalt: serializer.fromJson<Uint8List?>(json['kdfSalt']),
      wrappedMasterKeyNonce:
          serializer.fromJson<Uint8List?>(json['wrappedMasterKeyNonce']),
      wrappedMasterKey:
          serializer.fromJson<Uint8List?>(json['wrappedMasterKey']),
      autoBackupEnabled: serializer.fromJson<bool>(json['autoBackupEnabled']),
      autoBackupDestination:
          serializer.fromJson<String?>(json['autoBackupDestination']),
      autoBackupIntervalHours:
          serializer.fromJson<int>(json['autoBackupIntervalHours']),
      lastAutoBackupAt:
          serializer.fromJson<DateTime?>(json['lastAutoBackupAt']),
      autoBackupMaxMbPerRun:
          serializer.fromJson<int>(json['autoBackupMaxMbPerRun']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kdfSalt': serializer.toJson<Uint8List?>(kdfSalt),
      'wrappedMasterKeyNonce':
          serializer.toJson<Uint8List?>(wrappedMasterKeyNonce),
      'wrappedMasterKey': serializer.toJson<Uint8List?>(wrappedMasterKey),
      'autoBackupEnabled': serializer.toJson<bool>(autoBackupEnabled),
      'autoBackupDestination':
          serializer.toJson<String?>(autoBackupDestination),
      'autoBackupIntervalHours':
          serializer.toJson<int>(autoBackupIntervalHours),
      'lastAutoBackupAt': serializer.toJson<DateTime?>(lastAutoBackupAt),
      'autoBackupMaxMbPerRun': serializer.toJson<int>(autoBackupMaxMbPerRun),
    };
  }

  BackupSettingsData copyWith(
          {int? id,
          Value<Uint8List?> kdfSalt = const Value.absent(),
          Value<Uint8List?> wrappedMasterKeyNonce = const Value.absent(),
          Value<Uint8List?> wrappedMasterKey = const Value.absent(),
          bool? autoBackupEnabled,
          Value<String?> autoBackupDestination = const Value.absent(),
          int? autoBackupIntervalHours,
          Value<DateTime?> lastAutoBackupAt = const Value.absent(),
          int? autoBackupMaxMbPerRun}) =>
      BackupSettingsData(
        id: id ?? this.id,
        kdfSalt: kdfSalt.present ? kdfSalt.value : this.kdfSalt,
        wrappedMasterKeyNonce: wrappedMasterKeyNonce.present
            ? wrappedMasterKeyNonce.value
            : this.wrappedMasterKeyNonce,
        wrappedMasterKey: wrappedMasterKey.present
            ? wrappedMasterKey.value
            : this.wrappedMasterKey,
        autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
        autoBackupDestination: autoBackupDestination.present
            ? autoBackupDestination.value
            : this.autoBackupDestination,
        autoBackupIntervalHours:
            autoBackupIntervalHours ?? this.autoBackupIntervalHours,
        lastAutoBackupAt: lastAutoBackupAt.present
            ? lastAutoBackupAt.value
            : this.lastAutoBackupAt,
        autoBackupMaxMbPerRun:
            autoBackupMaxMbPerRun ?? this.autoBackupMaxMbPerRun,
      );
  BackupSettingsData copyWithCompanion(BackupSettingsCompanion data) {
    return BackupSettingsData(
      id: data.id.present ? data.id.value : this.id,
      kdfSalt: data.kdfSalt.present ? data.kdfSalt.value : this.kdfSalt,
      wrappedMasterKeyNonce: data.wrappedMasterKeyNonce.present
          ? data.wrappedMasterKeyNonce.value
          : this.wrappedMasterKeyNonce,
      wrappedMasterKey: data.wrappedMasterKey.present
          ? data.wrappedMasterKey.value
          : this.wrappedMasterKey,
      autoBackupEnabled: data.autoBackupEnabled.present
          ? data.autoBackupEnabled.value
          : this.autoBackupEnabled,
      autoBackupDestination: data.autoBackupDestination.present
          ? data.autoBackupDestination.value
          : this.autoBackupDestination,
      autoBackupIntervalHours: data.autoBackupIntervalHours.present
          ? data.autoBackupIntervalHours.value
          : this.autoBackupIntervalHours,
      lastAutoBackupAt: data.lastAutoBackupAt.present
          ? data.lastAutoBackupAt.value
          : this.lastAutoBackupAt,
      autoBackupMaxMbPerRun: data.autoBackupMaxMbPerRun.present
          ? data.autoBackupMaxMbPerRun.value
          : this.autoBackupMaxMbPerRun,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupSettingsData(')
          ..write('id: $id, ')
          ..write('kdfSalt: $kdfSalt, ')
          ..write('wrappedMasterKeyNonce: $wrappedMasterKeyNonce, ')
          ..write('wrappedMasterKey: $wrappedMasterKey, ')
          ..write('autoBackupEnabled: $autoBackupEnabled, ')
          ..write('autoBackupDestination: $autoBackupDestination, ')
          ..write('autoBackupIntervalHours: $autoBackupIntervalHours, ')
          ..write('lastAutoBackupAt: $lastAutoBackupAt, ')
          ..write('autoBackupMaxMbPerRun: $autoBackupMaxMbPerRun')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      $driftBlobEquality.hash(kdfSalt),
      $driftBlobEquality.hash(wrappedMasterKeyNonce),
      $driftBlobEquality.hash(wrappedMasterKey),
      autoBackupEnabled,
      autoBackupDestination,
      autoBackupIntervalHours,
      lastAutoBackupAt,
      autoBackupMaxMbPerRun);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupSettingsData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.kdfSalt, this.kdfSalt) &&
          $driftBlobEquality.equals(
              other.wrappedMasterKeyNonce, this.wrappedMasterKeyNonce) &&
          $driftBlobEquality.equals(
              other.wrappedMasterKey, this.wrappedMasterKey) &&
          other.autoBackupEnabled == this.autoBackupEnabled &&
          other.autoBackupDestination == this.autoBackupDestination &&
          other.autoBackupIntervalHours == this.autoBackupIntervalHours &&
          other.lastAutoBackupAt == this.lastAutoBackupAt &&
          other.autoBackupMaxMbPerRun == this.autoBackupMaxMbPerRun);
}

class BackupSettingsCompanion extends UpdateCompanion<BackupSettingsData> {
  final Value<int> id;
  final Value<Uint8List?> kdfSalt;
  final Value<Uint8List?> wrappedMasterKeyNonce;
  final Value<Uint8List?> wrappedMasterKey;
  final Value<bool> autoBackupEnabled;
  final Value<String?> autoBackupDestination;
  final Value<int> autoBackupIntervalHours;
  final Value<DateTime?> lastAutoBackupAt;
  final Value<int> autoBackupMaxMbPerRun;
  const BackupSettingsCompanion({
    this.id = const Value.absent(),
    this.kdfSalt = const Value.absent(),
    this.wrappedMasterKeyNonce = const Value.absent(),
    this.wrappedMasterKey = const Value.absent(),
    this.autoBackupEnabled = const Value.absent(),
    this.autoBackupDestination = const Value.absent(),
    this.autoBackupIntervalHours = const Value.absent(),
    this.lastAutoBackupAt = const Value.absent(),
    this.autoBackupMaxMbPerRun = const Value.absent(),
  });
  BackupSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.kdfSalt = const Value.absent(),
    this.wrappedMasterKeyNonce = const Value.absent(),
    this.wrappedMasterKey = const Value.absent(),
    this.autoBackupEnabled = const Value.absent(),
    this.autoBackupDestination = const Value.absent(),
    this.autoBackupIntervalHours = const Value.absent(),
    this.lastAutoBackupAt = const Value.absent(),
    this.autoBackupMaxMbPerRun = const Value.absent(),
  });
  static Insertable<BackupSettingsData> custom({
    Expression<int>? id,
    Expression<Uint8List>? kdfSalt,
    Expression<Uint8List>? wrappedMasterKeyNonce,
    Expression<Uint8List>? wrappedMasterKey,
    Expression<bool>? autoBackupEnabled,
    Expression<String>? autoBackupDestination,
    Expression<int>? autoBackupIntervalHours,
    Expression<DateTime>? lastAutoBackupAt,
    Expression<int>? autoBackupMaxMbPerRun,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kdfSalt != null) 'kdf_salt': kdfSalt,
      if (wrappedMasterKeyNonce != null)
        'wrapped_master_key_nonce': wrappedMasterKeyNonce,
      if (wrappedMasterKey != null) 'wrapped_master_key': wrappedMasterKey,
      if (autoBackupEnabled != null) 'auto_backup_enabled': autoBackupEnabled,
      if (autoBackupDestination != null)
        'auto_backup_destination': autoBackupDestination,
      if (autoBackupIntervalHours != null)
        'auto_backup_interval_hours': autoBackupIntervalHours,
      if (lastAutoBackupAt != null) 'last_auto_backup_at': lastAutoBackupAt,
      if (autoBackupMaxMbPerRun != null)
        'auto_backup_max_mb_per_run': autoBackupMaxMbPerRun,
    });
  }

  BackupSettingsCompanion copyWith(
      {Value<int>? id,
      Value<Uint8List?>? kdfSalt,
      Value<Uint8List?>? wrappedMasterKeyNonce,
      Value<Uint8List?>? wrappedMasterKey,
      Value<bool>? autoBackupEnabled,
      Value<String?>? autoBackupDestination,
      Value<int>? autoBackupIntervalHours,
      Value<DateTime?>? lastAutoBackupAt,
      Value<int>? autoBackupMaxMbPerRun}) {
    return BackupSettingsCompanion(
      id: id ?? this.id,
      kdfSalt: kdfSalt ?? this.kdfSalt,
      wrappedMasterKeyNonce:
          wrappedMasterKeyNonce ?? this.wrappedMasterKeyNonce,
      wrappedMasterKey: wrappedMasterKey ?? this.wrappedMasterKey,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupDestination:
          autoBackupDestination ?? this.autoBackupDestination,
      autoBackupIntervalHours:
          autoBackupIntervalHours ?? this.autoBackupIntervalHours,
      lastAutoBackupAt: lastAutoBackupAt ?? this.lastAutoBackupAt,
      autoBackupMaxMbPerRun:
          autoBackupMaxMbPerRun ?? this.autoBackupMaxMbPerRun,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kdfSalt.present) {
      map['kdf_salt'] = Variable<Uint8List>(kdfSalt.value);
    }
    if (wrappedMasterKeyNonce.present) {
      map['wrapped_master_key_nonce'] =
          Variable<Uint8List>(wrappedMasterKeyNonce.value);
    }
    if (wrappedMasterKey.present) {
      map['wrapped_master_key'] = Variable<Uint8List>(wrappedMasterKey.value);
    }
    if (autoBackupEnabled.present) {
      map['auto_backup_enabled'] = Variable<bool>(autoBackupEnabled.value);
    }
    if (autoBackupDestination.present) {
      map['auto_backup_destination'] =
          Variable<String>(autoBackupDestination.value);
    }
    if (autoBackupIntervalHours.present) {
      map['auto_backup_interval_hours'] =
          Variable<int>(autoBackupIntervalHours.value);
    }
    if (lastAutoBackupAt.present) {
      map['last_auto_backup_at'] = Variable<DateTime>(lastAutoBackupAt.value);
    }
    if (autoBackupMaxMbPerRun.present) {
      map['auto_backup_max_mb_per_run'] =
          Variable<int>(autoBackupMaxMbPerRun.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupSettingsCompanion(')
          ..write('id: $id, ')
          ..write('kdfSalt: $kdfSalt, ')
          ..write('wrappedMasterKeyNonce: $wrappedMasterKeyNonce, ')
          ..write('wrappedMasterKey: $wrappedMasterKey, ')
          ..write('autoBackupEnabled: $autoBackupEnabled, ')
          ..write('autoBackupDestination: $autoBackupDestination, ')
          ..write('autoBackupIntervalHours: $autoBackupIntervalHours, ')
          ..write('lastAutoBackupAt: $lastAutoBackupAt, ')
          ..write('autoBackupMaxMbPerRun: $autoBackupMaxMbPerRun')
          ..write(')'))
        .toString();
  }
}

class $SavedSearchesTable extends SavedSearches
    with TableInfo<$SavedSearchesTable, SavedSearchData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filtersJsonMeta =
      const VerificationMeta('filtersJson');
  @override
  late final GeneratedColumn<String> filtersJson = GeneratedColumn<String>(
      'filters_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, filtersJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_searches';
  @override
  VerificationContext validateIntegrity(Insertable<SavedSearchData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('filters_json')) {
      context.handle(
          _filtersJsonMeta,
          filtersJson.isAcceptableOrUnknown(
              data['filters_json']!, _filtersJsonMeta));
    } else if (isInserting) {
      context.missing(_filtersJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedSearchData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedSearchData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      filtersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filters_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SavedSearchesTable createAlias(String alias) {
    return $SavedSearchesTable(attachedDatabase, alias);
  }
}

class SavedSearchData extends DataClass implements Insertable<SavedSearchData> {
  final String id;
  final String name;
  final String filtersJson;
  final DateTime createdAt;
  const SavedSearchData(
      {required this.id,
      required this.name,
      required this.filtersJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['filters_json'] = Variable<String>(filtersJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedSearchesCompanion toCompanion(bool nullToAbsent) {
    return SavedSearchesCompanion(
      id: Value(id),
      name: Value(name),
      filtersJson: Value(filtersJson),
      createdAt: Value(createdAt),
    );
  }

  factory SavedSearchData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedSearchData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      filtersJson: serializer.fromJson<String>(json['filtersJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'filtersJson': serializer.toJson<String>(filtersJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedSearchData copyWith(
          {String? id,
          String? name,
          String? filtersJson,
          DateTime? createdAt}) =>
      SavedSearchData(
        id: id ?? this.id,
        name: name ?? this.name,
        filtersJson: filtersJson ?? this.filtersJson,
        createdAt: createdAt ?? this.createdAt,
      );
  SavedSearchData copyWithCompanion(SavedSearchesCompanion data) {
    return SavedSearchData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      filtersJson:
          data.filtersJson.present ? data.filtersJson.value : this.filtersJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedSearchData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filtersJson: $filtersJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, filtersJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedSearchData &&
          other.id == this.id &&
          other.name == this.name &&
          other.filtersJson == this.filtersJson &&
          other.createdAt == this.createdAt);
}

class SavedSearchesCompanion extends UpdateCompanion<SavedSearchData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> filtersJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavedSearchesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.filtersJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedSearchesCompanion.insert({
    required String id,
    required String name,
    required String filtersJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        filtersJson = Value(filtersJson),
        createdAt = Value(createdAt);
  static Insertable<SavedSearchData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? filtersJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (filtersJson != null) 'filters_json': filtersJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedSearchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? filtersJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SavedSearchesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      filtersJson: filtersJson ?? this.filtersJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filtersJson.present) {
      map['filters_json'] = Variable<String>(filtersJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedSearchesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filtersJson: $filtersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrashSettingsTable extends TrashSettings
    with TableInfo<$TrashSettingsTable, TrashSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrashSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _autoDeleteEnabledMeta =
      const VerificationMeta('autoDeleteEnabled');
  @override
  late final GeneratedColumn<bool> autoDeleteEnabled = GeneratedColumn<bool>(
      'auto_delete_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_delete_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autoDeleteAfterDaysMeta =
      const VerificationMeta('autoDeleteAfterDays');
  @override
  late final GeneratedColumn<int> autoDeleteAfterDays = GeneratedColumn<int>(
      'auto_delete_after_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _lastPurgeAtMeta =
      const VerificationMeta('lastPurgeAt');
  @override
  late final GeneratedColumn<DateTime> lastPurgeAt = GeneratedColumn<DateTime>(
      'last_purge_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, autoDeleteEnabled, autoDeleteAfterDays, lastPurgeAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trash_settings';
  @override
  VerificationContext validateIntegrity(Insertable<TrashSettingsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('auto_delete_enabled')) {
      context.handle(
          _autoDeleteEnabledMeta,
          autoDeleteEnabled.isAcceptableOrUnknown(
              data['auto_delete_enabled']!, _autoDeleteEnabledMeta));
    }
    if (data.containsKey('auto_delete_after_days')) {
      context.handle(
          _autoDeleteAfterDaysMeta,
          autoDeleteAfterDays.isAcceptableOrUnknown(
              data['auto_delete_after_days']!, _autoDeleteAfterDaysMeta));
    }
    if (data.containsKey('last_purge_at')) {
      context.handle(
          _lastPurgeAtMeta,
          lastPurgeAt.isAcceptableOrUnknown(
              data['last_purge_at']!, _lastPurgeAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrashSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrashSettingsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      autoDeleteEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_delete_enabled'])!,
      autoDeleteAfterDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}auto_delete_after_days'])!,
      lastPurgeAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_purge_at']),
    );
  }

  @override
  $TrashSettingsTable createAlias(String alias) {
    return $TrashSettingsTable(attachedDatabase, alias);
  }
}

class TrashSettingsData extends DataClass
    implements Insertable<TrashSettingsData> {
  final int id;
  final bool autoDeleteEnabled;
  final int autoDeleteAfterDays;
  final DateTime? lastPurgeAt;
  const TrashSettingsData(
      {required this.id,
      required this.autoDeleteEnabled,
      required this.autoDeleteAfterDays,
      this.lastPurgeAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['auto_delete_enabled'] = Variable<bool>(autoDeleteEnabled);
    map['auto_delete_after_days'] = Variable<int>(autoDeleteAfterDays);
    if (!nullToAbsent || lastPurgeAt != null) {
      map['last_purge_at'] = Variable<DateTime>(lastPurgeAt);
    }
    return map;
  }

  TrashSettingsCompanion toCompanion(bool nullToAbsent) {
    return TrashSettingsCompanion(
      id: Value(id),
      autoDeleteEnabled: Value(autoDeleteEnabled),
      autoDeleteAfterDays: Value(autoDeleteAfterDays),
      lastPurgeAt: lastPurgeAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPurgeAt),
    );
  }

  factory TrashSettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrashSettingsData(
      id: serializer.fromJson<int>(json['id']),
      autoDeleteEnabled: serializer.fromJson<bool>(json['autoDeleteEnabled']),
      autoDeleteAfterDays:
          serializer.fromJson<int>(json['autoDeleteAfterDays']),
      lastPurgeAt: serializer.fromJson<DateTime?>(json['lastPurgeAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'autoDeleteEnabled': serializer.toJson<bool>(autoDeleteEnabled),
      'autoDeleteAfterDays': serializer.toJson<int>(autoDeleteAfterDays),
      'lastPurgeAt': serializer.toJson<DateTime?>(lastPurgeAt),
    };
  }

  TrashSettingsData copyWith(
          {int? id,
          bool? autoDeleteEnabled,
          int? autoDeleteAfterDays,
          Value<DateTime?> lastPurgeAt = const Value.absent()}) =>
      TrashSettingsData(
        id: id ?? this.id,
        autoDeleteEnabled: autoDeleteEnabled ?? this.autoDeleteEnabled,
        autoDeleteAfterDays: autoDeleteAfterDays ?? this.autoDeleteAfterDays,
        lastPurgeAt: lastPurgeAt.present ? lastPurgeAt.value : this.lastPurgeAt,
      );
  TrashSettingsData copyWithCompanion(TrashSettingsCompanion data) {
    return TrashSettingsData(
      id: data.id.present ? data.id.value : this.id,
      autoDeleteEnabled: data.autoDeleteEnabled.present
          ? data.autoDeleteEnabled.value
          : this.autoDeleteEnabled,
      autoDeleteAfterDays: data.autoDeleteAfterDays.present
          ? data.autoDeleteAfterDays.value
          : this.autoDeleteAfterDays,
      lastPurgeAt:
          data.lastPurgeAt.present ? data.lastPurgeAt.value : this.lastPurgeAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrashSettingsData(')
          ..write('id: $id, ')
          ..write('autoDeleteEnabled: $autoDeleteEnabled, ')
          ..write('autoDeleteAfterDays: $autoDeleteAfterDays, ')
          ..write('lastPurgeAt: $lastPurgeAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, autoDeleteEnabled, autoDeleteAfterDays, lastPurgeAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrashSettingsData &&
          other.id == this.id &&
          other.autoDeleteEnabled == this.autoDeleteEnabled &&
          other.autoDeleteAfterDays == this.autoDeleteAfterDays &&
          other.lastPurgeAt == this.lastPurgeAt);
}

class TrashSettingsCompanion extends UpdateCompanion<TrashSettingsData> {
  final Value<int> id;
  final Value<bool> autoDeleteEnabled;
  final Value<int> autoDeleteAfterDays;
  final Value<DateTime?> lastPurgeAt;
  const TrashSettingsCompanion({
    this.id = const Value.absent(),
    this.autoDeleteEnabled = const Value.absent(),
    this.autoDeleteAfterDays = const Value.absent(),
    this.lastPurgeAt = const Value.absent(),
  });
  TrashSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.autoDeleteEnabled = const Value.absent(),
    this.autoDeleteAfterDays = const Value.absent(),
    this.lastPurgeAt = const Value.absent(),
  });
  static Insertable<TrashSettingsData> custom({
    Expression<int>? id,
    Expression<bool>? autoDeleteEnabled,
    Expression<int>? autoDeleteAfterDays,
    Expression<DateTime>? lastPurgeAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (autoDeleteEnabled != null) 'auto_delete_enabled': autoDeleteEnabled,
      if (autoDeleteAfterDays != null)
        'auto_delete_after_days': autoDeleteAfterDays,
      if (lastPurgeAt != null) 'last_purge_at': lastPurgeAt,
    });
  }

  TrashSettingsCompanion copyWith(
      {Value<int>? id,
      Value<bool>? autoDeleteEnabled,
      Value<int>? autoDeleteAfterDays,
      Value<DateTime?>? lastPurgeAt}) {
    return TrashSettingsCompanion(
      id: id ?? this.id,
      autoDeleteEnabled: autoDeleteEnabled ?? this.autoDeleteEnabled,
      autoDeleteAfterDays: autoDeleteAfterDays ?? this.autoDeleteAfterDays,
      lastPurgeAt: lastPurgeAt ?? this.lastPurgeAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (autoDeleteEnabled.present) {
      map['auto_delete_enabled'] = Variable<bool>(autoDeleteEnabled.value);
    }
    if (autoDeleteAfterDays.present) {
      map['auto_delete_after_days'] = Variable<int>(autoDeleteAfterDays.value);
    }
    if (lastPurgeAt.present) {
      map['last_purge_at'] = Variable<DateTime>(lastPurgeAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrashSettingsCompanion(')
          ..write('id: $id, ')
          ..write('autoDeleteEnabled: $autoDeleteEnabled, ')
          ..write('autoDeleteAfterDays: $autoDeleteAfterDays, ')
          ..write('lastPurgeAt: $lastPurgeAt')
          ..write(')'))
        .toString();
  }
}

class $DuplikatAusnahmenTable extends DuplikatAusnahmen
    with TableInfo<$DuplikatAusnahmenTable, DuplikatAusnahmeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DuplikatAusnahmenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetAMeta = const VerificationMeta('assetA');
  @override
  late final GeneratedColumn<String> assetA = GeneratedColumn<String>(
      'asset_a', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetBMeta = const VerificationMeta('assetB');
  @override
  late final GeneratedColumn<String> assetB = GeneratedColumn<String>(
      'asset_b', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _angelegtAmMeta =
      const VerificationMeta('angelegtAm');
  @override
  late final GeneratedColumn<DateTime> angelegtAm = GeneratedColumn<DateTime>(
      'angelegt_am', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [assetA, assetB, angelegtAm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'duplikat_ausnahmen';
  @override
  VerificationContext validateIntegrity(
      Insertable<DuplikatAusnahmeData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_a')) {
      context.handle(_assetAMeta,
          assetA.isAcceptableOrUnknown(data['asset_a']!, _assetAMeta));
    } else if (isInserting) {
      context.missing(_assetAMeta);
    }
    if (data.containsKey('asset_b')) {
      context.handle(_assetBMeta,
          assetB.isAcceptableOrUnknown(data['asset_b']!, _assetBMeta));
    } else if (isInserting) {
      context.missing(_assetBMeta);
    }
    if (data.containsKey('angelegt_am')) {
      context.handle(
          _angelegtAmMeta,
          angelegtAm.isAcceptableOrUnknown(
              data['angelegt_am']!, _angelegtAmMeta));
    } else if (isInserting) {
      context.missing(_angelegtAmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetA, assetB};
  @override
  DuplikatAusnahmeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DuplikatAusnahmeData(
      assetA: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_a'])!,
      assetB: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_b'])!,
      angelegtAm: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}angelegt_am'])!,
    );
  }

  @override
  $DuplikatAusnahmenTable createAlias(String alias) {
    return $DuplikatAusnahmenTable(attachedDatabase, alias);
  }
}

class DuplikatAusnahmeData extends DataClass
    implements Insertable<DuplikatAusnahmeData> {
  final String assetA;
  final String assetB;
  final DateTime angelegtAm;
  const DuplikatAusnahmeData(
      {required this.assetA, required this.assetB, required this.angelegtAm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_a'] = Variable<String>(assetA);
    map['asset_b'] = Variable<String>(assetB);
    map['angelegt_am'] = Variable<DateTime>(angelegtAm);
    return map;
  }

  DuplikatAusnahmenCompanion toCompanion(bool nullToAbsent) {
    return DuplikatAusnahmenCompanion(
      assetA: Value(assetA),
      assetB: Value(assetB),
      angelegtAm: Value(angelegtAm),
    );
  }

  factory DuplikatAusnahmeData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DuplikatAusnahmeData(
      assetA: serializer.fromJson<String>(json['assetA']),
      assetB: serializer.fromJson<String>(json['assetB']),
      angelegtAm: serializer.fromJson<DateTime>(json['angelegtAm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetA': serializer.toJson<String>(assetA),
      'assetB': serializer.toJson<String>(assetB),
      'angelegtAm': serializer.toJson<DateTime>(angelegtAm),
    };
  }

  DuplikatAusnahmeData copyWith(
          {String? assetA, String? assetB, DateTime? angelegtAm}) =>
      DuplikatAusnahmeData(
        assetA: assetA ?? this.assetA,
        assetB: assetB ?? this.assetB,
        angelegtAm: angelegtAm ?? this.angelegtAm,
      );
  DuplikatAusnahmeData copyWithCompanion(DuplikatAusnahmenCompanion data) {
    return DuplikatAusnahmeData(
      assetA: data.assetA.present ? data.assetA.value : this.assetA,
      assetB: data.assetB.present ? data.assetB.value : this.assetB,
      angelegtAm:
          data.angelegtAm.present ? data.angelegtAm.value : this.angelegtAm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DuplikatAusnahmeData(')
          ..write('assetA: $assetA, ')
          ..write('assetB: $assetB, ')
          ..write('angelegtAm: $angelegtAm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetA, assetB, angelegtAm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DuplikatAusnahmeData &&
          other.assetA == this.assetA &&
          other.assetB == this.assetB &&
          other.angelegtAm == this.angelegtAm);
}

class DuplikatAusnahmenCompanion extends UpdateCompanion<DuplikatAusnahmeData> {
  final Value<String> assetA;
  final Value<String> assetB;
  final Value<DateTime> angelegtAm;
  final Value<int> rowid;
  const DuplikatAusnahmenCompanion({
    this.assetA = const Value.absent(),
    this.assetB = const Value.absent(),
    this.angelegtAm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DuplikatAusnahmenCompanion.insert({
    required String assetA,
    required String assetB,
    required DateTime angelegtAm,
    this.rowid = const Value.absent(),
  })  : assetA = Value(assetA),
        assetB = Value(assetB),
        angelegtAm = Value(angelegtAm);
  static Insertable<DuplikatAusnahmeData> custom({
    Expression<String>? assetA,
    Expression<String>? assetB,
    Expression<DateTime>? angelegtAm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetA != null) 'asset_a': assetA,
      if (assetB != null) 'asset_b': assetB,
      if (angelegtAm != null) 'angelegt_am': angelegtAm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DuplikatAusnahmenCompanion copyWith(
      {Value<String>? assetA,
      Value<String>? assetB,
      Value<DateTime>? angelegtAm,
      Value<int>? rowid}) {
    return DuplikatAusnahmenCompanion(
      assetA: assetA ?? this.assetA,
      assetB: assetB ?? this.assetB,
      angelegtAm: angelegtAm ?? this.angelegtAm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetA.present) {
      map['asset_a'] = Variable<String>(assetA.value);
    }
    if (assetB.present) {
      map['asset_b'] = Variable<String>(assetB.value);
    }
    if (angelegtAm.present) {
      map['angelegt_am'] = Variable<DateTime>(angelegtAm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DuplikatAusnahmenCompanion(')
          ..write('assetA: $assetA, ')
          ..write('assetB: $assetB, ')
          ..write('angelegtAm: $angelegtAm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CameraPresetsTable extends CameraPresets
    with TableInfo<$CameraPresetsTable, CameraPresetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CameraPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cameraMakeMeta =
      const VerificationMeta('cameraMake');
  @override
  late final GeneratedColumn<String> cameraMake = GeneratedColumn<String>(
      'camera_make', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cameraModelMeta =
      const VerificationMeta('cameraModel');
  @override
  late final GeneratedColumn<String> cameraModel = GeneratedColumn<String>(
      'camera_model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAlbumIdMeta =
      const VerificationMeta('targetAlbumId');
  @override
  late final GeneratedColumn<String> targetAlbumId = GeneratedColumn<String>(
      'target_album_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _autoFavoriteMeta =
      const VerificationMeta('autoFavorite');
  @override
  late final GeneratedColumn<bool> autoFavorite = GeneratedColumn<bool>(
      'auto_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, cameraMake, cameraModel, targetAlbumId, autoFavorite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camera_presets';
  @override
  VerificationContext validateIntegrity(Insertable<CameraPresetData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('camera_make')) {
      context.handle(
          _cameraMakeMeta,
          cameraMake.isAcceptableOrUnknown(
              data['camera_make']!, _cameraMakeMeta));
    } else if (isInserting) {
      context.missing(_cameraMakeMeta);
    }
    if (data.containsKey('camera_model')) {
      context.handle(
          _cameraModelMeta,
          cameraModel.isAcceptableOrUnknown(
              data['camera_model']!, _cameraModelMeta));
    } else if (isInserting) {
      context.missing(_cameraModelMeta);
    }
    if (data.containsKey('target_album_id')) {
      context.handle(
          _targetAlbumIdMeta,
          targetAlbumId.isAcceptableOrUnknown(
              data['target_album_id']!, _targetAlbumIdMeta));
    }
    if (data.containsKey('auto_favorite')) {
      context.handle(
          _autoFavoriteMeta,
          autoFavorite.isAcceptableOrUnknown(
              data['auto_favorite']!, _autoFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CameraPresetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CameraPresetData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cameraMake: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}camera_make'])!,
      cameraModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}camera_model'])!,
      targetAlbumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_album_id']),
      autoFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_favorite'])!,
    );
  }

  @override
  $CameraPresetsTable createAlias(String alias) {
    return $CameraPresetsTable(attachedDatabase, alias);
  }
}

class CameraPresetData extends DataClass
    implements Insertable<CameraPresetData> {
  final String id;
  final String cameraMake;
  final String cameraModel;
  final String? targetAlbumId;
  final bool autoFavorite;
  const CameraPresetData(
      {required this.id,
      required this.cameraMake,
      required this.cameraModel,
      this.targetAlbumId,
      required this.autoFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['camera_make'] = Variable<String>(cameraMake);
    map['camera_model'] = Variable<String>(cameraModel);
    if (!nullToAbsent || targetAlbumId != null) {
      map['target_album_id'] = Variable<String>(targetAlbumId);
    }
    map['auto_favorite'] = Variable<bool>(autoFavorite);
    return map;
  }

  CameraPresetsCompanion toCompanion(bool nullToAbsent) {
    return CameraPresetsCompanion(
      id: Value(id),
      cameraMake: Value(cameraMake),
      cameraModel: Value(cameraModel),
      targetAlbumId: targetAlbumId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAlbumId),
      autoFavorite: Value(autoFavorite),
    );
  }

  factory CameraPresetData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CameraPresetData(
      id: serializer.fromJson<String>(json['id']),
      cameraMake: serializer.fromJson<String>(json['cameraMake']),
      cameraModel: serializer.fromJson<String>(json['cameraModel']),
      targetAlbumId: serializer.fromJson<String?>(json['targetAlbumId']),
      autoFavorite: serializer.fromJson<bool>(json['autoFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cameraMake': serializer.toJson<String>(cameraMake),
      'cameraModel': serializer.toJson<String>(cameraModel),
      'targetAlbumId': serializer.toJson<String?>(targetAlbumId),
      'autoFavorite': serializer.toJson<bool>(autoFavorite),
    };
  }

  CameraPresetData copyWith(
          {String? id,
          String? cameraMake,
          String? cameraModel,
          Value<String?> targetAlbumId = const Value.absent(),
          bool? autoFavorite}) =>
      CameraPresetData(
        id: id ?? this.id,
        cameraMake: cameraMake ?? this.cameraMake,
        cameraModel: cameraModel ?? this.cameraModel,
        targetAlbumId:
            targetAlbumId.present ? targetAlbumId.value : this.targetAlbumId,
        autoFavorite: autoFavorite ?? this.autoFavorite,
      );
  CameraPresetData copyWithCompanion(CameraPresetsCompanion data) {
    return CameraPresetData(
      id: data.id.present ? data.id.value : this.id,
      cameraMake:
          data.cameraMake.present ? data.cameraMake.value : this.cameraMake,
      cameraModel:
          data.cameraModel.present ? data.cameraModel.value : this.cameraModel,
      targetAlbumId: data.targetAlbumId.present
          ? data.targetAlbumId.value
          : this.targetAlbumId,
      autoFavorite: data.autoFavorite.present
          ? data.autoFavorite.value
          : this.autoFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CameraPresetData(')
          ..write('id: $id, ')
          ..write('cameraMake: $cameraMake, ')
          ..write('cameraModel: $cameraModel, ')
          ..write('targetAlbumId: $targetAlbumId, ')
          ..write('autoFavorite: $autoFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cameraMake, cameraModel, targetAlbumId, autoFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CameraPresetData &&
          other.id == this.id &&
          other.cameraMake == this.cameraMake &&
          other.cameraModel == this.cameraModel &&
          other.targetAlbumId == this.targetAlbumId &&
          other.autoFavorite == this.autoFavorite);
}

class CameraPresetsCompanion extends UpdateCompanion<CameraPresetData> {
  final Value<String> id;
  final Value<String> cameraMake;
  final Value<String> cameraModel;
  final Value<String?> targetAlbumId;
  final Value<bool> autoFavorite;
  final Value<int> rowid;
  const CameraPresetsCompanion({
    this.id = const Value.absent(),
    this.cameraMake = const Value.absent(),
    this.cameraModel = const Value.absent(),
    this.targetAlbumId = const Value.absent(),
    this.autoFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CameraPresetsCompanion.insert({
    required String id,
    required String cameraMake,
    required String cameraModel,
    this.targetAlbumId = const Value.absent(),
    this.autoFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cameraMake = Value(cameraMake),
        cameraModel = Value(cameraModel);
  static Insertable<CameraPresetData> custom({
    Expression<String>? id,
    Expression<String>? cameraMake,
    Expression<String>? cameraModel,
    Expression<String>? targetAlbumId,
    Expression<bool>? autoFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cameraMake != null) 'camera_make': cameraMake,
      if (cameraModel != null) 'camera_model': cameraModel,
      if (targetAlbumId != null) 'target_album_id': targetAlbumId,
      if (autoFavorite != null) 'auto_favorite': autoFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CameraPresetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? cameraMake,
      Value<String>? cameraModel,
      Value<String?>? targetAlbumId,
      Value<bool>? autoFavorite,
      Value<int>? rowid}) {
    return CameraPresetsCompanion(
      id: id ?? this.id,
      cameraMake: cameraMake ?? this.cameraMake,
      cameraModel: cameraModel ?? this.cameraModel,
      targetAlbumId: targetAlbumId ?? this.targetAlbumId,
      autoFavorite: autoFavorite ?? this.autoFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cameraMake.present) {
      map['camera_make'] = Variable<String>(cameraMake.value);
    }
    if (cameraModel.present) {
      map['camera_model'] = Variable<String>(cameraModel.value);
    }
    if (targetAlbumId.present) {
      map['target_album_id'] = Variable<String>(targetAlbumId.value);
    }
    if (autoFavorite.present) {
      map['auto_favorite'] = Variable<bool>(autoFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CameraPresetsCompanion(')
          ..write('id: $id, ')
          ..write('cameraMake: $cameraMake, ')
          ..write('cameraModel: $cameraModel, ')
          ..write('targetAlbumId: $targetAlbumId, ')
          ..write('autoFavorite: $autoFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CameraPresetTagsTable extends CameraPresetTags
    with TableInfo<$CameraPresetTagsTable, CameraPresetTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CameraPresetTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _presetIdMeta =
      const VerificationMeta('presetId');
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
      'preset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [presetId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camera_preset_tags';
  @override
  VerificationContext validateIntegrity(Insertable<CameraPresetTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('preset_id')) {
      context.handle(_presetIdMeta,
          presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta));
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {presetId, tagId};
  @override
  CameraPresetTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CameraPresetTag(
      presetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preset_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $CameraPresetTagsTable createAlias(String alias) {
    return $CameraPresetTagsTable(attachedDatabase, alias);
  }
}

class CameraPresetTag extends DataClass implements Insertable<CameraPresetTag> {
  final String presetId;
  final String tagId;
  const CameraPresetTag({required this.presetId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['preset_id'] = Variable<String>(presetId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  CameraPresetTagsCompanion toCompanion(bool nullToAbsent) {
    return CameraPresetTagsCompanion(
      presetId: Value(presetId),
      tagId: Value(tagId),
    );
  }

  factory CameraPresetTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CameraPresetTag(
      presetId: serializer.fromJson<String>(json['presetId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'presetId': serializer.toJson<String>(presetId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  CameraPresetTag copyWith({String? presetId, String? tagId}) =>
      CameraPresetTag(
        presetId: presetId ?? this.presetId,
        tagId: tagId ?? this.tagId,
      );
  CameraPresetTag copyWithCompanion(CameraPresetTagsCompanion data) {
    return CameraPresetTag(
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CameraPresetTag(')
          ..write('presetId: $presetId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(presetId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CameraPresetTag &&
          other.presetId == this.presetId &&
          other.tagId == this.tagId);
}

class CameraPresetTagsCompanion extends UpdateCompanion<CameraPresetTag> {
  final Value<String> presetId;
  final Value<String> tagId;
  final Value<int> rowid;
  const CameraPresetTagsCompanion({
    this.presetId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CameraPresetTagsCompanion.insert({
    required String presetId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : presetId = Value(presetId),
        tagId = Value(tagId);
  static Insertable<CameraPresetTag> custom({
    Expression<String>? presetId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (presetId != null) 'preset_id': presetId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CameraPresetTagsCompanion copyWith(
      {Value<String>? presetId, Value<String>? tagId, Value<int>? rowid}) {
    return CameraPresetTagsCompanion(
      presetId: presetId ?? this.presetId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CameraPresetTagsCompanion(')
          ..write('presetId: $presetId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevelopSettingsTable extends DevelopSettings
    with TableInfo<$DevelopSettingsTable, DevelopSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevelopSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exposureMeta =
      const VerificationMeta('exposure');
  @override
  late final GeneratedColumn<double> exposure = GeneratedColumn<double>(
      'exposure', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _tintMeta = const VerificationMeta('tint');
  @override
  late final GeneratedColumn<double> tint = GeneratedColumn<double>(
      'tint', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _contrastMeta =
      const VerificationMeta('contrast');
  @override
  late final GeneratedColumn<double> contrast = GeneratedColumn<double>(
      'contrast', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shadowsMeta =
      const VerificationMeta('shadows');
  @override
  late final GeneratedColumn<double> shadows = GeneratedColumn<double>(
      'shadows', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sharpnessMeta =
      const VerificationMeta('sharpness');
  @override
  late final GeneratedColumn<double> sharpness = GeneratedColumn<double>(
      'sharpness', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noiseReductionMeta =
      const VerificationMeta('noiseReduction');
  @override
  late final GeneratedColumn<double> noiseReduction = GeneratedColumn<double>(
      'noise_reduction', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lensCorrectionEnabledMeta =
      const VerificationMeta('lensCorrectionEnabled');
  @override
  late final GeneratedColumn<bool> lensCorrectionEnabled =
      GeneratedColumn<bool>('lens_correction_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("lens_correction_enabled" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _clarityMeta =
      const VerificationMeta('clarity');
  @override
  late final GeneratedColumn<double> clarity = GeneratedColumn<double>(
      'clarity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _vignetteMeta =
      const VerificationMeta('vignette');
  @override
  late final GeneratedColumn<double> vignette = GeneratedColumn<double>(
      'vignette', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lutPathMeta =
      const VerificationMeta('lutPath');
  @override
  late final GeneratedColumn<String> lutPath = GeneratedColumn<String>(
      'lut_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lutStrengthMeta =
      const VerificationMeta('lutStrength');
  @override
  late final GeneratedColumn<double> lutStrength = GeneratedColumn<double>(
      'lut_strength', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _toneCurveJsonMeta =
      const VerificationMeta('toneCurveJson');
  @override
  late final GeneratedColumn<String> toneCurveJson = GeneratedColumn<String>(
      'tone_curve_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMixerJsonMeta =
      const VerificationMeta('colorMixerJson');
  @override
  late final GeneratedColumn<String> colorMixerJson = GeneratedColumn<String>(
      'color_mixer_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        assetId,
        exposure,
        temperature,
        tint,
        contrast,
        shadows,
        sharpness,
        noiseReduction,
        lensCorrectionEnabled,
        clarity,
        vignette,
        lutPath,
        lutStrength,
        toneCurveJson,
        colorMixerJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'develop_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<DevelopSettingsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('exposure')) {
      context.handle(_exposureMeta,
          exposure.isAcceptableOrUnknown(data['exposure']!, _exposureMeta));
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('tint')) {
      context.handle(
          _tintMeta, tint.isAcceptableOrUnknown(data['tint']!, _tintMeta));
    }
    if (data.containsKey('contrast')) {
      context.handle(_contrastMeta,
          contrast.isAcceptableOrUnknown(data['contrast']!, _contrastMeta));
    }
    if (data.containsKey('shadows')) {
      context.handle(_shadowsMeta,
          shadows.isAcceptableOrUnknown(data['shadows']!, _shadowsMeta));
    }
    if (data.containsKey('sharpness')) {
      context.handle(_sharpnessMeta,
          sharpness.isAcceptableOrUnknown(data['sharpness']!, _sharpnessMeta));
    }
    if (data.containsKey('noise_reduction')) {
      context.handle(
          _noiseReductionMeta,
          noiseReduction.isAcceptableOrUnknown(
              data['noise_reduction']!, _noiseReductionMeta));
    }
    if (data.containsKey('lens_correction_enabled')) {
      context.handle(
          _lensCorrectionEnabledMeta,
          lensCorrectionEnabled.isAcceptableOrUnknown(
              data['lens_correction_enabled']!, _lensCorrectionEnabledMeta));
    }
    if (data.containsKey('clarity')) {
      context.handle(_clarityMeta,
          clarity.isAcceptableOrUnknown(data['clarity']!, _clarityMeta));
    }
    if (data.containsKey('vignette')) {
      context.handle(_vignetteMeta,
          vignette.isAcceptableOrUnknown(data['vignette']!, _vignetteMeta));
    }
    if (data.containsKey('lut_path')) {
      context.handle(_lutPathMeta,
          lutPath.isAcceptableOrUnknown(data['lut_path']!, _lutPathMeta));
    }
    if (data.containsKey('lut_strength')) {
      context.handle(
          _lutStrengthMeta,
          lutStrength.isAcceptableOrUnknown(
              data['lut_strength']!, _lutStrengthMeta));
    }
    if (data.containsKey('tone_curve_json')) {
      context.handle(
          _toneCurveJsonMeta,
          toneCurveJson.isAcceptableOrUnknown(
              data['tone_curve_json']!, _toneCurveJsonMeta));
    }
    if (data.containsKey('color_mixer_json')) {
      context.handle(
          _colorMixerJsonMeta,
          colorMixerJson.isAcceptableOrUnknown(
              data['color_mixer_json']!, _colorMixerJsonMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  DevelopSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevelopSettingsData(
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      exposure: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exposure'])!,
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature']),
      tint: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tint']),
      contrast: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}contrast'])!,
      shadows: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shadows'])!,
      sharpness: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sharpness'])!,
      noiseReduction: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}noise_reduction'])!,
      lensCorrectionEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}lens_correction_enabled'])!,
      clarity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}clarity'])!,
      vignette: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vignette'])!,
      lutPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lut_path']),
      lutStrength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lut_strength'])!,
      toneCurveJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tone_curve_json']),
      colorMixerJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}color_mixer_json']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DevelopSettingsTable createAlias(String alias) {
    return $DevelopSettingsTable(attachedDatabase, alias);
  }
}

class DevelopSettingsData extends DataClass
    implements Insertable<DevelopSettingsData> {
  final String assetId;
  final double exposure;
  final double? temperature;
  final double? tint;
  final double contrast;
  final double shadows;
  final double sharpness;
  final double noiseReduction;
  final bool lensCorrectionEnabled;

  /// Klarheit (lokaler Mikrokontrast) und Vignettierung, je -1..1.
  ///
  /// Beide sind reine Core-Image-Filter und wirken deshalb – wie Schärfe
  /// und Rauschunterdrückung – erst im gerenderten Bild, nicht in der
  /// Shader-Vorschau während des Ziehens.
  final double clarity;
  final double vignette;

  /// Eine importierte Farbtabelle (`.cube`), relativ zur Bibliothek, und
  /// wie stark sie wirkt.
  ///
  /// Der Pfad statt des Inhalts: Ein 33er-Würfel sind 36.000 Zahlen, die
  /// sonst in jeder Zeile und noch einmal in jedem Verlaufseintrag lägen.
  final String? lutPath;
  final double lutStrength;

  /// JSON-kodierte [ToneCurve] bzw. [ColorMixer] (siehe develop_color.dart).
  ///
  /// Anders als die Regler darüber sind das keine einzelnen Zahlen, sondern
  /// eine Punktfolge je Kanal bzw. acht Bänder mit je drei Werten – als
  /// Spalten flachgeklopft wären das über dreissig zusätzliche Felder, die
  /// in [DevelopHistory] noch einmal aufträten. `null` bedeutet neutral;
  /// damit brauchen vorhandene Zeilen keine Migration und der Normalfall
  /// kostet zur Laufzeit nichts (siehe `ToneCurve.istNeutral`).
  final String? toneCurveJson;
  final String? colorMixerJson;
  final DateTime updatedAt;
  const DevelopSettingsData(
      {required this.assetId,
      required this.exposure,
      this.temperature,
      this.tint,
      required this.contrast,
      required this.shadows,
      required this.sharpness,
      required this.noiseReduction,
      required this.lensCorrectionEnabled,
      required this.clarity,
      required this.vignette,
      this.lutPath,
      required this.lutStrength,
      this.toneCurveJson,
      this.colorMixerJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['exposure'] = Variable<double>(exposure);
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || tint != null) {
      map['tint'] = Variable<double>(tint);
    }
    map['contrast'] = Variable<double>(contrast);
    map['shadows'] = Variable<double>(shadows);
    map['sharpness'] = Variable<double>(sharpness);
    map['noise_reduction'] = Variable<double>(noiseReduction);
    map['lens_correction_enabled'] = Variable<bool>(lensCorrectionEnabled);
    map['clarity'] = Variable<double>(clarity);
    map['vignette'] = Variable<double>(vignette);
    if (!nullToAbsent || lutPath != null) {
      map['lut_path'] = Variable<String>(lutPath);
    }
    map['lut_strength'] = Variable<double>(lutStrength);
    if (!nullToAbsent || toneCurveJson != null) {
      map['tone_curve_json'] = Variable<String>(toneCurveJson);
    }
    if (!nullToAbsent || colorMixerJson != null) {
      map['color_mixer_json'] = Variable<String>(colorMixerJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DevelopSettingsCompanion toCompanion(bool nullToAbsent) {
    return DevelopSettingsCompanion(
      assetId: Value(assetId),
      exposure: Value(exposure),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      tint: tint == null && nullToAbsent ? const Value.absent() : Value(tint),
      contrast: Value(contrast),
      shadows: Value(shadows),
      sharpness: Value(sharpness),
      noiseReduction: Value(noiseReduction),
      lensCorrectionEnabled: Value(lensCorrectionEnabled),
      clarity: Value(clarity),
      vignette: Value(vignette),
      lutPath: lutPath == null && nullToAbsent
          ? const Value.absent()
          : Value(lutPath),
      lutStrength: Value(lutStrength),
      toneCurveJson: toneCurveJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toneCurveJson),
      colorMixerJson: colorMixerJson == null && nullToAbsent
          ? const Value.absent()
          : Value(colorMixerJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DevelopSettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevelopSettingsData(
      assetId: serializer.fromJson<String>(json['assetId']),
      exposure: serializer.fromJson<double>(json['exposure']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      tint: serializer.fromJson<double?>(json['tint']),
      contrast: serializer.fromJson<double>(json['contrast']),
      shadows: serializer.fromJson<double>(json['shadows']),
      sharpness: serializer.fromJson<double>(json['sharpness']),
      noiseReduction: serializer.fromJson<double>(json['noiseReduction']),
      lensCorrectionEnabled:
          serializer.fromJson<bool>(json['lensCorrectionEnabled']),
      clarity: serializer.fromJson<double>(json['clarity']),
      vignette: serializer.fromJson<double>(json['vignette']),
      lutPath: serializer.fromJson<String?>(json['lutPath']),
      lutStrength: serializer.fromJson<double>(json['lutStrength']),
      toneCurveJson: serializer.fromJson<String?>(json['toneCurveJson']),
      colorMixerJson: serializer.fromJson<String?>(json['colorMixerJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'exposure': serializer.toJson<double>(exposure),
      'temperature': serializer.toJson<double?>(temperature),
      'tint': serializer.toJson<double?>(tint),
      'contrast': serializer.toJson<double>(contrast),
      'shadows': serializer.toJson<double>(shadows),
      'sharpness': serializer.toJson<double>(sharpness),
      'noiseReduction': serializer.toJson<double>(noiseReduction),
      'lensCorrectionEnabled': serializer.toJson<bool>(lensCorrectionEnabled),
      'clarity': serializer.toJson<double>(clarity),
      'vignette': serializer.toJson<double>(vignette),
      'lutPath': serializer.toJson<String?>(lutPath),
      'lutStrength': serializer.toJson<double>(lutStrength),
      'toneCurveJson': serializer.toJson<String?>(toneCurveJson),
      'colorMixerJson': serializer.toJson<String?>(colorMixerJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DevelopSettingsData copyWith(
          {String? assetId,
          double? exposure,
          Value<double?> temperature = const Value.absent(),
          Value<double?> tint = const Value.absent(),
          double? contrast,
          double? shadows,
          double? sharpness,
          double? noiseReduction,
          bool? lensCorrectionEnabled,
          double? clarity,
          double? vignette,
          Value<String?> lutPath = const Value.absent(),
          double? lutStrength,
          Value<String?> toneCurveJson = const Value.absent(),
          Value<String?> colorMixerJson = const Value.absent(),
          DateTime? updatedAt}) =>
      DevelopSettingsData(
        assetId: assetId ?? this.assetId,
        exposure: exposure ?? this.exposure,
        temperature: temperature.present ? temperature.value : this.temperature,
        tint: tint.present ? tint.value : this.tint,
        contrast: contrast ?? this.contrast,
        shadows: shadows ?? this.shadows,
        sharpness: sharpness ?? this.sharpness,
        noiseReduction: noiseReduction ?? this.noiseReduction,
        lensCorrectionEnabled:
            lensCorrectionEnabled ?? this.lensCorrectionEnabled,
        clarity: clarity ?? this.clarity,
        vignette: vignette ?? this.vignette,
        lutPath: lutPath.present ? lutPath.value : this.lutPath,
        lutStrength: lutStrength ?? this.lutStrength,
        toneCurveJson:
            toneCurveJson.present ? toneCurveJson.value : this.toneCurveJson,
        colorMixerJson:
            colorMixerJson.present ? colorMixerJson.value : this.colorMixerJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DevelopSettingsData copyWithCompanion(DevelopSettingsCompanion data) {
    return DevelopSettingsData(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      exposure: data.exposure.present ? data.exposure.value : this.exposure,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      tint: data.tint.present ? data.tint.value : this.tint,
      contrast: data.contrast.present ? data.contrast.value : this.contrast,
      shadows: data.shadows.present ? data.shadows.value : this.shadows,
      sharpness: data.sharpness.present ? data.sharpness.value : this.sharpness,
      noiseReduction: data.noiseReduction.present
          ? data.noiseReduction.value
          : this.noiseReduction,
      lensCorrectionEnabled: data.lensCorrectionEnabled.present
          ? data.lensCorrectionEnabled.value
          : this.lensCorrectionEnabled,
      clarity: data.clarity.present ? data.clarity.value : this.clarity,
      vignette: data.vignette.present ? data.vignette.value : this.vignette,
      lutPath: data.lutPath.present ? data.lutPath.value : this.lutPath,
      lutStrength:
          data.lutStrength.present ? data.lutStrength.value : this.lutStrength,
      toneCurveJson: data.toneCurveJson.present
          ? data.toneCurveJson.value
          : this.toneCurveJson,
      colorMixerJson: data.colorMixerJson.present
          ? data.colorMixerJson.value
          : this.colorMixerJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevelopSettingsData(')
          ..write('assetId: $assetId, ')
          ..write('exposure: $exposure, ')
          ..write('temperature: $temperature, ')
          ..write('tint: $tint, ')
          ..write('contrast: $contrast, ')
          ..write('shadows: $shadows, ')
          ..write('sharpness: $sharpness, ')
          ..write('noiseReduction: $noiseReduction, ')
          ..write('lensCorrectionEnabled: $lensCorrectionEnabled, ')
          ..write('clarity: $clarity, ')
          ..write('vignette: $vignette, ')
          ..write('lutPath: $lutPath, ')
          ..write('lutStrength: $lutStrength, ')
          ..write('toneCurveJson: $toneCurveJson, ')
          ..write('colorMixerJson: $colorMixerJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      assetId,
      exposure,
      temperature,
      tint,
      contrast,
      shadows,
      sharpness,
      noiseReduction,
      lensCorrectionEnabled,
      clarity,
      vignette,
      lutPath,
      lutStrength,
      toneCurveJson,
      colorMixerJson,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevelopSettingsData &&
          other.assetId == this.assetId &&
          other.exposure == this.exposure &&
          other.temperature == this.temperature &&
          other.tint == this.tint &&
          other.contrast == this.contrast &&
          other.shadows == this.shadows &&
          other.sharpness == this.sharpness &&
          other.noiseReduction == this.noiseReduction &&
          other.lensCorrectionEnabled == this.lensCorrectionEnabled &&
          other.clarity == this.clarity &&
          other.vignette == this.vignette &&
          other.lutPath == this.lutPath &&
          other.lutStrength == this.lutStrength &&
          other.toneCurveJson == this.toneCurveJson &&
          other.colorMixerJson == this.colorMixerJson &&
          other.updatedAt == this.updatedAt);
}

class DevelopSettingsCompanion extends UpdateCompanion<DevelopSettingsData> {
  final Value<String> assetId;
  final Value<double> exposure;
  final Value<double?> temperature;
  final Value<double?> tint;
  final Value<double> contrast;
  final Value<double> shadows;
  final Value<double> sharpness;
  final Value<double> noiseReduction;
  final Value<bool> lensCorrectionEnabled;
  final Value<double> clarity;
  final Value<double> vignette;
  final Value<String?> lutPath;
  final Value<double> lutStrength;
  final Value<String?> toneCurveJson;
  final Value<String?> colorMixerJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DevelopSettingsCompanion({
    this.assetId = const Value.absent(),
    this.exposure = const Value.absent(),
    this.temperature = const Value.absent(),
    this.tint = const Value.absent(),
    this.contrast = const Value.absent(),
    this.shadows = const Value.absent(),
    this.sharpness = const Value.absent(),
    this.noiseReduction = const Value.absent(),
    this.lensCorrectionEnabled = const Value.absent(),
    this.clarity = const Value.absent(),
    this.vignette = const Value.absent(),
    this.lutPath = const Value.absent(),
    this.lutStrength = const Value.absent(),
    this.toneCurveJson = const Value.absent(),
    this.colorMixerJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevelopSettingsCompanion.insert({
    required String assetId,
    this.exposure = const Value.absent(),
    this.temperature = const Value.absent(),
    this.tint = const Value.absent(),
    this.contrast = const Value.absent(),
    this.shadows = const Value.absent(),
    this.sharpness = const Value.absent(),
    this.noiseReduction = const Value.absent(),
    this.lensCorrectionEnabled = const Value.absent(),
    this.clarity = const Value.absent(),
    this.vignette = const Value.absent(),
    this.lutPath = const Value.absent(),
    this.lutStrength = const Value.absent(),
    this.toneCurveJson = const Value.absent(),
    this.colorMixerJson = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : assetId = Value(assetId),
        updatedAt = Value(updatedAt);
  static Insertable<DevelopSettingsData> custom({
    Expression<String>? assetId,
    Expression<double>? exposure,
    Expression<double>? temperature,
    Expression<double>? tint,
    Expression<double>? contrast,
    Expression<double>? shadows,
    Expression<double>? sharpness,
    Expression<double>? noiseReduction,
    Expression<bool>? lensCorrectionEnabled,
    Expression<double>? clarity,
    Expression<double>? vignette,
    Expression<String>? lutPath,
    Expression<double>? lutStrength,
    Expression<String>? toneCurveJson,
    Expression<String>? colorMixerJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (exposure != null) 'exposure': exposure,
      if (temperature != null) 'temperature': temperature,
      if (tint != null) 'tint': tint,
      if (contrast != null) 'contrast': contrast,
      if (shadows != null) 'shadows': shadows,
      if (sharpness != null) 'sharpness': sharpness,
      if (noiseReduction != null) 'noise_reduction': noiseReduction,
      if (lensCorrectionEnabled != null)
        'lens_correction_enabled': lensCorrectionEnabled,
      if (clarity != null) 'clarity': clarity,
      if (vignette != null) 'vignette': vignette,
      if (lutPath != null) 'lut_path': lutPath,
      if (lutStrength != null) 'lut_strength': lutStrength,
      if (toneCurveJson != null) 'tone_curve_json': toneCurveJson,
      if (colorMixerJson != null) 'color_mixer_json': colorMixerJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevelopSettingsCompanion copyWith(
      {Value<String>? assetId,
      Value<double>? exposure,
      Value<double?>? temperature,
      Value<double?>? tint,
      Value<double>? contrast,
      Value<double>? shadows,
      Value<double>? sharpness,
      Value<double>? noiseReduction,
      Value<bool>? lensCorrectionEnabled,
      Value<double>? clarity,
      Value<double>? vignette,
      Value<String?>? lutPath,
      Value<double>? lutStrength,
      Value<String?>? toneCurveJson,
      Value<String?>? colorMixerJson,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DevelopSettingsCompanion(
      assetId: assetId ?? this.assetId,
      exposure: exposure ?? this.exposure,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      contrast: contrast ?? this.contrast,
      shadows: shadows ?? this.shadows,
      sharpness: sharpness ?? this.sharpness,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      lensCorrectionEnabled:
          lensCorrectionEnabled ?? this.lensCorrectionEnabled,
      clarity: clarity ?? this.clarity,
      vignette: vignette ?? this.vignette,
      lutPath: lutPath ?? this.lutPath,
      lutStrength: lutStrength ?? this.lutStrength,
      toneCurveJson: toneCurveJson ?? this.toneCurveJson,
      colorMixerJson: colorMixerJson ?? this.colorMixerJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (exposure.present) {
      map['exposure'] = Variable<double>(exposure.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (tint.present) {
      map['tint'] = Variable<double>(tint.value);
    }
    if (contrast.present) {
      map['contrast'] = Variable<double>(contrast.value);
    }
    if (shadows.present) {
      map['shadows'] = Variable<double>(shadows.value);
    }
    if (sharpness.present) {
      map['sharpness'] = Variable<double>(sharpness.value);
    }
    if (noiseReduction.present) {
      map['noise_reduction'] = Variable<double>(noiseReduction.value);
    }
    if (lensCorrectionEnabled.present) {
      map['lens_correction_enabled'] =
          Variable<bool>(lensCorrectionEnabled.value);
    }
    if (clarity.present) {
      map['clarity'] = Variable<double>(clarity.value);
    }
    if (vignette.present) {
      map['vignette'] = Variable<double>(vignette.value);
    }
    if (lutPath.present) {
      map['lut_path'] = Variable<String>(lutPath.value);
    }
    if (lutStrength.present) {
      map['lut_strength'] = Variable<double>(lutStrength.value);
    }
    if (toneCurveJson.present) {
      map['tone_curve_json'] = Variable<String>(toneCurveJson.value);
    }
    if (colorMixerJson.present) {
      map['color_mixer_json'] = Variable<String>(colorMixerJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevelopSettingsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('exposure: $exposure, ')
          ..write('temperature: $temperature, ')
          ..write('tint: $tint, ')
          ..write('contrast: $contrast, ')
          ..write('shadows: $shadows, ')
          ..write('sharpness: $sharpness, ')
          ..write('noiseReduction: $noiseReduction, ')
          ..write('lensCorrectionEnabled: $lensCorrectionEnabled, ')
          ..write('clarity: $clarity, ')
          ..write('vignette: $vignette, ')
          ..write('lutPath: $lutPath, ')
          ..write('lutStrength: $lutStrength, ')
          ..write('toneCurveJson: $toneCurveJson, ')
          ..write('colorMixerJson: $colorMixerJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevelopHistoryTable extends DevelopHistory
    with TableInfo<$DevelopHistoryTable, DevelopHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevelopHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exposureMeta =
      const VerificationMeta('exposure');
  @override
  late final GeneratedColumn<double> exposure = GeneratedColumn<double>(
      'exposure', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _tintMeta = const VerificationMeta('tint');
  @override
  late final GeneratedColumn<double> tint = GeneratedColumn<double>(
      'tint', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _contrastMeta =
      const VerificationMeta('contrast');
  @override
  late final GeneratedColumn<double> contrast = GeneratedColumn<double>(
      'contrast', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _shadowsMeta =
      const VerificationMeta('shadows');
  @override
  late final GeneratedColumn<double> shadows = GeneratedColumn<double>(
      'shadows', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sharpnessMeta =
      const VerificationMeta('sharpness');
  @override
  late final GeneratedColumn<double> sharpness = GeneratedColumn<double>(
      'sharpness', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _noiseReductionMeta =
      const VerificationMeta('noiseReduction');
  @override
  late final GeneratedColumn<double> noiseReduction = GeneratedColumn<double>(
      'noise_reduction', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lensCorrectionEnabledMeta =
      const VerificationMeta('lensCorrectionEnabled');
  @override
  late final GeneratedColumn<bool> lensCorrectionEnabled =
      GeneratedColumn<bool>('lens_correction_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("lens_correction_enabled" IN (0, 1))'));
  static const VerificationMeta _clarityMeta =
      const VerificationMeta('clarity');
  @override
  late final GeneratedColumn<double> clarity = GeneratedColumn<double>(
      'clarity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _vignetteMeta =
      const VerificationMeta('vignette');
  @override
  late final GeneratedColumn<double> vignette = GeneratedColumn<double>(
      'vignette', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lutPathMeta =
      const VerificationMeta('lutPath');
  @override
  late final GeneratedColumn<String> lutPath = GeneratedColumn<String>(
      'lut_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lutStrengthMeta =
      const VerificationMeta('lutStrength');
  @override
  late final GeneratedColumn<double> lutStrength = GeneratedColumn<double>(
      'lut_strength', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _toneCurveJsonMeta =
      const VerificationMeta('toneCurveJson');
  @override
  late final GeneratedColumn<String> toneCurveJson = GeneratedColumn<String>(
      'tone_curve_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMixerJsonMeta =
      const VerificationMeta('colorMixerJson');
  @override
  late final GeneratedColumn<String> colorMixerJson = GeneratedColumn<String>(
      'color_mixer_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        assetId,
        exposure,
        temperature,
        tint,
        contrast,
        shadows,
        sharpness,
        noiseReduction,
        lensCorrectionEnabled,
        clarity,
        vignette,
        lutPath,
        lutStrength,
        toneCurveJson,
        colorMixerJson,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'develop_history';
  @override
  VerificationContext validateIntegrity(Insertable<DevelopHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('exposure')) {
      context.handle(_exposureMeta,
          exposure.isAcceptableOrUnknown(data['exposure']!, _exposureMeta));
    } else if (isInserting) {
      context.missing(_exposureMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('tint')) {
      context.handle(
          _tintMeta, tint.isAcceptableOrUnknown(data['tint']!, _tintMeta));
    }
    if (data.containsKey('contrast')) {
      context.handle(_contrastMeta,
          contrast.isAcceptableOrUnknown(data['contrast']!, _contrastMeta));
    } else if (isInserting) {
      context.missing(_contrastMeta);
    }
    if (data.containsKey('shadows')) {
      context.handle(_shadowsMeta,
          shadows.isAcceptableOrUnknown(data['shadows']!, _shadowsMeta));
    } else if (isInserting) {
      context.missing(_shadowsMeta);
    }
    if (data.containsKey('sharpness')) {
      context.handle(_sharpnessMeta,
          sharpness.isAcceptableOrUnknown(data['sharpness']!, _sharpnessMeta));
    } else if (isInserting) {
      context.missing(_sharpnessMeta);
    }
    if (data.containsKey('noise_reduction')) {
      context.handle(
          _noiseReductionMeta,
          noiseReduction.isAcceptableOrUnknown(
              data['noise_reduction']!, _noiseReductionMeta));
    } else if (isInserting) {
      context.missing(_noiseReductionMeta);
    }
    if (data.containsKey('lens_correction_enabled')) {
      context.handle(
          _lensCorrectionEnabledMeta,
          lensCorrectionEnabled.isAcceptableOrUnknown(
              data['lens_correction_enabled']!, _lensCorrectionEnabledMeta));
    } else if (isInserting) {
      context.missing(_lensCorrectionEnabledMeta);
    }
    if (data.containsKey('clarity')) {
      context.handle(_clarityMeta,
          clarity.isAcceptableOrUnknown(data['clarity']!, _clarityMeta));
    }
    if (data.containsKey('vignette')) {
      context.handle(_vignetteMeta,
          vignette.isAcceptableOrUnknown(data['vignette']!, _vignetteMeta));
    }
    if (data.containsKey('lut_path')) {
      context.handle(_lutPathMeta,
          lutPath.isAcceptableOrUnknown(data['lut_path']!, _lutPathMeta));
    }
    if (data.containsKey('lut_strength')) {
      context.handle(
          _lutStrengthMeta,
          lutStrength.isAcceptableOrUnknown(
              data['lut_strength']!, _lutStrengthMeta));
    }
    if (data.containsKey('tone_curve_json')) {
      context.handle(
          _toneCurveJsonMeta,
          toneCurveJson.isAcceptableOrUnknown(
              data['tone_curve_json']!, _toneCurveJsonMeta));
    }
    if (data.containsKey('color_mixer_json')) {
      context.handle(
          _colorMixerJsonMeta,
          colorMixerJson.isAcceptableOrUnknown(
              data['color_mixer_json']!, _colorMixerJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevelopHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevelopHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      exposure: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exposure'])!,
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature']),
      tint: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tint']),
      contrast: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}contrast'])!,
      shadows: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shadows'])!,
      sharpness: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sharpness'])!,
      noiseReduction: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}noise_reduction'])!,
      lensCorrectionEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}lens_correction_enabled'])!,
      clarity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}clarity'])!,
      vignette: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vignette'])!,
      lutPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lut_path']),
      lutStrength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lut_strength'])!,
      toneCurveJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tone_curve_json']),
      colorMixerJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}color_mixer_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DevelopHistoryTable createAlias(String alias) {
    return $DevelopHistoryTable(attachedDatabase, alias);
  }
}

class DevelopHistoryData extends DataClass
    implements Insertable<DevelopHistoryData> {
  final int id;
  final String assetId;
  final double exposure;
  final double? temperature;
  final double? tint;
  final double contrast;
  final double shadows;
  final double sharpness;
  final double noiseReduction;
  final bool lensCorrectionEnabled;

  /// Wie in [DevelopSettings]. Ohne sie liesse ein Verlaufs-Eintrag diese
  /// Werte stillschweigend fallen, und „Zurück zu diesem Stand" führte zu
  /// einem anderen Bild als damals.
  final double clarity;
  final double vignette;
  final String? lutPath;
  final double lutStrength;

  /// Wie in [DevelopSettings] – ohne diese beiden Spalten liesse ein
  /// Verlaufs-Eintrag Kurve und Mischer stillschweigend fallen, und
  /// "Zurück zu diesem Stand" führte zu einem anderen Bild als damals.
  final String? toneCurveJson;
  final String? colorMixerJson;
  final DateTime createdAt;
  const DevelopHistoryData(
      {required this.id,
      required this.assetId,
      required this.exposure,
      this.temperature,
      this.tint,
      required this.contrast,
      required this.shadows,
      required this.sharpness,
      required this.noiseReduction,
      required this.lensCorrectionEnabled,
      required this.clarity,
      required this.vignette,
      this.lutPath,
      required this.lutStrength,
      this.toneCurveJson,
      this.colorMixerJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['exposure'] = Variable<double>(exposure);
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || tint != null) {
      map['tint'] = Variable<double>(tint);
    }
    map['contrast'] = Variable<double>(contrast);
    map['shadows'] = Variable<double>(shadows);
    map['sharpness'] = Variable<double>(sharpness);
    map['noise_reduction'] = Variable<double>(noiseReduction);
    map['lens_correction_enabled'] = Variable<bool>(lensCorrectionEnabled);
    map['clarity'] = Variable<double>(clarity);
    map['vignette'] = Variable<double>(vignette);
    if (!nullToAbsent || lutPath != null) {
      map['lut_path'] = Variable<String>(lutPath);
    }
    map['lut_strength'] = Variable<double>(lutStrength);
    if (!nullToAbsent || toneCurveJson != null) {
      map['tone_curve_json'] = Variable<String>(toneCurveJson);
    }
    if (!nullToAbsent || colorMixerJson != null) {
      map['color_mixer_json'] = Variable<String>(colorMixerJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DevelopHistoryCompanion toCompanion(bool nullToAbsent) {
    return DevelopHistoryCompanion(
      id: Value(id),
      assetId: Value(assetId),
      exposure: Value(exposure),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      tint: tint == null && nullToAbsent ? const Value.absent() : Value(tint),
      contrast: Value(contrast),
      shadows: Value(shadows),
      sharpness: Value(sharpness),
      noiseReduction: Value(noiseReduction),
      lensCorrectionEnabled: Value(lensCorrectionEnabled),
      clarity: Value(clarity),
      vignette: Value(vignette),
      lutPath: lutPath == null && nullToAbsent
          ? const Value.absent()
          : Value(lutPath),
      lutStrength: Value(lutStrength),
      toneCurveJson: toneCurveJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toneCurveJson),
      colorMixerJson: colorMixerJson == null && nullToAbsent
          ? const Value.absent()
          : Value(colorMixerJson),
      createdAt: Value(createdAt),
    );
  }

  factory DevelopHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevelopHistoryData(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      exposure: serializer.fromJson<double>(json['exposure']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      tint: serializer.fromJson<double?>(json['tint']),
      contrast: serializer.fromJson<double>(json['contrast']),
      shadows: serializer.fromJson<double>(json['shadows']),
      sharpness: serializer.fromJson<double>(json['sharpness']),
      noiseReduction: serializer.fromJson<double>(json['noiseReduction']),
      lensCorrectionEnabled:
          serializer.fromJson<bool>(json['lensCorrectionEnabled']),
      clarity: serializer.fromJson<double>(json['clarity']),
      vignette: serializer.fromJson<double>(json['vignette']),
      lutPath: serializer.fromJson<String?>(json['lutPath']),
      lutStrength: serializer.fromJson<double>(json['lutStrength']),
      toneCurveJson: serializer.fromJson<String?>(json['toneCurveJson']),
      colorMixerJson: serializer.fromJson<String?>(json['colorMixerJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<String>(assetId),
      'exposure': serializer.toJson<double>(exposure),
      'temperature': serializer.toJson<double?>(temperature),
      'tint': serializer.toJson<double?>(tint),
      'contrast': serializer.toJson<double>(contrast),
      'shadows': serializer.toJson<double>(shadows),
      'sharpness': serializer.toJson<double>(sharpness),
      'noiseReduction': serializer.toJson<double>(noiseReduction),
      'lensCorrectionEnabled': serializer.toJson<bool>(lensCorrectionEnabled),
      'clarity': serializer.toJson<double>(clarity),
      'vignette': serializer.toJson<double>(vignette),
      'lutPath': serializer.toJson<String?>(lutPath),
      'lutStrength': serializer.toJson<double>(lutStrength),
      'toneCurveJson': serializer.toJson<String?>(toneCurveJson),
      'colorMixerJson': serializer.toJson<String?>(colorMixerJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DevelopHistoryData copyWith(
          {int? id,
          String? assetId,
          double? exposure,
          Value<double?> temperature = const Value.absent(),
          Value<double?> tint = const Value.absent(),
          double? contrast,
          double? shadows,
          double? sharpness,
          double? noiseReduction,
          bool? lensCorrectionEnabled,
          double? clarity,
          double? vignette,
          Value<String?> lutPath = const Value.absent(),
          double? lutStrength,
          Value<String?> toneCurveJson = const Value.absent(),
          Value<String?> colorMixerJson = const Value.absent(),
          DateTime? createdAt}) =>
      DevelopHistoryData(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        exposure: exposure ?? this.exposure,
        temperature: temperature.present ? temperature.value : this.temperature,
        tint: tint.present ? tint.value : this.tint,
        contrast: contrast ?? this.contrast,
        shadows: shadows ?? this.shadows,
        sharpness: sharpness ?? this.sharpness,
        noiseReduction: noiseReduction ?? this.noiseReduction,
        lensCorrectionEnabled:
            lensCorrectionEnabled ?? this.lensCorrectionEnabled,
        clarity: clarity ?? this.clarity,
        vignette: vignette ?? this.vignette,
        lutPath: lutPath.present ? lutPath.value : this.lutPath,
        lutStrength: lutStrength ?? this.lutStrength,
        toneCurveJson:
            toneCurveJson.present ? toneCurveJson.value : this.toneCurveJson,
        colorMixerJson:
            colorMixerJson.present ? colorMixerJson.value : this.colorMixerJson,
        createdAt: createdAt ?? this.createdAt,
      );
  DevelopHistoryData copyWithCompanion(DevelopHistoryCompanion data) {
    return DevelopHistoryData(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      exposure: data.exposure.present ? data.exposure.value : this.exposure,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      tint: data.tint.present ? data.tint.value : this.tint,
      contrast: data.contrast.present ? data.contrast.value : this.contrast,
      shadows: data.shadows.present ? data.shadows.value : this.shadows,
      sharpness: data.sharpness.present ? data.sharpness.value : this.sharpness,
      noiseReduction: data.noiseReduction.present
          ? data.noiseReduction.value
          : this.noiseReduction,
      lensCorrectionEnabled: data.lensCorrectionEnabled.present
          ? data.lensCorrectionEnabled.value
          : this.lensCorrectionEnabled,
      clarity: data.clarity.present ? data.clarity.value : this.clarity,
      vignette: data.vignette.present ? data.vignette.value : this.vignette,
      lutPath: data.lutPath.present ? data.lutPath.value : this.lutPath,
      lutStrength:
          data.lutStrength.present ? data.lutStrength.value : this.lutStrength,
      toneCurveJson: data.toneCurveJson.present
          ? data.toneCurveJson.value
          : this.toneCurveJson,
      colorMixerJson: data.colorMixerJson.present
          ? data.colorMixerJson.value
          : this.colorMixerJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevelopHistoryData(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('exposure: $exposure, ')
          ..write('temperature: $temperature, ')
          ..write('tint: $tint, ')
          ..write('contrast: $contrast, ')
          ..write('shadows: $shadows, ')
          ..write('sharpness: $sharpness, ')
          ..write('noiseReduction: $noiseReduction, ')
          ..write('lensCorrectionEnabled: $lensCorrectionEnabled, ')
          ..write('clarity: $clarity, ')
          ..write('vignette: $vignette, ')
          ..write('lutPath: $lutPath, ')
          ..write('lutStrength: $lutStrength, ')
          ..write('toneCurveJson: $toneCurveJson, ')
          ..write('colorMixerJson: $colorMixerJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      assetId,
      exposure,
      temperature,
      tint,
      contrast,
      shadows,
      sharpness,
      noiseReduction,
      lensCorrectionEnabled,
      clarity,
      vignette,
      lutPath,
      lutStrength,
      toneCurveJson,
      colorMixerJson,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevelopHistoryData &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.exposure == this.exposure &&
          other.temperature == this.temperature &&
          other.tint == this.tint &&
          other.contrast == this.contrast &&
          other.shadows == this.shadows &&
          other.sharpness == this.sharpness &&
          other.noiseReduction == this.noiseReduction &&
          other.lensCorrectionEnabled == this.lensCorrectionEnabled &&
          other.clarity == this.clarity &&
          other.vignette == this.vignette &&
          other.lutPath == this.lutPath &&
          other.lutStrength == this.lutStrength &&
          other.toneCurveJson == this.toneCurveJson &&
          other.colorMixerJson == this.colorMixerJson &&
          other.createdAt == this.createdAt);
}

class DevelopHistoryCompanion extends UpdateCompanion<DevelopHistoryData> {
  final Value<int> id;
  final Value<String> assetId;
  final Value<double> exposure;
  final Value<double?> temperature;
  final Value<double?> tint;
  final Value<double> contrast;
  final Value<double> shadows;
  final Value<double> sharpness;
  final Value<double> noiseReduction;
  final Value<bool> lensCorrectionEnabled;
  final Value<double> clarity;
  final Value<double> vignette;
  final Value<String?> lutPath;
  final Value<double> lutStrength;
  final Value<String?> toneCurveJson;
  final Value<String?> colorMixerJson;
  final Value<DateTime> createdAt;
  const DevelopHistoryCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.exposure = const Value.absent(),
    this.temperature = const Value.absent(),
    this.tint = const Value.absent(),
    this.contrast = const Value.absent(),
    this.shadows = const Value.absent(),
    this.sharpness = const Value.absent(),
    this.noiseReduction = const Value.absent(),
    this.lensCorrectionEnabled = const Value.absent(),
    this.clarity = const Value.absent(),
    this.vignette = const Value.absent(),
    this.lutPath = const Value.absent(),
    this.lutStrength = const Value.absent(),
    this.toneCurveJson = const Value.absent(),
    this.colorMixerJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DevelopHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String assetId,
    required double exposure,
    this.temperature = const Value.absent(),
    this.tint = const Value.absent(),
    required double contrast,
    required double shadows,
    required double sharpness,
    required double noiseReduction,
    required bool lensCorrectionEnabled,
    this.clarity = const Value.absent(),
    this.vignette = const Value.absent(),
    this.lutPath = const Value.absent(),
    this.lutStrength = const Value.absent(),
    this.toneCurveJson = const Value.absent(),
    this.colorMixerJson = const Value.absent(),
    required DateTime createdAt,
  })  : assetId = Value(assetId),
        exposure = Value(exposure),
        contrast = Value(contrast),
        shadows = Value(shadows),
        sharpness = Value(sharpness),
        noiseReduction = Value(noiseReduction),
        lensCorrectionEnabled = Value(lensCorrectionEnabled),
        createdAt = Value(createdAt);
  static Insertable<DevelopHistoryData> custom({
    Expression<int>? id,
    Expression<String>? assetId,
    Expression<double>? exposure,
    Expression<double>? temperature,
    Expression<double>? tint,
    Expression<double>? contrast,
    Expression<double>? shadows,
    Expression<double>? sharpness,
    Expression<double>? noiseReduction,
    Expression<bool>? lensCorrectionEnabled,
    Expression<double>? clarity,
    Expression<double>? vignette,
    Expression<String>? lutPath,
    Expression<double>? lutStrength,
    Expression<String>? toneCurveJson,
    Expression<String>? colorMixerJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (exposure != null) 'exposure': exposure,
      if (temperature != null) 'temperature': temperature,
      if (tint != null) 'tint': tint,
      if (contrast != null) 'contrast': contrast,
      if (shadows != null) 'shadows': shadows,
      if (sharpness != null) 'sharpness': sharpness,
      if (noiseReduction != null) 'noise_reduction': noiseReduction,
      if (lensCorrectionEnabled != null)
        'lens_correction_enabled': lensCorrectionEnabled,
      if (clarity != null) 'clarity': clarity,
      if (vignette != null) 'vignette': vignette,
      if (lutPath != null) 'lut_path': lutPath,
      if (lutStrength != null) 'lut_strength': lutStrength,
      if (toneCurveJson != null) 'tone_curve_json': toneCurveJson,
      if (colorMixerJson != null) 'color_mixer_json': colorMixerJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DevelopHistoryCompanion copyWith(
      {Value<int>? id,
      Value<String>? assetId,
      Value<double>? exposure,
      Value<double?>? temperature,
      Value<double?>? tint,
      Value<double>? contrast,
      Value<double>? shadows,
      Value<double>? sharpness,
      Value<double>? noiseReduction,
      Value<bool>? lensCorrectionEnabled,
      Value<double>? clarity,
      Value<double>? vignette,
      Value<String?>? lutPath,
      Value<double>? lutStrength,
      Value<String?>? toneCurveJson,
      Value<String?>? colorMixerJson,
      Value<DateTime>? createdAt}) {
    return DevelopHistoryCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      exposure: exposure ?? this.exposure,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      contrast: contrast ?? this.contrast,
      shadows: shadows ?? this.shadows,
      sharpness: sharpness ?? this.sharpness,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      lensCorrectionEnabled:
          lensCorrectionEnabled ?? this.lensCorrectionEnabled,
      clarity: clarity ?? this.clarity,
      vignette: vignette ?? this.vignette,
      lutPath: lutPath ?? this.lutPath,
      lutStrength: lutStrength ?? this.lutStrength,
      toneCurveJson: toneCurveJson ?? this.toneCurveJson,
      colorMixerJson: colorMixerJson ?? this.colorMixerJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (exposure.present) {
      map['exposure'] = Variable<double>(exposure.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (tint.present) {
      map['tint'] = Variable<double>(tint.value);
    }
    if (contrast.present) {
      map['contrast'] = Variable<double>(contrast.value);
    }
    if (shadows.present) {
      map['shadows'] = Variable<double>(shadows.value);
    }
    if (sharpness.present) {
      map['sharpness'] = Variable<double>(sharpness.value);
    }
    if (noiseReduction.present) {
      map['noise_reduction'] = Variable<double>(noiseReduction.value);
    }
    if (lensCorrectionEnabled.present) {
      map['lens_correction_enabled'] =
          Variable<bool>(lensCorrectionEnabled.value);
    }
    if (clarity.present) {
      map['clarity'] = Variable<double>(clarity.value);
    }
    if (vignette.present) {
      map['vignette'] = Variable<double>(vignette.value);
    }
    if (lutPath.present) {
      map['lut_path'] = Variable<String>(lutPath.value);
    }
    if (lutStrength.present) {
      map['lut_strength'] = Variable<double>(lutStrength.value);
    }
    if (toneCurveJson.present) {
      map['tone_curve_json'] = Variable<String>(toneCurveJson.value);
    }
    if (colorMixerJson.present) {
      map['color_mixer_json'] = Variable<String>(colorMixerJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevelopHistoryCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('exposure: $exposure, ')
          ..write('temperature: $temperature, ')
          ..write('tint: $tint, ')
          ..write('contrast: $contrast, ')
          ..write('shadows: $shadows, ')
          ..write('sharpness: $sharpness, ')
          ..write('noiseReduction: $noiseReduction, ')
          ..write('lensCorrectionEnabled: $lensCorrectionEnabled, ')
          ..write('clarity: $clarity, ')
          ..write('vignette: $vignette, ')
          ..write('lutPath: $lutPath, ')
          ..write('lutStrength: $lutStrength, ')
          ..write('toneCurveJson: $toneCurveJson, ')
          ..write('colorMixerJson: $colorMixerJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VideoTrimsTable extends VideoTrims
    with TableInfo<$VideoTrimsTable, VideoTrimData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoTrimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startSecondsMeta =
      const VerificationMeta('startSeconds');
  @override
  late final GeneratedColumn<double> startSeconds = GeneratedColumn<double>(
      'start_seconds', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _endSecondsMeta =
      const VerificationMeta('endSeconds');
  @override
  late final GeneratedColumn<double> endSeconds = GeneratedColumn<double>(
      'end_seconds', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [assetId, startSeconds, endSeconds, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_trims';
  @override
  VerificationContext validateIntegrity(Insertable<VideoTrimData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('start_seconds')) {
      context.handle(
          _startSecondsMeta,
          startSeconds.isAcceptableOrUnknown(
              data['start_seconds']!, _startSecondsMeta));
    } else if (isInserting) {
      context.missing(_startSecondsMeta);
    }
    if (data.containsKey('end_seconds')) {
      context.handle(
          _endSecondsMeta,
          endSeconds.isAcceptableOrUnknown(
              data['end_seconds']!, _endSecondsMeta));
    } else if (isInserting) {
      context.missing(_endSecondsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  VideoTrimData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoTrimData(
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      startSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}start_seconds'])!,
      endSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}end_seconds'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VideoTrimsTable createAlias(String alias) {
    return $VideoTrimsTable(attachedDatabase, alias);
  }
}

class VideoTrimData extends DataClass implements Insertable<VideoTrimData> {
  final String assetId;
  final double startSeconds;
  final double endSeconds;
  final DateTime updatedAt;
  const VideoTrimData(
      {required this.assetId,
      required this.startSeconds,
      required this.endSeconds,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['start_seconds'] = Variable<double>(startSeconds);
    map['end_seconds'] = Variable<double>(endSeconds);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VideoTrimsCompanion toCompanion(bool nullToAbsent) {
    return VideoTrimsCompanion(
      assetId: Value(assetId),
      startSeconds: Value(startSeconds),
      endSeconds: Value(endSeconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory VideoTrimData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoTrimData(
      assetId: serializer.fromJson<String>(json['assetId']),
      startSeconds: serializer.fromJson<double>(json['startSeconds']),
      endSeconds: serializer.fromJson<double>(json['endSeconds']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'startSeconds': serializer.toJson<double>(startSeconds),
      'endSeconds': serializer.toJson<double>(endSeconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VideoTrimData copyWith(
          {String? assetId,
          double? startSeconds,
          double? endSeconds,
          DateTime? updatedAt}) =>
      VideoTrimData(
        assetId: assetId ?? this.assetId,
        startSeconds: startSeconds ?? this.startSeconds,
        endSeconds: endSeconds ?? this.endSeconds,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  VideoTrimData copyWithCompanion(VideoTrimsCompanion data) {
    return VideoTrimData(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      startSeconds: data.startSeconds.present
          ? data.startSeconds.value
          : this.startSeconds,
      endSeconds:
          data.endSeconds.present ? data.endSeconds.value : this.endSeconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoTrimData(')
          ..write('assetId: $assetId, ')
          ..write('startSeconds: $startSeconds, ')
          ..write('endSeconds: $endSeconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetId, startSeconds, endSeconds, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoTrimData &&
          other.assetId == this.assetId &&
          other.startSeconds == this.startSeconds &&
          other.endSeconds == this.endSeconds &&
          other.updatedAt == this.updatedAt);
}

class VideoTrimsCompanion extends UpdateCompanion<VideoTrimData> {
  final Value<String> assetId;
  final Value<double> startSeconds;
  final Value<double> endSeconds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VideoTrimsCompanion({
    this.assetId = const Value.absent(),
    this.startSeconds = const Value.absent(),
    this.endSeconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideoTrimsCompanion.insert({
    required String assetId,
    required double startSeconds,
    required double endSeconds,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : assetId = Value(assetId),
        startSeconds = Value(startSeconds),
        endSeconds = Value(endSeconds),
        updatedAt = Value(updatedAt);
  static Insertable<VideoTrimData> custom({
    Expression<String>? assetId,
    Expression<double>? startSeconds,
    Expression<double>? endSeconds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (startSeconds != null) 'start_seconds': startSeconds,
      if (endSeconds != null) 'end_seconds': endSeconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideoTrimsCompanion copyWith(
      {Value<String>? assetId,
      Value<double>? startSeconds,
      Value<double>? endSeconds,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return VideoTrimsCompanion(
      assetId: assetId ?? this.assetId,
      startSeconds: startSeconds ?? this.startSeconds,
      endSeconds: endSeconds ?? this.endSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (startSeconds.present) {
      map['start_seconds'] = Variable<double>(startSeconds.value);
    }
    if (endSeconds.present) {
      map['end_seconds'] = Variable<double>(endSeconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoTrimsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('startSeconds: $startSeconds, ')
          ..write('endSeconds: $endSeconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevelopMasksTable extends DevelopMasks
    with TableInfo<$DevelopMasksTable, DevelopMaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevelopMasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maskRelativePathMeta =
      const VerificationMeta('maskRelativePath');
  @override
  late final GeneratedColumn<String> maskRelativePath = GeneratedColumn<String>(
      'mask_relative_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exposureMeta =
      const VerificationMeta('exposure');
  @override
  late final GeneratedColumn<double> exposure = GeneratedColumn<double>(
      'exposure', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _tintMeta = const VerificationMeta('tint');
  @override
  late final GeneratedColumn<double> tint = GeneratedColumn<double>(
      'tint', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _contrastMeta =
      const VerificationMeta('contrast');
  @override
  late final GeneratedColumn<double> contrast = GeneratedColumn<double>(
      'contrast', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shadowsMeta =
      const VerificationMeta('shadows');
  @override
  late final GeneratedColumn<double> shadows = GeneratedColumn<double>(
      'shadows', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sharpnessMeta =
      const VerificationMeta('sharpness');
  @override
  late final GeneratedColumn<double> sharpness = GeneratedColumn<double>(
      'sharpness', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noiseReductionMeta =
      const VerificationMeta('noiseReduction');
  @override
  late final GeneratedColumn<double> noiseReduction = GeneratedColumn<double>(
      'noise_reduction', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lensCorrectionEnabledMeta =
      const VerificationMeta('lensCorrectionEnabled');
  @override
  late final GeneratedColumn<bool> lensCorrectionEnabled =
      GeneratedColumn<bool>('lens_correction_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("lens_correction_enabled" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _shapeDefinitionJsonMeta =
      const VerificationMeta('shapeDefinitionJson');
  @override
  late final GeneratedColumn<String> shapeDefinitionJson =
      GeneratedColumn<String>('shape_definition_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        assetId,
        maskRelativePath,
        label,
        exposure,
        temperature,
        tint,
        contrast,
        shadows,
        sharpness,
        noiseReduction,
        lensCorrectionEnabled,
        createdAt,
        shapeDefinitionJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'develop_masks';
  @override
  VerificationContext validateIntegrity(Insertable<DevelopMaskData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('mask_relative_path')) {
      context.handle(
          _maskRelativePathMeta,
          maskRelativePath.isAcceptableOrUnknown(
              data['mask_relative_path']!, _maskRelativePathMeta));
    } else if (isInserting) {
      context.missing(_maskRelativePathMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('exposure')) {
      context.handle(_exposureMeta,
          exposure.isAcceptableOrUnknown(data['exposure']!, _exposureMeta));
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('tint')) {
      context.handle(
          _tintMeta, tint.isAcceptableOrUnknown(data['tint']!, _tintMeta));
    }
    if (data.containsKey('contrast')) {
      context.handle(_contrastMeta,
          contrast.isAcceptableOrUnknown(data['contrast']!, _contrastMeta));
    }
    if (data.containsKey('shadows')) {
      context.handle(_shadowsMeta,
          shadows.isAcceptableOrUnknown(data['shadows']!, _shadowsMeta));
    }
    if (data.containsKey('sharpness')) {
      context.handle(_sharpnessMeta,
          sharpness.isAcceptableOrUnknown(data['sharpness']!, _sharpnessMeta));
    }
    if (data.containsKey('noise_reduction')) {
      context.handle(
          _noiseReductionMeta,
          noiseReduction.isAcceptableOrUnknown(
              data['noise_reduction']!, _noiseReductionMeta));
    }
    if (data.containsKey('lens_correction_enabled')) {
      context.handle(
          _lensCorrectionEnabledMeta,
          lensCorrectionEnabled.isAcceptableOrUnknown(
              data['lens_correction_enabled']!, _lensCorrectionEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('shape_definition_json')) {
      context.handle(
          _shapeDefinitionJsonMeta,
          shapeDefinitionJson.isAcceptableOrUnknown(
              data['shape_definition_json']!, _shapeDefinitionJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevelopMaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevelopMaskData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      maskRelativePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}mask_relative_path'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      exposure: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exposure'])!,
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature']),
      tint: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tint']),
      contrast: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}contrast'])!,
      shadows: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shadows'])!,
      sharpness: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sharpness'])!,
      noiseReduction: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}noise_reduction'])!,
      lensCorrectionEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}lens_correction_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      shapeDefinitionJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shape_definition_json']),
    );
  }

  @override
  $DevelopMasksTable createAlias(String alias) {
    return $DevelopMasksTable(attachedDatabase, alias);
  }
}

class DevelopMaskData extends DataClass implements Insertable<DevelopMaskData> {
  final int id;
  final String assetId;
  final String maskRelativePath;
  final String label;
  final double exposure;
  final double? temperature;
  final double? tint;
  final double contrast;
  final double shadows;
  final double sharpness;
  final double noiseReduction;
  final bool lensCorrectionEnabled;
  final DateTime createdAt;

  /// JSON-kodierte [MaskShapeDefinition] (siehe vector_mask_service.dart) –
  /// `null` bedeutet eine per SAM-Punkt-Prompt erzeugte Maske (heutiges
  /// Verhalten, nicht nachträglich als Form editierbar). Ist ein Wert
  /// gesetzt, ist er die Quelle der Wahrheit für erneutes Bearbeiten;
  /// [maskRelativePath] bleibt in beiden Fällen der gerenderte Graustufen-
  /// PNG-Cache, den die native Kompositierung tatsächlich konsumiert – bei
  /// jeder Formänderung wird er neu gerendert und überschrieben.
  final String? shapeDefinitionJson;
  const DevelopMaskData(
      {required this.id,
      required this.assetId,
      required this.maskRelativePath,
      required this.label,
      required this.exposure,
      this.temperature,
      this.tint,
      required this.contrast,
      required this.shadows,
      required this.sharpness,
      required this.noiseReduction,
      required this.lensCorrectionEnabled,
      required this.createdAt,
      this.shapeDefinitionJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['mask_relative_path'] = Variable<String>(maskRelativePath);
    map['label'] = Variable<String>(label);
    map['exposure'] = Variable<double>(exposure);
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || tint != null) {
      map['tint'] = Variable<double>(tint);
    }
    map['contrast'] = Variable<double>(contrast);
    map['shadows'] = Variable<double>(shadows);
    map['sharpness'] = Variable<double>(sharpness);
    map['noise_reduction'] = Variable<double>(noiseReduction);
    map['lens_correction_enabled'] = Variable<bool>(lensCorrectionEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || shapeDefinitionJson != null) {
      map['shape_definition_json'] = Variable<String>(shapeDefinitionJson);
    }
    return map;
  }

  DevelopMasksCompanion toCompanion(bool nullToAbsent) {
    return DevelopMasksCompanion(
      id: Value(id),
      assetId: Value(assetId),
      maskRelativePath: Value(maskRelativePath),
      label: Value(label),
      exposure: Value(exposure),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      tint: tint == null && nullToAbsent ? const Value.absent() : Value(tint),
      contrast: Value(contrast),
      shadows: Value(shadows),
      sharpness: Value(sharpness),
      noiseReduction: Value(noiseReduction),
      lensCorrectionEnabled: Value(lensCorrectionEnabled),
      createdAt: Value(createdAt),
      shapeDefinitionJson: shapeDefinitionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(shapeDefinitionJson),
    );
  }

  factory DevelopMaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevelopMaskData(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      maskRelativePath: serializer.fromJson<String>(json['maskRelativePath']),
      label: serializer.fromJson<String>(json['label']),
      exposure: serializer.fromJson<double>(json['exposure']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      tint: serializer.fromJson<double?>(json['tint']),
      contrast: serializer.fromJson<double>(json['contrast']),
      shadows: serializer.fromJson<double>(json['shadows']),
      sharpness: serializer.fromJson<double>(json['sharpness']),
      noiseReduction: serializer.fromJson<double>(json['noiseReduction']),
      lensCorrectionEnabled:
          serializer.fromJson<bool>(json['lensCorrectionEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      shapeDefinitionJson:
          serializer.fromJson<String?>(json['shapeDefinitionJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<String>(assetId),
      'maskRelativePath': serializer.toJson<String>(maskRelativePath),
      'label': serializer.toJson<String>(label),
      'exposure': serializer.toJson<double>(exposure),
      'temperature': serializer.toJson<double?>(temperature),
      'tint': serializer.toJson<double?>(tint),
      'contrast': serializer.toJson<double>(contrast),
      'shadows': serializer.toJson<double>(shadows),
      'sharpness': serializer.toJson<double>(sharpness),
      'noiseReduction': serializer.toJson<double>(noiseReduction),
      'lensCorrectionEnabled': serializer.toJson<bool>(lensCorrectionEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'shapeDefinitionJson': serializer.toJson<String?>(shapeDefinitionJson),
    };
  }

  DevelopMaskData copyWith(
          {int? id,
          String? assetId,
          String? maskRelativePath,
          String? label,
          double? exposure,
          Value<double?> temperature = const Value.absent(),
          Value<double?> tint = const Value.absent(),
          double? contrast,
          double? shadows,
          double? sharpness,
          double? noiseReduction,
          bool? lensCorrectionEnabled,
          DateTime? createdAt,
          Value<String?> shapeDefinitionJson = const Value.absent()}) =>
      DevelopMaskData(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        maskRelativePath: maskRelativePath ?? this.maskRelativePath,
        label: label ?? this.label,
        exposure: exposure ?? this.exposure,
        temperature: temperature.present ? temperature.value : this.temperature,
        tint: tint.present ? tint.value : this.tint,
        contrast: contrast ?? this.contrast,
        shadows: shadows ?? this.shadows,
        sharpness: sharpness ?? this.sharpness,
        noiseReduction: noiseReduction ?? this.noiseReduction,
        lensCorrectionEnabled:
            lensCorrectionEnabled ?? this.lensCorrectionEnabled,
        createdAt: createdAt ?? this.createdAt,
        shapeDefinitionJson: shapeDefinitionJson.present
            ? shapeDefinitionJson.value
            : this.shapeDefinitionJson,
      );
  DevelopMaskData copyWithCompanion(DevelopMasksCompanion data) {
    return DevelopMaskData(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      maskRelativePath: data.maskRelativePath.present
          ? data.maskRelativePath.value
          : this.maskRelativePath,
      label: data.label.present ? data.label.value : this.label,
      exposure: data.exposure.present ? data.exposure.value : this.exposure,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      tint: data.tint.present ? data.tint.value : this.tint,
      contrast: data.contrast.present ? data.contrast.value : this.contrast,
      shadows: data.shadows.present ? data.shadows.value : this.shadows,
      sharpness: data.sharpness.present ? data.sharpness.value : this.sharpness,
      noiseReduction: data.noiseReduction.present
          ? data.noiseReduction.value
          : this.noiseReduction,
      lensCorrectionEnabled: data.lensCorrectionEnabled.present
          ? data.lensCorrectionEnabled.value
          : this.lensCorrectionEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      shapeDefinitionJson: data.shapeDefinitionJson.present
          ? data.shapeDefinitionJson.value
          : this.shapeDefinitionJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevelopMaskData(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('maskRelativePath: $maskRelativePath, ')
          ..write('label: $label, ')
          ..write('exposure: $exposure, ')
          ..write('temperature: $temperature, ')
          ..write('tint: $tint, ')
          ..write('contrast: $contrast, ')
          ..write('shadows: $shadows, ')
          ..write('sharpness: $sharpness, ')
          ..write('noiseReduction: $noiseReduction, ')
          ..write('lensCorrectionEnabled: $lensCorrectionEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('shapeDefinitionJson: $shapeDefinitionJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      assetId,
      maskRelativePath,
      label,
      exposure,
      temperature,
      tint,
      contrast,
      shadows,
      sharpness,
      noiseReduction,
      lensCorrectionEnabled,
      createdAt,
      shapeDefinitionJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevelopMaskData &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.maskRelativePath == this.maskRelativePath &&
          other.label == this.label &&
          other.exposure == this.exposure &&
          other.temperature == this.temperature &&
          other.tint == this.tint &&
          other.contrast == this.contrast &&
          other.shadows == this.shadows &&
          other.sharpness == this.sharpness &&
          other.noiseReduction == this.noiseReduction &&
          other.lensCorrectionEnabled == this.lensCorrectionEnabled &&
          other.createdAt == this.createdAt &&
          other.shapeDefinitionJson == this.shapeDefinitionJson);
}

class DevelopMasksCompanion extends UpdateCompanion<DevelopMaskData> {
  final Value<int> id;
  final Value<String> assetId;
  final Value<String> maskRelativePath;
  final Value<String> label;
  final Value<double> exposure;
  final Value<double?> temperature;
  final Value<double?> tint;
  final Value<double> contrast;
  final Value<double> shadows;
  final Value<double> sharpness;
  final Value<double> noiseReduction;
  final Value<bool> lensCorrectionEnabled;
  final Value<DateTime> createdAt;
  final Value<String?> shapeDefinitionJson;
  const DevelopMasksCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.maskRelativePath = const Value.absent(),
    this.label = const Value.absent(),
    this.exposure = const Value.absent(),
    this.temperature = const Value.absent(),
    this.tint = const Value.absent(),
    this.contrast = const Value.absent(),
    this.shadows = const Value.absent(),
    this.sharpness = const Value.absent(),
    this.noiseReduction = const Value.absent(),
    this.lensCorrectionEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.shapeDefinitionJson = const Value.absent(),
  });
  DevelopMasksCompanion.insert({
    this.id = const Value.absent(),
    required String assetId,
    required String maskRelativePath,
    required String label,
    this.exposure = const Value.absent(),
    this.temperature = const Value.absent(),
    this.tint = const Value.absent(),
    this.contrast = const Value.absent(),
    this.shadows = const Value.absent(),
    this.sharpness = const Value.absent(),
    this.noiseReduction = const Value.absent(),
    this.lensCorrectionEnabled = const Value.absent(),
    required DateTime createdAt,
    this.shapeDefinitionJson = const Value.absent(),
  })  : assetId = Value(assetId),
        maskRelativePath = Value(maskRelativePath),
        label = Value(label),
        createdAt = Value(createdAt);
  static Insertable<DevelopMaskData> custom({
    Expression<int>? id,
    Expression<String>? assetId,
    Expression<String>? maskRelativePath,
    Expression<String>? label,
    Expression<double>? exposure,
    Expression<double>? temperature,
    Expression<double>? tint,
    Expression<double>? contrast,
    Expression<double>? shadows,
    Expression<double>? sharpness,
    Expression<double>? noiseReduction,
    Expression<bool>? lensCorrectionEnabled,
    Expression<DateTime>? createdAt,
    Expression<String>? shapeDefinitionJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (maskRelativePath != null) 'mask_relative_path': maskRelativePath,
      if (label != null) 'label': label,
      if (exposure != null) 'exposure': exposure,
      if (temperature != null) 'temperature': temperature,
      if (tint != null) 'tint': tint,
      if (contrast != null) 'contrast': contrast,
      if (shadows != null) 'shadows': shadows,
      if (sharpness != null) 'sharpness': sharpness,
      if (noiseReduction != null) 'noise_reduction': noiseReduction,
      if (lensCorrectionEnabled != null)
        'lens_correction_enabled': lensCorrectionEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (shapeDefinitionJson != null)
        'shape_definition_json': shapeDefinitionJson,
    });
  }

  DevelopMasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? assetId,
      Value<String>? maskRelativePath,
      Value<String>? label,
      Value<double>? exposure,
      Value<double?>? temperature,
      Value<double?>? tint,
      Value<double>? contrast,
      Value<double>? shadows,
      Value<double>? sharpness,
      Value<double>? noiseReduction,
      Value<bool>? lensCorrectionEnabled,
      Value<DateTime>? createdAt,
      Value<String?>? shapeDefinitionJson}) {
    return DevelopMasksCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      maskRelativePath: maskRelativePath ?? this.maskRelativePath,
      label: label ?? this.label,
      exposure: exposure ?? this.exposure,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      contrast: contrast ?? this.contrast,
      shadows: shadows ?? this.shadows,
      sharpness: sharpness ?? this.sharpness,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      lensCorrectionEnabled:
          lensCorrectionEnabled ?? this.lensCorrectionEnabled,
      createdAt: createdAt ?? this.createdAt,
      shapeDefinitionJson: shapeDefinitionJson ?? this.shapeDefinitionJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (maskRelativePath.present) {
      map['mask_relative_path'] = Variable<String>(maskRelativePath.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (exposure.present) {
      map['exposure'] = Variable<double>(exposure.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (tint.present) {
      map['tint'] = Variable<double>(tint.value);
    }
    if (contrast.present) {
      map['contrast'] = Variable<double>(contrast.value);
    }
    if (shadows.present) {
      map['shadows'] = Variable<double>(shadows.value);
    }
    if (sharpness.present) {
      map['sharpness'] = Variable<double>(sharpness.value);
    }
    if (noiseReduction.present) {
      map['noise_reduction'] = Variable<double>(noiseReduction.value);
    }
    if (lensCorrectionEnabled.present) {
      map['lens_correction_enabled'] =
          Variable<bool>(lensCorrectionEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (shapeDefinitionJson.present) {
      map['shape_definition_json'] =
          Variable<String>(shapeDefinitionJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevelopMasksCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('maskRelativePath: $maskRelativePath, ')
          ..write('label: $label, ')
          ..write('exposure: $exposure, ')
          ..write('temperature: $temperature, ')
          ..write('tint: $tint, ')
          ..write('contrast: $contrast, ')
          ..write('shadows: $shadows, ')
          ..write('sharpness: $sharpness, ')
          ..write('noiseReduction: $noiseReduction, ')
          ..write('lensCorrectionEnabled: $lensCorrectionEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('shapeDefinitionJson: $shapeDefinitionJson')
          ..write(')'))
        .toString();
  }
}

class $RestoreJobsTable extends RestoreJobs
    with TableInfo<$RestoreJobsTable, RestoreJobData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestoreJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tilesDoneMeta =
      const VerificationMeta('tilesDone');
  @override
  late final GeneratedColumn<int> tilesDone = GeneratedColumn<int>(
      'tiles_done', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tilesTotalMeta =
      const VerificationMeta('tilesTotal');
  @override
  late final GeneratedColumn<int> tilesTotal = GeneratedColumn<int>(
      'tiles_total', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        assetId,
        status,
        tilesDone,
        tilesTotal,
        errorMessage,
        createdAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restore_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<RestoreJobData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('tiles_done')) {
      context.handle(_tilesDoneMeta,
          tilesDone.isAcceptableOrUnknown(data['tiles_done']!, _tilesDoneMeta));
    }
    if (data.containsKey('tiles_total')) {
      context.handle(
          _tilesTotalMeta,
          tilesTotal.isAcceptableOrUnknown(
              data['tiles_total']!, _tilesTotalMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RestoreJobData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestoreJobData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      tilesDone: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tiles_done'])!,
      tilesTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tiles_total'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $RestoreJobsTable createAlias(String alias) {
    return $RestoreJobsTable(attachedDatabase, alias);
  }
}

class RestoreJobData extends DataClass implements Insertable<RestoreJobData> {
  final String id;
  final String assetId;
  final String status;
  final int tilesDone;
  final int tilesTotal;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  const RestoreJobData(
      {required this.id,
      required this.assetId,
      required this.status,
      required this.tilesDone,
      required this.tilesTotal,
      this.errorMessage,
      required this.createdAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['status'] = Variable<String>(status);
    map['tiles_done'] = Variable<int>(tilesDone);
    map['tiles_total'] = Variable<int>(tilesTotal);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  RestoreJobsCompanion toCompanion(bool nullToAbsent) {
    return RestoreJobsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      status: Value(status),
      tilesDone: Value(tilesDone),
      tilesTotal: Value(tilesTotal),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory RestoreJobData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestoreJobData(
      id: serializer.fromJson<String>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      status: serializer.fromJson<String>(json['status']),
      tilesDone: serializer.fromJson<int>(json['tilesDone']),
      tilesTotal: serializer.fromJson<int>(json['tilesTotal']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assetId': serializer.toJson<String>(assetId),
      'status': serializer.toJson<String>(status),
      'tilesDone': serializer.toJson<int>(tilesDone),
      'tilesTotal': serializer.toJson<int>(tilesTotal),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  RestoreJobData copyWith(
          {String? id,
          String? assetId,
          String? status,
          int? tilesDone,
          int? tilesTotal,
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      RestoreJobData(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        status: status ?? this.status,
        tilesDone: tilesDone ?? this.tilesDone,
        tilesTotal: tilesTotal ?? this.tilesTotal,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  RestoreJobData copyWithCompanion(RestoreJobsCompanion data) {
    return RestoreJobData(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      status: data.status.present ? data.status.value : this.status,
      tilesDone: data.tilesDone.present ? data.tilesDone.value : this.tilesDone,
      tilesTotal:
          data.tilesTotal.present ? data.tilesTotal.value : this.tilesTotal,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestoreJobData(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('status: $status, ')
          ..write('tilesDone: $tilesDone, ')
          ..write('tilesTotal: $tilesTotal, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, assetId, status, tilesDone, tilesTotal,
      errorMessage, createdAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestoreJobData &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.status == this.status &&
          other.tilesDone == this.tilesDone &&
          other.tilesTotal == this.tilesTotal &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class RestoreJobsCompanion extends UpdateCompanion<RestoreJobData> {
  final Value<String> id;
  final Value<String> assetId;
  final Value<String> status;
  final Value<int> tilesDone;
  final Value<int> tilesTotal;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const RestoreJobsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.status = const Value.absent(),
    this.tilesDone = const Value.absent(),
    this.tilesTotal = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestoreJobsCompanion.insert({
    required String id,
    required String assetId,
    required String status,
    this.tilesDone = const Value.absent(),
    this.tilesTotal = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        assetId = Value(assetId),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<RestoreJobData> custom({
    Expression<String>? id,
    Expression<String>? assetId,
    Expression<String>? status,
    Expression<int>? tilesDone,
    Expression<int>? tilesTotal,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (status != null) 'status': status,
      if (tilesDone != null) 'tiles_done': tilesDone,
      if (tilesTotal != null) 'tiles_total': tilesTotal,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestoreJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? assetId,
      Value<String>? status,
      Value<int>? tilesDone,
      Value<int>? tilesTotal,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return RestoreJobsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      status: status ?? this.status,
      tilesDone: tilesDone ?? this.tilesDone,
      tilesTotal: tilesTotal ?? this.tilesTotal,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tilesDone.present) {
      map['tiles_done'] = Variable<int>(tilesDone.value);
    }
    if (tilesTotal.present) {
      map['tiles_total'] = Variable<int>(tilesTotal.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestoreJobsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('status: $status, ')
          ..write('tilesDone: $tilesDone, ')
          ..write('tilesTotal: $tilesTotal, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _spracheMeta =
      const VerificationMeta('sprache');
  @override
  late final GeneratedColumn<String> sprache = GeneratedColumn<String>(
      'sprache', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _autoAnalyzeAfterImportMeta =
      const VerificationMeta('autoAnalyzeAfterImport');
  @override
  late final GeneratedColumn<bool> autoAnalyzeAfterImport =
      GeneratedColumn<bool>('auto_analyze_after_import', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("auto_analyze_after_import" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _watchedFolderPathMeta =
      const VerificationMeta('watchedFolderPath');
  @override
  late final GeneratedColumn<String> watchedFolderPath =
      GeneratedColumn<String>('watched_folder_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _watchedFolderTokenMeta =
      const VerificationMeta('watchedFolderToken');
  @override
  late final GeneratedColumn<String> watchedFolderToken =
      GeneratedColumn<String>('watched_folder_token', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _faceSimilarityThresholdMeta =
      const VerificationMeta('faceSimilarityThreshold');
  @override
  late final GeneratedColumn<double> faceSimilarityThreshold =
      GeneratedColumn<double>('face_similarity_threshold', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.363));
  static const VerificationMeta _translateCaptionsMeta =
      const VerificationMeta('translateCaptions');
  @override
  late final GeneratedColumn<bool> translateCaptions = GeneratedColumn<bool>(
      'translate_captions', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("translate_captions" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _translateSearchAndTagsMeta =
      const VerificationMeta('translateSearchAndTags');
  @override
  late final GeneratedColumn<bool> translateSearchAndTags =
      GeneratedColumn<bool>('translate_search_and_tags', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("translate_search_and_tags" IN (0, 1))'),
          defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        themeMode,
        sprache,
        autoAnalyzeAfterImport,
        watchedFolderPath,
        watchedFolderToken,
        faceSimilarityThreshold,
        translateCaptions,
        translateSearchAndTags
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('sprache')) {
      context.handle(_spracheMeta,
          sprache.isAcceptableOrUnknown(data['sprache']!, _spracheMeta));
    }
    if (data.containsKey('auto_analyze_after_import')) {
      context.handle(
          _autoAnalyzeAfterImportMeta,
          autoAnalyzeAfterImport.isAcceptableOrUnknown(
              data['auto_analyze_after_import']!, _autoAnalyzeAfterImportMeta));
    }
    if (data.containsKey('watched_folder_path')) {
      context.handle(
          _watchedFolderPathMeta,
          watchedFolderPath.isAcceptableOrUnknown(
              data['watched_folder_path']!, _watchedFolderPathMeta));
    }
    if (data.containsKey('watched_folder_token')) {
      context.handle(
          _watchedFolderTokenMeta,
          watchedFolderToken.isAcceptableOrUnknown(
              data['watched_folder_token']!, _watchedFolderTokenMeta));
    }
    if (data.containsKey('face_similarity_threshold')) {
      context.handle(
          _faceSimilarityThresholdMeta,
          faceSimilarityThreshold.isAcceptableOrUnknown(
              data['face_similarity_threshold']!,
              _faceSimilarityThresholdMeta));
    }
    if (data.containsKey('translate_captions')) {
      context.handle(
          _translateCaptionsMeta,
          translateCaptions.isAcceptableOrUnknown(
              data['translate_captions']!, _translateCaptionsMeta));
    }
    if (data.containsKey('translate_search_and_tags')) {
      context.handle(
          _translateSearchAndTagsMeta,
          translateSearchAndTags.isAcceptableOrUnknown(
              data['translate_search_and_tags']!, _translateSearchAndTagsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      sprache: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sprache'])!,
      autoAnalyzeAfterImport: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}auto_analyze_after_import'])!,
      watchedFolderPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}watched_folder_path']),
      watchedFolderToken: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}watched_folder_token']),
      faceSimilarityThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}face_similarity_threshold'])!,
      translateCaptions: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}translate_captions'])!,
      translateSearchAndTags: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}translate_search_and_tags'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsData extends DataClass implements Insertable<AppSettingsData> {
  final int id;
  final String themeMode;

  /// Oberflächensprache: `'system'`, `'de'` oder `'en'`.
  ///
  /// Dasselbe Muster wie [themeMode], und aus demselben Grund als Text
  /// statt als Aufzählung: Eine unbekannte Angabe (etwa aus einer
  /// neueren Fassung) fällt beim Lesen auf den Standard zurück, statt
  /// den Start zu verhindern.
  final String sprache;

  /// Ob die rechenintensiven KI-Auswertungen (Gesichter, Texterkennung,
  /// CLIP, Bildbeschreibung, Unschärfe) nach einem Import automatisch als
  /// Hintergrundaufgabe nachlaufen. Standard an – sonst blieben frisch
  /// importierte Fotos ohne Suche und ohne Personenzuordnung, bis jemand
  /// die Werkzeuge von Hand anstößt.
  final bool autoAnalyzeAfterImport;

  /// Ordner, der laufend auf neue Dateien geprüft wird (siehe
  /// LibraryState.pruefeUeberwachtenOrdner). Null = keiner eingerichtet.
  ///
  /// Der Zugriff braucht unter macOS zusätzlich das Sandbox-Merkmal aus der
  /// Ordnerauswahl, sonst erlischt er beim nächsten Programmstart – deshalb
  /// beide Angaben zusammen, wie bei den Bibliotheksorten auch.
  final String? watchedFolderPath;
  final String? watchedFolderToken;

  /// Allgemeine Schwelle für "dasselbe Gesicht" (Kosinus-Ähnlichkeit).
  ///
  /// 0,363 ist der von OpenCV Zoo für SFace dokumentierte Wert. Die
  /// Einstellung lag bisher nur im Speicher – der Regler unter "Werkzeuge"
  /// war bei jedem Programmstart wieder auf dem Ausgangswert, ohne dass
  /// das irgendwo stand.
  final double faceSimilarityThreshold;

  /// Bildbeschreibungen ins Deutsche übersetzen (Modell `translation_en_de`).
  final bool translateCaptions;

  /// Deutsche Suchanfragen und Schlagwörter vor der KI-Bildsuche ins
  /// Englische übersetzen (Modell `translation_de_en`).
  ///
  /// Standard aus, und zwar bewusst: An 103 Fotos der Testbibliothek
  /// gemessen trennt die englische Fassung eines Vokabelbegriffs bei 33
  /// von 56 Begriffen schärfer, bei 19 schlechter. Der Gewinn ist real,
  /// aber weder gross noch durchgängig – und die Zahl vergebener Tags
  /// sinkt bei gleicher Schwelle von 402 auf 248. Eine solche Änderung
  /// gehört nicht stillschweigend eingeschaltet.
  final bool translateSearchAndTags;
  const AppSettingsData(
      {required this.id,
      required this.themeMode,
      required this.sprache,
      required this.autoAnalyzeAfterImport,
      this.watchedFolderPath,
      this.watchedFolderToken,
      required this.faceSimilarityThreshold,
      required this.translateCaptions,
      required this.translateSearchAndTags});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['sprache'] = Variable<String>(sprache);
    map['auto_analyze_after_import'] = Variable<bool>(autoAnalyzeAfterImport);
    if (!nullToAbsent || watchedFolderPath != null) {
      map['watched_folder_path'] = Variable<String>(watchedFolderPath);
    }
    if (!nullToAbsent || watchedFolderToken != null) {
      map['watched_folder_token'] = Variable<String>(watchedFolderToken);
    }
    map['face_similarity_threshold'] =
        Variable<double>(faceSimilarityThreshold);
    map['translate_captions'] = Variable<bool>(translateCaptions);
    map['translate_search_and_tags'] = Variable<bool>(translateSearchAndTags);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      sprache: Value(sprache),
      autoAnalyzeAfterImport: Value(autoAnalyzeAfterImport),
      watchedFolderPath: watchedFolderPath == null && nullToAbsent
          ? const Value.absent()
          : Value(watchedFolderPath),
      watchedFolderToken: watchedFolderToken == null && nullToAbsent
          ? const Value.absent()
          : Value(watchedFolderToken),
      faceSimilarityThreshold: Value(faceSimilarityThreshold),
      translateCaptions: Value(translateCaptions),
      translateSearchAndTags: Value(translateSearchAndTags),
    );
  }

  factory AppSettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsData(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      sprache: serializer.fromJson<String>(json['sprache']),
      autoAnalyzeAfterImport:
          serializer.fromJson<bool>(json['autoAnalyzeAfterImport']),
      watchedFolderPath:
          serializer.fromJson<String?>(json['watchedFolderPath']),
      watchedFolderToken:
          serializer.fromJson<String?>(json['watchedFolderToken']),
      faceSimilarityThreshold:
          serializer.fromJson<double>(json['faceSimilarityThreshold']),
      translateCaptions: serializer.fromJson<bool>(json['translateCaptions']),
      translateSearchAndTags:
          serializer.fromJson<bool>(json['translateSearchAndTags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'sprache': serializer.toJson<String>(sprache),
      'autoAnalyzeAfterImport': serializer.toJson<bool>(autoAnalyzeAfterImport),
      'watchedFolderPath': serializer.toJson<String?>(watchedFolderPath),
      'watchedFolderToken': serializer.toJson<String?>(watchedFolderToken),
      'faceSimilarityThreshold':
          serializer.toJson<double>(faceSimilarityThreshold),
      'translateCaptions': serializer.toJson<bool>(translateCaptions),
      'translateSearchAndTags': serializer.toJson<bool>(translateSearchAndTags),
    };
  }

  AppSettingsData copyWith(
          {int? id,
          String? themeMode,
          String? sprache,
          bool? autoAnalyzeAfterImport,
          Value<String?> watchedFolderPath = const Value.absent(),
          Value<String?> watchedFolderToken = const Value.absent(),
          double? faceSimilarityThreshold,
          bool? translateCaptions,
          bool? translateSearchAndTags}) =>
      AppSettingsData(
        id: id ?? this.id,
        themeMode: themeMode ?? this.themeMode,
        sprache: sprache ?? this.sprache,
        autoAnalyzeAfterImport:
            autoAnalyzeAfterImport ?? this.autoAnalyzeAfterImport,
        watchedFolderPath: watchedFolderPath.present
            ? watchedFolderPath.value
            : this.watchedFolderPath,
        watchedFolderToken: watchedFolderToken.present
            ? watchedFolderToken.value
            : this.watchedFolderToken,
        faceSimilarityThreshold:
            faceSimilarityThreshold ?? this.faceSimilarityThreshold,
        translateCaptions: translateCaptions ?? this.translateCaptions,
        translateSearchAndTags:
            translateSearchAndTags ?? this.translateSearchAndTags,
      );
  AppSettingsData copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsData(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      sprache: data.sprache.present ? data.sprache.value : this.sprache,
      autoAnalyzeAfterImport: data.autoAnalyzeAfterImport.present
          ? data.autoAnalyzeAfterImport.value
          : this.autoAnalyzeAfterImport,
      watchedFolderPath: data.watchedFolderPath.present
          ? data.watchedFolderPath.value
          : this.watchedFolderPath,
      watchedFolderToken: data.watchedFolderToken.present
          ? data.watchedFolderToken.value
          : this.watchedFolderToken,
      faceSimilarityThreshold: data.faceSimilarityThreshold.present
          ? data.faceSimilarityThreshold.value
          : this.faceSimilarityThreshold,
      translateCaptions: data.translateCaptions.present
          ? data.translateCaptions.value
          : this.translateCaptions,
      translateSearchAndTags: data.translateSearchAndTags.present
          ? data.translateSearchAndTags.value
          : this.translateSearchAndTags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsData(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('sprache: $sprache, ')
          ..write('autoAnalyzeAfterImport: $autoAnalyzeAfterImport, ')
          ..write('watchedFolderPath: $watchedFolderPath, ')
          ..write('watchedFolderToken: $watchedFolderToken, ')
          ..write('faceSimilarityThreshold: $faceSimilarityThreshold, ')
          ..write('translateCaptions: $translateCaptions, ')
          ..write('translateSearchAndTags: $translateSearchAndTags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      themeMode,
      sprache,
      autoAnalyzeAfterImport,
      watchedFolderPath,
      watchedFolderToken,
      faceSimilarityThreshold,
      translateCaptions,
      translateSearchAndTags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsData &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.sprache == this.sprache &&
          other.autoAnalyzeAfterImport == this.autoAnalyzeAfterImport &&
          other.watchedFolderPath == this.watchedFolderPath &&
          other.watchedFolderToken == this.watchedFolderToken &&
          other.faceSimilarityThreshold == this.faceSimilarityThreshold &&
          other.translateCaptions == this.translateCaptions &&
          other.translateSearchAndTags == this.translateSearchAndTags);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsData> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<String> sprache;
  final Value<bool> autoAnalyzeAfterImport;
  final Value<String?> watchedFolderPath;
  final Value<String?> watchedFolderToken;
  final Value<double> faceSimilarityThreshold;
  final Value<bool> translateCaptions;
  final Value<bool> translateSearchAndTags;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.sprache = const Value.absent(),
    this.autoAnalyzeAfterImport = const Value.absent(),
    this.watchedFolderPath = const Value.absent(),
    this.watchedFolderToken = const Value.absent(),
    this.faceSimilarityThreshold = const Value.absent(),
    this.translateCaptions = const Value.absent(),
    this.translateSearchAndTags = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.sprache = const Value.absent(),
    this.autoAnalyzeAfterImport = const Value.absent(),
    this.watchedFolderPath = const Value.absent(),
    this.watchedFolderToken = const Value.absent(),
    this.faceSimilarityThreshold = const Value.absent(),
    this.translateCaptions = const Value.absent(),
    this.translateSearchAndTags = const Value.absent(),
  });
  static Insertable<AppSettingsData> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<String>? sprache,
    Expression<bool>? autoAnalyzeAfterImport,
    Expression<String>? watchedFolderPath,
    Expression<String>? watchedFolderToken,
    Expression<double>? faceSimilarityThreshold,
    Expression<bool>? translateCaptions,
    Expression<bool>? translateSearchAndTags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (sprache != null) 'sprache': sprache,
      if (autoAnalyzeAfterImport != null)
        'auto_analyze_after_import': autoAnalyzeAfterImport,
      if (watchedFolderPath != null) 'watched_folder_path': watchedFolderPath,
      if (watchedFolderToken != null)
        'watched_folder_token': watchedFolderToken,
      if (faceSimilarityThreshold != null)
        'face_similarity_threshold': faceSimilarityThreshold,
      if (translateCaptions != null) 'translate_captions': translateCaptions,
      if (translateSearchAndTags != null)
        'translate_search_and_tags': translateSearchAndTags,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? themeMode,
      Value<String>? sprache,
      Value<bool>? autoAnalyzeAfterImport,
      Value<String?>? watchedFolderPath,
      Value<String?>? watchedFolderToken,
      Value<double>? faceSimilarityThreshold,
      Value<bool>? translateCaptions,
      Value<bool>? translateSearchAndTags}) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      sprache: sprache ?? this.sprache,
      autoAnalyzeAfterImport:
          autoAnalyzeAfterImport ?? this.autoAnalyzeAfterImport,
      watchedFolderPath: watchedFolderPath ?? this.watchedFolderPath,
      watchedFolderToken: watchedFolderToken ?? this.watchedFolderToken,
      faceSimilarityThreshold:
          faceSimilarityThreshold ?? this.faceSimilarityThreshold,
      translateCaptions: translateCaptions ?? this.translateCaptions,
      translateSearchAndTags:
          translateSearchAndTags ?? this.translateSearchAndTags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (sprache.present) {
      map['sprache'] = Variable<String>(sprache.value);
    }
    if (autoAnalyzeAfterImport.present) {
      map['auto_analyze_after_import'] =
          Variable<bool>(autoAnalyzeAfterImport.value);
    }
    if (watchedFolderPath.present) {
      map['watched_folder_path'] = Variable<String>(watchedFolderPath.value);
    }
    if (watchedFolderToken.present) {
      map['watched_folder_token'] = Variable<String>(watchedFolderToken.value);
    }
    if (faceSimilarityThreshold.present) {
      map['face_similarity_threshold'] =
          Variable<double>(faceSimilarityThreshold.value);
    }
    if (translateCaptions.present) {
      map['translate_captions'] = Variable<bool>(translateCaptions.value);
    }
    if (translateSearchAndTags.present) {
      map['translate_search_and_tags'] =
          Variable<bool>(translateSearchAndTags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('sprache: $sprache, ')
          ..write('autoAnalyzeAfterImport: $autoAnalyzeAfterImport, ')
          ..write('watchedFolderPath: $watchedFolderPath, ')
          ..write('watchedFolderToken: $watchedFolderToken, ')
          ..write('faceSimilarityThreshold: $faceSimilarityThreshold, ')
          ..write('translateCaptions: $translateCaptions, ')
          ..write('translateSearchAndTags: $translateSearchAndTags')
          ..write(')'))
        .toString();
  }
}

class $AiTagVocabularyTable extends AiTagVocabulary
    with TableInfo<$AiTagVocabularyTable, AiTagVocabularyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiTagVocabularyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
      'term', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, term];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_tag_vocabulary';
  @override
  VerificationContext validateIntegrity(
      Insertable<AiTagVocabularyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('term')) {
      context.handle(
          _termMeta, term.isAcceptableOrUnknown(data['term']!, _termMeta));
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiTagVocabularyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiTagVocabularyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      term: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term'])!,
    );
  }

  @override
  $AiTagVocabularyTable createAlias(String alias) {
    return $AiTagVocabularyTable(attachedDatabase, alias);
  }
}

class AiTagVocabularyData extends DataClass
    implements Insertable<AiTagVocabularyData> {
  final int id;
  final String term;
  const AiTagVocabularyData({required this.id, required this.term});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['term'] = Variable<String>(term);
    return map;
  }

  AiTagVocabularyCompanion toCompanion(bool nullToAbsent) {
    return AiTagVocabularyCompanion(
      id: Value(id),
      term: Value(term),
    );
  }

  factory AiTagVocabularyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiTagVocabularyData(
      id: serializer.fromJson<int>(json['id']),
      term: serializer.fromJson<String>(json['term']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'term': serializer.toJson<String>(term),
    };
  }

  AiTagVocabularyData copyWith({int? id, String? term}) => AiTagVocabularyData(
        id: id ?? this.id,
        term: term ?? this.term,
      );
  AiTagVocabularyData copyWithCompanion(AiTagVocabularyCompanion data) {
    return AiTagVocabularyData(
      id: data.id.present ? data.id.value : this.id,
      term: data.term.present ? data.term.value : this.term,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiTagVocabularyData(')
          ..write('id: $id, ')
          ..write('term: $term')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, term);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiTagVocabularyData &&
          other.id == this.id &&
          other.term == this.term);
}

class AiTagVocabularyCompanion extends UpdateCompanion<AiTagVocabularyData> {
  final Value<int> id;
  final Value<String> term;
  const AiTagVocabularyCompanion({
    this.id = const Value.absent(),
    this.term = const Value.absent(),
  });
  AiTagVocabularyCompanion.insert({
    this.id = const Value.absent(),
    required String term,
  }) : term = Value(term);
  static Insertable<AiTagVocabularyData> custom({
    Expression<int>? id,
    Expression<String>? term,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (term != null) 'term': term,
    });
  }

  AiTagVocabularyCompanion copyWith({Value<int>? id, Value<String>? term}) {
    return AiTagVocabularyCompanion(
      id: id ?? this.id,
      term: term ?? this.term,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiTagVocabularyCompanion(')
          ..write('id: $id, ')
          ..write('term: $term')
          ..write(')'))
        .toString();
  }
}

class $AutomationRulesTable extends AutomationRules
    with TableInfo<$AutomationRulesTable, AutomationRuleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutomationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggerTypeMeta =
      const VerificationMeta('triggerType');
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
      'trigger_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _regionCenterLatMeta =
      const VerificationMeta('regionCenterLat');
  @override
  late final GeneratedColumn<double> regionCenterLat = GeneratedColumn<double>(
      'region_center_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _regionCenterLonMeta =
      const VerificationMeta('regionCenterLon');
  @override
  late final GeneratedColumn<double> regionCenterLon = GeneratedColumn<double>(
      'region_center_lon', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _regionRadiusKmMeta =
      const VerificationMeta('regionRadiusKm');
  @override
  late final GeneratedColumn<double> regionRadiusKm = GeneratedColumn<double>(
      'region_radius_km', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _aiTagTermMeta =
      const VerificationMeta('aiTagTerm');
  @override
  late final GeneratedColumn<String> aiTagTerm = GeneratedColumn<String>(
      'ai_tag_term', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateFromMeta =
      const VerificationMeta('dateFrom');
  @override
  late final GeneratedColumn<DateTime> dateFrom = GeneratedColumn<DateTime>(
      'date_from', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dateToMeta = const VerificationMeta('dateTo');
  @override
  late final GeneratedColumn<DateTime> dateTo = GeneratedColumn<DateTime>(
      'date_to', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _targetAlbumIdMeta =
      const VerificationMeta('targetAlbumId');
  @override
  late final GeneratedColumn<String> targetAlbumId = GeneratedColumn<String>(
      'target_album_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _autoFavoriteMeta =
      const VerificationMeta('autoFavorite');
  @override
  late final GeneratedColumn<bool> autoFavorite = GeneratedColumn<bool>(
      'auto_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        triggerType,
        regionCenterLat,
        regionCenterLon,
        regionRadiusKm,
        aiTagTerm,
        dateFrom,
        dateTo,
        targetAlbumId,
        autoFavorite
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'automation_rules';
  @override
  VerificationContext validateIntegrity(Insertable<AutomationRuleData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
          _triggerTypeMeta,
          triggerType.isAcceptableOrUnknown(
              data['trigger_type']!, _triggerTypeMeta));
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('region_center_lat')) {
      context.handle(
          _regionCenterLatMeta,
          regionCenterLat.isAcceptableOrUnknown(
              data['region_center_lat']!, _regionCenterLatMeta));
    }
    if (data.containsKey('region_center_lon')) {
      context.handle(
          _regionCenterLonMeta,
          regionCenterLon.isAcceptableOrUnknown(
              data['region_center_lon']!, _regionCenterLonMeta));
    }
    if (data.containsKey('region_radius_km')) {
      context.handle(
          _regionRadiusKmMeta,
          regionRadiusKm.isAcceptableOrUnknown(
              data['region_radius_km']!, _regionRadiusKmMeta));
    }
    if (data.containsKey('ai_tag_term')) {
      context.handle(
          _aiTagTermMeta,
          aiTagTerm.isAcceptableOrUnknown(
              data['ai_tag_term']!, _aiTagTermMeta));
    }
    if (data.containsKey('date_from')) {
      context.handle(_dateFromMeta,
          dateFrom.isAcceptableOrUnknown(data['date_from']!, _dateFromMeta));
    }
    if (data.containsKey('date_to')) {
      context.handle(_dateToMeta,
          dateTo.isAcceptableOrUnknown(data['date_to']!, _dateToMeta));
    }
    if (data.containsKey('target_album_id')) {
      context.handle(
          _targetAlbumIdMeta,
          targetAlbumId.isAcceptableOrUnknown(
              data['target_album_id']!, _targetAlbumIdMeta));
    }
    if (data.containsKey('auto_favorite')) {
      context.handle(
          _autoFavoriteMeta,
          autoFavorite.isAcceptableOrUnknown(
              data['auto_favorite']!, _autoFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AutomationRuleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutomationRuleData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      triggerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_type'])!,
      regionCenterLat: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}region_center_lat']),
      regionCenterLon: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}region_center_lon']),
      regionRadiusKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}region_radius_km']),
      aiTagTerm: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_tag_term']),
      dateFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_from']),
      dateTo: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_to']),
      targetAlbumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_album_id']),
      autoFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_favorite'])!,
    );
  }

  @override
  $AutomationRulesTable createAlias(String alias) {
    return $AutomationRulesTable(attachedDatabase, alias);
  }
}

class AutomationRuleData extends DataClass
    implements Insertable<AutomationRuleData> {
  final String id;
  final String name;
  final String triggerType;
  final double? regionCenterLat;
  final double? regionCenterLon;
  final double? regionRadiusKm;
  final String? aiTagTerm;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? targetAlbumId;
  final bool autoFavorite;
  const AutomationRuleData(
      {required this.id,
      required this.name,
      required this.triggerType,
      this.regionCenterLat,
      this.regionCenterLon,
      this.regionRadiusKm,
      this.aiTagTerm,
      this.dateFrom,
      this.dateTo,
      this.targetAlbumId,
      required this.autoFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['trigger_type'] = Variable<String>(triggerType);
    if (!nullToAbsent || regionCenterLat != null) {
      map['region_center_lat'] = Variable<double>(regionCenterLat);
    }
    if (!nullToAbsent || regionCenterLon != null) {
      map['region_center_lon'] = Variable<double>(regionCenterLon);
    }
    if (!nullToAbsent || regionRadiusKm != null) {
      map['region_radius_km'] = Variable<double>(regionRadiusKm);
    }
    if (!nullToAbsent || aiTagTerm != null) {
      map['ai_tag_term'] = Variable<String>(aiTagTerm);
    }
    if (!nullToAbsent || dateFrom != null) {
      map['date_from'] = Variable<DateTime>(dateFrom);
    }
    if (!nullToAbsent || dateTo != null) {
      map['date_to'] = Variable<DateTime>(dateTo);
    }
    if (!nullToAbsent || targetAlbumId != null) {
      map['target_album_id'] = Variable<String>(targetAlbumId);
    }
    map['auto_favorite'] = Variable<bool>(autoFavorite);
    return map;
  }

  AutomationRulesCompanion toCompanion(bool nullToAbsent) {
    return AutomationRulesCompanion(
      id: Value(id),
      name: Value(name),
      triggerType: Value(triggerType),
      regionCenterLat: regionCenterLat == null && nullToAbsent
          ? const Value.absent()
          : Value(regionCenterLat),
      regionCenterLon: regionCenterLon == null && nullToAbsent
          ? const Value.absent()
          : Value(regionCenterLon),
      regionRadiusKm: regionRadiusKm == null && nullToAbsent
          ? const Value.absent()
          : Value(regionRadiusKm),
      aiTagTerm: aiTagTerm == null && nullToAbsent
          ? const Value.absent()
          : Value(aiTagTerm),
      dateFrom: dateFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFrom),
      dateTo:
          dateTo == null && nullToAbsent ? const Value.absent() : Value(dateTo),
      targetAlbumId: targetAlbumId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAlbumId),
      autoFavorite: Value(autoFavorite),
    );
  }

  factory AutomationRuleData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutomationRuleData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      regionCenterLat: serializer.fromJson<double?>(json['regionCenterLat']),
      regionCenterLon: serializer.fromJson<double?>(json['regionCenterLon']),
      regionRadiusKm: serializer.fromJson<double?>(json['regionRadiusKm']),
      aiTagTerm: serializer.fromJson<String?>(json['aiTagTerm']),
      dateFrom: serializer.fromJson<DateTime?>(json['dateFrom']),
      dateTo: serializer.fromJson<DateTime?>(json['dateTo']),
      targetAlbumId: serializer.fromJson<String?>(json['targetAlbumId']),
      autoFavorite: serializer.fromJson<bool>(json['autoFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'triggerType': serializer.toJson<String>(triggerType),
      'regionCenterLat': serializer.toJson<double?>(regionCenterLat),
      'regionCenterLon': serializer.toJson<double?>(regionCenterLon),
      'regionRadiusKm': serializer.toJson<double?>(regionRadiusKm),
      'aiTagTerm': serializer.toJson<String?>(aiTagTerm),
      'dateFrom': serializer.toJson<DateTime?>(dateFrom),
      'dateTo': serializer.toJson<DateTime?>(dateTo),
      'targetAlbumId': serializer.toJson<String?>(targetAlbumId),
      'autoFavorite': serializer.toJson<bool>(autoFavorite),
    };
  }

  AutomationRuleData copyWith(
          {String? id,
          String? name,
          String? triggerType,
          Value<double?> regionCenterLat = const Value.absent(),
          Value<double?> regionCenterLon = const Value.absent(),
          Value<double?> regionRadiusKm = const Value.absent(),
          Value<String?> aiTagTerm = const Value.absent(),
          Value<DateTime?> dateFrom = const Value.absent(),
          Value<DateTime?> dateTo = const Value.absent(),
          Value<String?> targetAlbumId = const Value.absent(),
          bool? autoFavorite}) =>
      AutomationRuleData(
        id: id ?? this.id,
        name: name ?? this.name,
        triggerType: triggerType ?? this.triggerType,
        regionCenterLat: regionCenterLat.present
            ? regionCenterLat.value
            : this.regionCenterLat,
        regionCenterLon: regionCenterLon.present
            ? regionCenterLon.value
            : this.regionCenterLon,
        regionRadiusKm:
            regionRadiusKm.present ? regionRadiusKm.value : this.regionRadiusKm,
        aiTagTerm: aiTagTerm.present ? aiTagTerm.value : this.aiTagTerm,
        dateFrom: dateFrom.present ? dateFrom.value : this.dateFrom,
        dateTo: dateTo.present ? dateTo.value : this.dateTo,
        targetAlbumId:
            targetAlbumId.present ? targetAlbumId.value : this.targetAlbumId,
        autoFavorite: autoFavorite ?? this.autoFavorite,
      );
  AutomationRuleData copyWithCompanion(AutomationRulesCompanion data) {
    return AutomationRuleData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      triggerType:
          data.triggerType.present ? data.triggerType.value : this.triggerType,
      regionCenterLat: data.regionCenterLat.present
          ? data.regionCenterLat.value
          : this.regionCenterLat,
      regionCenterLon: data.regionCenterLon.present
          ? data.regionCenterLon.value
          : this.regionCenterLon,
      regionRadiusKm: data.regionRadiusKm.present
          ? data.regionRadiusKm.value
          : this.regionRadiusKm,
      aiTagTerm: data.aiTagTerm.present ? data.aiTagTerm.value : this.aiTagTerm,
      dateFrom: data.dateFrom.present ? data.dateFrom.value : this.dateFrom,
      dateTo: data.dateTo.present ? data.dateTo.value : this.dateTo,
      targetAlbumId: data.targetAlbumId.present
          ? data.targetAlbumId.value
          : this.targetAlbumId,
      autoFavorite: data.autoFavorite.present
          ? data.autoFavorite.value
          : this.autoFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutomationRuleData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('triggerType: $triggerType, ')
          ..write('regionCenterLat: $regionCenterLat, ')
          ..write('regionCenterLon: $regionCenterLon, ')
          ..write('regionRadiusKm: $regionRadiusKm, ')
          ..write('aiTagTerm: $aiTagTerm, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('targetAlbumId: $targetAlbumId, ')
          ..write('autoFavorite: $autoFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      triggerType,
      regionCenterLat,
      regionCenterLon,
      regionRadiusKm,
      aiTagTerm,
      dateFrom,
      dateTo,
      targetAlbumId,
      autoFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutomationRuleData &&
          other.id == this.id &&
          other.name == this.name &&
          other.triggerType == this.triggerType &&
          other.regionCenterLat == this.regionCenterLat &&
          other.regionCenterLon == this.regionCenterLon &&
          other.regionRadiusKm == this.regionRadiusKm &&
          other.aiTagTerm == this.aiTagTerm &&
          other.dateFrom == this.dateFrom &&
          other.dateTo == this.dateTo &&
          other.targetAlbumId == this.targetAlbumId &&
          other.autoFavorite == this.autoFavorite);
}

class AutomationRulesCompanion extends UpdateCompanion<AutomationRuleData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> triggerType;
  final Value<double?> regionCenterLat;
  final Value<double?> regionCenterLon;
  final Value<double?> regionRadiusKm;
  final Value<String?> aiTagTerm;
  final Value<DateTime?> dateFrom;
  final Value<DateTime?> dateTo;
  final Value<String?> targetAlbumId;
  final Value<bool> autoFavorite;
  final Value<int> rowid;
  const AutomationRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.regionCenterLat = const Value.absent(),
    this.regionCenterLon = const Value.absent(),
    this.regionRadiusKm = const Value.absent(),
    this.aiTagTerm = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.targetAlbumId = const Value.absent(),
    this.autoFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AutomationRulesCompanion.insert({
    required String id,
    required String name,
    required String triggerType,
    this.regionCenterLat = const Value.absent(),
    this.regionCenterLon = const Value.absent(),
    this.regionRadiusKm = const Value.absent(),
    this.aiTagTerm = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.targetAlbumId = const Value.absent(),
    this.autoFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        triggerType = Value(triggerType);
  static Insertable<AutomationRuleData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? triggerType,
    Expression<double>? regionCenterLat,
    Expression<double>? regionCenterLon,
    Expression<double>? regionRadiusKm,
    Expression<String>? aiTagTerm,
    Expression<DateTime>? dateFrom,
    Expression<DateTime>? dateTo,
    Expression<String>? targetAlbumId,
    Expression<bool>? autoFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (triggerType != null) 'trigger_type': triggerType,
      if (regionCenterLat != null) 'region_center_lat': regionCenterLat,
      if (regionCenterLon != null) 'region_center_lon': regionCenterLon,
      if (regionRadiusKm != null) 'region_radius_km': regionRadiusKm,
      if (aiTagTerm != null) 'ai_tag_term': aiTagTerm,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (targetAlbumId != null) 'target_album_id': targetAlbumId,
      if (autoFavorite != null) 'auto_favorite': autoFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AutomationRulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? triggerType,
      Value<double?>? regionCenterLat,
      Value<double?>? regionCenterLon,
      Value<double?>? regionRadiusKm,
      Value<String?>? aiTagTerm,
      Value<DateTime?>? dateFrom,
      Value<DateTime?>? dateTo,
      Value<String?>? targetAlbumId,
      Value<bool>? autoFavorite,
      Value<int>? rowid}) {
    return AutomationRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      triggerType: triggerType ?? this.triggerType,
      regionCenterLat: regionCenterLat ?? this.regionCenterLat,
      regionCenterLon: regionCenterLon ?? this.regionCenterLon,
      regionRadiusKm: regionRadiusKm ?? this.regionRadiusKm,
      aiTagTerm: aiTagTerm ?? this.aiTagTerm,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      targetAlbumId: targetAlbumId ?? this.targetAlbumId,
      autoFavorite: autoFavorite ?? this.autoFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (regionCenterLat.present) {
      map['region_center_lat'] = Variable<double>(regionCenterLat.value);
    }
    if (regionCenterLon.present) {
      map['region_center_lon'] = Variable<double>(regionCenterLon.value);
    }
    if (regionRadiusKm.present) {
      map['region_radius_km'] = Variable<double>(regionRadiusKm.value);
    }
    if (aiTagTerm.present) {
      map['ai_tag_term'] = Variable<String>(aiTagTerm.value);
    }
    if (dateFrom.present) {
      map['date_from'] = Variable<DateTime>(dateFrom.value);
    }
    if (dateTo.present) {
      map['date_to'] = Variable<DateTime>(dateTo.value);
    }
    if (targetAlbumId.present) {
      map['target_album_id'] = Variable<String>(targetAlbumId.value);
    }
    if (autoFavorite.present) {
      map['auto_favorite'] = Variable<bool>(autoFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutomationRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('triggerType: $triggerType, ')
          ..write('regionCenterLat: $regionCenterLat, ')
          ..write('regionCenterLon: $regionCenterLon, ')
          ..write('regionRadiusKm: $regionRadiusKm, ')
          ..write('aiTagTerm: $aiTagTerm, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('targetAlbumId: $targetAlbumId, ')
          ..write('autoFavorite: $autoFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AutomationRuleTagsTable extends AutomationRuleTags
    with TableInfo<$AutomationRuleTagsTable, AutomationRuleTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutomationRuleTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
      'rule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [ruleId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'automation_rule_tags';
  @override
  VerificationContext validateIntegrity(Insertable<AutomationRuleTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rule_id')) {
      context.handle(_ruleIdMeta,
          ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta));
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ruleId, tagId};
  @override
  AutomationRuleTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutomationRuleTag(
      ruleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $AutomationRuleTagsTable createAlias(String alias) {
    return $AutomationRuleTagsTable(attachedDatabase, alias);
  }
}

class AutomationRuleTag extends DataClass
    implements Insertable<AutomationRuleTag> {
  final String ruleId;
  final String tagId;
  const AutomationRuleTag({required this.ruleId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rule_id'] = Variable<String>(ruleId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  AutomationRuleTagsCompanion toCompanion(bool nullToAbsent) {
    return AutomationRuleTagsCompanion(
      ruleId: Value(ruleId),
      tagId: Value(tagId),
    );
  }

  factory AutomationRuleTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutomationRuleTag(
      ruleId: serializer.fromJson<String>(json['ruleId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ruleId': serializer.toJson<String>(ruleId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  AutomationRuleTag copyWith({String? ruleId, String? tagId}) =>
      AutomationRuleTag(
        ruleId: ruleId ?? this.ruleId,
        tagId: tagId ?? this.tagId,
      );
  AutomationRuleTag copyWithCompanion(AutomationRuleTagsCompanion data) {
    return AutomationRuleTag(
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutomationRuleTag(')
          ..write('ruleId: $ruleId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ruleId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutomationRuleTag &&
          other.ruleId == this.ruleId &&
          other.tagId == this.tagId);
}

class AutomationRuleTagsCompanion extends UpdateCompanion<AutomationRuleTag> {
  final Value<String> ruleId;
  final Value<String> tagId;
  final Value<int> rowid;
  const AutomationRuleTagsCompanion({
    this.ruleId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AutomationRuleTagsCompanion.insert({
    required String ruleId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : ruleId = Value(ruleId),
        tagId = Value(tagId);
  static Insertable<AutomationRuleTag> custom({
    Expression<String>? ruleId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ruleId != null) 'rule_id': ruleId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AutomationRuleTagsCompanion copyWith(
      {Value<String>? ruleId, Value<String>? tagId, Value<int>? rowid}) {
    return AutomationRuleTagsCompanion(
      ruleId: ruleId ?? this.ruleId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutomationRuleTagsCompanion(')
          ..write('ruleId: $ruleId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportPresetsTable extends ExportPresets
    with TableInfo<$ExportPresetsTable, ExportPresetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nachJpegMeta =
      const VerificationMeta('nachJpeg');
  @override
  late final GeneratedColumn<bool> nachJpeg = GeneratedColumn<bool>(
      'nach_jpeg', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("nach_jpeg" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _maxKanteMeta =
      const VerificationMeta('maxKante');
  @override
  late final GeneratedColumn<int> maxKante = GeneratedColumn<int>(
      'max_kante', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _qualitaetMeta =
      const VerificationMeta('qualitaet');
  @override
  late final GeneratedColumn<double> qualitaet = GeneratedColumn<double>(
      'qualitaet', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.9));
  static const VerificationMeta _namensmusterMeta =
      const VerificationMeta('namensmuster');
  @override
  late final GeneratedColumn<String> namensmuster = GeneratedColumn<String>(
      'namensmuster', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{name}'));
  static const VerificationMeta _xmpDanebenMeta =
      const VerificationMeta('xmpDaneben');
  @override
  late final GeneratedColumn<bool> xmpDaneben = GeneratedColumn<bool>(
      'xmp_daneben', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("xmp_daneben" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _erstelltAmMeta =
      const VerificationMeta('erstelltAm');
  @override
  late final GeneratedColumn<DateTime> erstelltAm = GeneratedColumn<DateTime>(
      'erstellt_am', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        nachJpeg,
        maxKante,
        qualitaet,
        namensmuster,
        xmpDaneben,
        erstelltAm
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_presets';
  @override
  VerificationContext validateIntegrity(Insertable<ExportPresetData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nach_jpeg')) {
      context.handle(_nachJpegMeta,
          nachJpeg.isAcceptableOrUnknown(data['nach_jpeg']!, _nachJpegMeta));
    }
    if (data.containsKey('max_kante')) {
      context.handle(_maxKanteMeta,
          maxKante.isAcceptableOrUnknown(data['max_kante']!, _maxKanteMeta));
    }
    if (data.containsKey('qualitaet')) {
      context.handle(_qualitaetMeta,
          qualitaet.isAcceptableOrUnknown(data['qualitaet']!, _qualitaetMeta));
    }
    if (data.containsKey('namensmuster')) {
      context.handle(
          _namensmusterMeta,
          namensmuster.isAcceptableOrUnknown(
              data['namensmuster']!, _namensmusterMeta));
    }
    if (data.containsKey('xmp_daneben')) {
      context.handle(
          _xmpDanebenMeta,
          xmpDaneben.isAcceptableOrUnknown(
              data['xmp_daneben']!, _xmpDanebenMeta));
    }
    if (data.containsKey('erstellt_am')) {
      context.handle(
          _erstelltAmMeta,
          erstelltAm.isAcceptableOrUnknown(
              data['erstellt_am']!, _erstelltAmMeta));
    } else if (isInserting) {
      context.missing(_erstelltAmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportPresetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportPresetData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nachJpeg: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}nach_jpeg'])!,
      maxKante: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_kante']),
      qualitaet: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}qualitaet'])!,
      namensmuster: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}namensmuster'])!,
      xmpDaneben: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}xmp_daneben'])!,
      erstelltAm: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}erstellt_am'])!,
    );
  }

  @override
  $ExportPresetsTable createAlias(String alias) {
    return $ExportPresetsTable(attachedDatabase, alias);
  }
}

class ExportPresetData extends DataClass
    implements Insertable<ExportPresetData> {
  final int id;

  /// Angezeigter Name. Eindeutig, damit die Auswahlliste eindeutig bleibt.
  final String name;
  final bool nachJpeg;

  /// Längere Bildkante in Pixeln; `null` = nicht begrenzen.
  final int? maxKante;

  /// JPEG-Qualität 0,1 … 1,0. Ohne [nachJpeg] ohne Bedeutung.
  final double qualitaet;

  /// Muster für den Dateinamen, siehe `export_naming.dart`.
  final String namensmuster;
  final bool xmpDaneben;
  final DateTime erstelltAm;
  const ExportPresetData(
      {required this.id,
      required this.name,
      required this.nachJpeg,
      this.maxKante,
      required this.qualitaet,
      required this.namensmuster,
      required this.xmpDaneben,
      required this.erstelltAm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['nach_jpeg'] = Variable<bool>(nachJpeg);
    if (!nullToAbsent || maxKante != null) {
      map['max_kante'] = Variable<int>(maxKante);
    }
    map['qualitaet'] = Variable<double>(qualitaet);
    map['namensmuster'] = Variable<String>(namensmuster);
    map['xmp_daneben'] = Variable<bool>(xmpDaneben);
    map['erstellt_am'] = Variable<DateTime>(erstelltAm);
    return map;
  }

  ExportPresetsCompanion toCompanion(bool nullToAbsent) {
    return ExportPresetsCompanion(
      id: Value(id),
      name: Value(name),
      nachJpeg: Value(nachJpeg),
      maxKante: maxKante == null && nullToAbsent
          ? const Value.absent()
          : Value(maxKante),
      qualitaet: Value(qualitaet),
      namensmuster: Value(namensmuster),
      xmpDaneben: Value(xmpDaneben),
      erstelltAm: Value(erstelltAm),
    );
  }

  factory ExportPresetData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportPresetData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nachJpeg: serializer.fromJson<bool>(json['nachJpeg']),
      maxKante: serializer.fromJson<int?>(json['maxKante']),
      qualitaet: serializer.fromJson<double>(json['qualitaet']),
      namensmuster: serializer.fromJson<String>(json['namensmuster']),
      xmpDaneben: serializer.fromJson<bool>(json['xmpDaneben']),
      erstelltAm: serializer.fromJson<DateTime>(json['erstelltAm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nachJpeg': serializer.toJson<bool>(nachJpeg),
      'maxKante': serializer.toJson<int?>(maxKante),
      'qualitaet': serializer.toJson<double>(qualitaet),
      'namensmuster': serializer.toJson<String>(namensmuster),
      'xmpDaneben': serializer.toJson<bool>(xmpDaneben),
      'erstelltAm': serializer.toJson<DateTime>(erstelltAm),
    };
  }

  ExportPresetData copyWith(
          {int? id,
          String? name,
          bool? nachJpeg,
          Value<int?> maxKante = const Value.absent(),
          double? qualitaet,
          String? namensmuster,
          bool? xmpDaneben,
          DateTime? erstelltAm}) =>
      ExportPresetData(
        id: id ?? this.id,
        name: name ?? this.name,
        nachJpeg: nachJpeg ?? this.nachJpeg,
        maxKante: maxKante.present ? maxKante.value : this.maxKante,
        qualitaet: qualitaet ?? this.qualitaet,
        namensmuster: namensmuster ?? this.namensmuster,
        xmpDaneben: xmpDaneben ?? this.xmpDaneben,
        erstelltAm: erstelltAm ?? this.erstelltAm,
      );
  ExportPresetData copyWithCompanion(ExportPresetsCompanion data) {
    return ExportPresetData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nachJpeg: data.nachJpeg.present ? data.nachJpeg.value : this.nachJpeg,
      maxKante: data.maxKante.present ? data.maxKante.value : this.maxKante,
      qualitaet: data.qualitaet.present ? data.qualitaet.value : this.qualitaet,
      namensmuster: data.namensmuster.present
          ? data.namensmuster.value
          : this.namensmuster,
      xmpDaneben:
          data.xmpDaneben.present ? data.xmpDaneben.value : this.xmpDaneben,
      erstelltAm:
          data.erstelltAm.present ? data.erstelltAm.value : this.erstelltAm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportPresetData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nachJpeg: $nachJpeg, ')
          ..write('maxKante: $maxKante, ')
          ..write('qualitaet: $qualitaet, ')
          ..write('namensmuster: $namensmuster, ')
          ..write('xmpDaneben: $xmpDaneben, ')
          ..write('erstelltAm: $erstelltAm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nachJpeg, maxKante, qualitaet,
      namensmuster, xmpDaneben, erstelltAm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportPresetData &&
          other.id == this.id &&
          other.name == this.name &&
          other.nachJpeg == this.nachJpeg &&
          other.maxKante == this.maxKante &&
          other.qualitaet == this.qualitaet &&
          other.namensmuster == this.namensmuster &&
          other.xmpDaneben == this.xmpDaneben &&
          other.erstelltAm == this.erstelltAm);
}

class ExportPresetsCompanion extends UpdateCompanion<ExportPresetData> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> nachJpeg;
  final Value<int?> maxKante;
  final Value<double> qualitaet;
  final Value<String> namensmuster;
  final Value<bool> xmpDaneben;
  final Value<DateTime> erstelltAm;
  const ExportPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nachJpeg = const Value.absent(),
    this.maxKante = const Value.absent(),
    this.qualitaet = const Value.absent(),
    this.namensmuster = const Value.absent(),
    this.xmpDaneben = const Value.absent(),
    this.erstelltAm = const Value.absent(),
  });
  ExportPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nachJpeg = const Value.absent(),
    this.maxKante = const Value.absent(),
    this.qualitaet = const Value.absent(),
    this.namensmuster = const Value.absent(),
    this.xmpDaneben = const Value.absent(),
    required DateTime erstelltAm,
  })  : name = Value(name),
        erstelltAm = Value(erstelltAm);
  static Insertable<ExportPresetData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? nachJpeg,
    Expression<int>? maxKante,
    Expression<double>? qualitaet,
    Expression<String>? namensmuster,
    Expression<bool>? xmpDaneben,
    Expression<DateTime>? erstelltAm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nachJpeg != null) 'nach_jpeg': nachJpeg,
      if (maxKante != null) 'max_kante': maxKante,
      if (qualitaet != null) 'qualitaet': qualitaet,
      if (namensmuster != null) 'namensmuster': namensmuster,
      if (xmpDaneben != null) 'xmp_daneben': xmpDaneben,
      if (erstelltAm != null) 'erstellt_am': erstelltAm,
    });
  }

  ExportPresetsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<bool>? nachJpeg,
      Value<int?>? maxKante,
      Value<double>? qualitaet,
      Value<String>? namensmuster,
      Value<bool>? xmpDaneben,
      Value<DateTime>? erstelltAm}) {
    return ExportPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nachJpeg: nachJpeg ?? this.nachJpeg,
      maxKante: maxKante ?? this.maxKante,
      qualitaet: qualitaet ?? this.qualitaet,
      namensmuster: namensmuster ?? this.namensmuster,
      xmpDaneben: xmpDaneben ?? this.xmpDaneben,
      erstelltAm: erstelltAm ?? this.erstelltAm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nachJpeg.present) {
      map['nach_jpeg'] = Variable<bool>(nachJpeg.value);
    }
    if (maxKante.present) {
      map['max_kante'] = Variable<int>(maxKante.value);
    }
    if (qualitaet.present) {
      map['qualitaet'] = Variable<double>(qualitaet.value);
    }
    if (namensmuster.present) {
      map['namensmuster'] = Variable<String>(namensmuster.value);
    }
    if (xmpDaneben.present) {
      map['xmp_daneben'] = Variable<bool>(xmpDaneben.value);
    }
    if (erstelltAm.present) {
      map['erstellt_am'] = Variable<DateTime>(erstelltAm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nachJpeg: $nachJpeg, ')
          ..write('maxKante: $maxKante, ')
          ..write('qualitaet: $qualitaet, ')
          ..write('namensmuster: $namensmuster, ')
          ..write('xmpDaneben: $xmpDaneben, ')
          ..write('erstelltAm: $erstelltAm')
          ..write(')'))
        .toString();
  }
}

class $PersonBeziehungenTable extends PersonBeziehungen
    with TableInfo<$PersonBeziehungenTable, PersonBeziehungenData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonBeziehungenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _andereIdMeta =
      const VerificationMeta('andereId');
  @override
  late final GeneratedColumn<String> andereId = GeneratedColumn<String>(
      'andere_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
      'art', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [personId, andereId, art];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_beziehungen';
  @override
  VerificationContext validateIntegrity(
      Insertable<PersonBeziehungenData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('andere_id')) {
      context.handle(_andereIdMeta,
          andereId.isAcceptableOrUnknown(data['andere_id']!, _andereIdMeta));
    } else if (isInserting) {
      context.missing(_andereIdMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art']!, _artMeta));
    } else if (isInserting) {
      context.missing(_artMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {personId, andereId, art};
  @override
  PersonBeziehungenData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonBeziehungenData(
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      andereId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}andere_id'])!,
      art: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}art'])!,
    );
  }

  @override
  $PersonBeziehungenTable createAlias(String alias) {
    return $PersonBeziehungenTable(attachedDatabase, alias);
  }
}

class PersonBeziehungenData extends DataClass
    implements Insertable<PersonBeziehungenData> {
  final String personId;
  final String andereId;
  final String art;
  const PersonBeziehungenData(
      {required this.personId, required this.andereId, required this.art});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['person_id'] = Variable<String>(personId);
    map['andere_id'] = Variable<String>(andereId);
    map['art'] = Variable<String>(art);
    return map;
  }

  PersonBeziehungenCompanion toCompanion(bool nullToAbsent) {
    return PersonBeziehungenCompanion(
      personId: Value(personId),
      andereId: Value(andereId),
      art: Value(art),
    );
  }

  factory PersonBeziehungenData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonBeziehungenData(
      personId: serializer.fromJson<String>(json['personId']),
      andereId: serializer.fromJson<String>(json['andereId']),
      art: serializer.fromJson<String>(json['art']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'personId': serializer.toJson<String>(personId),
      'andereId': serializer.toJson<String>(andereId),
      'art': serializer.toJson<String>(art),
    };
  }

  PersonBeziehungenData copyWith(
          {String? personId, String? andereId, String? art}) =>
      PersonBeziehungenData(
        personId: personId ?? this.personId,
        andereId: andereId ?? this.andereId,
        art: art ?? this.art,
      );
  PersonBeziehungenData copyWithCompanion(PersonBeziehungenCompanion data) {
    return PersonBeziehungenData(
      personId: data.personId.present ? data.personId.value : this.personId,
      andereId: data.andereId.present ? data.andereId.value : this.andereId,
      art: data.art.present ? data.art.value : this.art,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonBeziehungenData(')
          ..write('personId: $personId, ')
          ..write('andereId: $andereId, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(personId, andereId, art);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonBeziehungenData &&
          other.personId == this.personId &&
          other.andereId == this.andereId &&
          other.art == this.art);
}

class PersonBeziehungenCompanion
    extends UpdateCompanion<PersonBeziehungenData> {
  final Value<String> personId;
  final Value<String> andereId;
  final Value<String> art;
  final Value<int> rowid;
  const PersonBeziehungenCompanion({
    this.personId = const Value.absent(),
    this.andereId = const Value.absent(),
    this.art = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonBeziehungenCompanion.insert({
    required String personId,
    required String andereId,
    required String art,
    this.rowid = const Value.absent(),
  })  : personId = Value(personId),
        andereId = Value(andereId),
        art = Value(art);
  static Insertable<PersonBeziehungenData> custom({
    Expression<String>? personId,
    Expression<String>? andereId,
    Expression<String>? art,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (personId != null) 'person_id': personId,
      if (andereId != null) 'andere_id': andereId,
      if (art != null) 'art': art,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonBeziehungenCompanion copyWith(
      {Value<String>? personId,
      Value<String>? andereId,
      Value<String>? art,
      Value<int>? rowid}) {
    return PersonBeziehungenCompanion(
      personId: personId ?? this.personId,
      andereId: andereId ?? this.andereId,
      art: art ?? this.art,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (andereId.present) {
      map['andere_id'] = Variable<String>(andereId.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonBeziehungenCompanion(')
          ..write('personId: $personId, ')
          ..write('andereId: $andereId, ')
          ..write('art: $art, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LebensereignisseTable extends Lebensereignisse
    with TableInfo<$LebensereignisseTable, LebensereignisseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LebensereignisseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
      'art', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  @override
  late final GeneratedColumn<DateTime> datum = GeneratedColumn<DateTime>(
      'datum', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _ortMeta = const VerificationMeta('ort');
  @override
  late final GeneratedColumn<String> ort = GeneratedColumn<String>(
      'ort', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notizMeta = const VerificationMeta('notiz');
  @override
  late final GeneratedColumn<String> notiz = GeneratedColumn<String>(
      'notiz', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, personId, art, datum, ort, notiz];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lebensereignisse';
  @override
  VerificationContext validateIntegrity(
      Insertable<LebensereignisseData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art']!, _artMeta));
    } else if (isInserting) {
      context.missing(_artMeta);
    }
    if (data.containsKey('datum')) {
      context.handle(
          _datumMeta, datum.isAcceptableOrUnknown(data['datum']!, _datumMeta));
    }
    if (data.containsKey('ort')) {
      context.handle(
          _ortMeta, ort.isAcceptableOrUnknown(data['ort']!, _ortMeta));
    }
    if (data.containsKey('notiz')) {
      context.handle(
          _notizMeta, notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LebensereignisseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LebensereignisseData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      art: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}art'])!,
      datum: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datum']),
      ort: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ort']),
      notiz: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notiz']),
    );
  }

  @override
  $LebensereignisseTable createAlias(String alias) {
    return $LebensereignisseTable(attachedDatabase, alias);
  }
}

class LebensereignisseData extends DataClass
    implements Insertable<LebensereignisseData> {
  final String id;
  final String personId;

  /// Siehe `Ereignisart` in services/lebenslauf.dart.
  final String art;

  /// Freiwillig – manchmal weiß man nur, *dass* etwas war.
  final DateTime? datum;
  final String? ort;
  final String? notiz;
  const LebensereignisseData(
      {required this.id,
      required this.personId,
      required this.art,
      this.datum,
      this.ort,
      this.notiz});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['art'] = Variable<String>(art);
    if (!nullToAbsent || datum != null) {
      map['datum'] = Variable<DateTime>(datum);
    }
    if (!nullToAbsent || ort != null) {
      map['ort'] = Variable<String>(ort);
    }
    if (!nullToAbsent || notiz != null) {
      map['notiz'] = Variable<String>(notiz);
    }
    return map;
  }

  LebensereignisseCompanion toCompanion(bool nullToAbsent) {
    return LebensereignisseCompanion(
      id: Value(id),
      personId: Value(personId),
      art: Value(art),
      datum:
          datum == null && nullToAbsent ? const Value.absent() : Value(datum),
      ort: ort == null && nullToAbsent ? const Value.absent() : Value(ort),
      notiz:
          notiz == null && nullToAbsent ? const Value.absent() : Value(notiz),
    );
  }

  factory LebensereignisseData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LebensereignisseData(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      art: serializer.fromJson<String>(json['art']),
      datum: serializer.fromJson<DateTime?>(json['datum']),
      ort: serializer.fromJson<String?>(json['ort']),
      notiz: serializer.fromJson<String?>(json['notiz']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'art': serializer.toJson<String>(art),
      'datum': serializer.toJson<DateTime?>(datum),
      'ort': serializer.toJson<String?>(ort),
      'notiz': serializer.toJson<String?>(notiz),
    };
  }

  LebensereignisseData copyWith(
          {String? id,
          String? personId,
          String? art,
          Value<DateTime?> datum = const Value.absent(),
          Value<String?> ort = const Value.absent(),
          Value<String?> notiz = const Value.absent()}) =>
      LebensereignisseData(
        id: id ?? this.id,
        personId: personId ?? this.personId,
        art: art ?? this.art,
        datum: datum.present ? datum.value : this.datum,
        ort: ort.present ? ort.value : this.ort,
        notiz: notiz.present ? notiz.value : this.notiz,
      );
  LebensereignisseData copyWithCompanion(LebensereignisseCompanion data) {
    return LebensereignisseData(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      art: data.art.present ? data.art.value : this.art,
      datum: data.datum.present ? data.datum.value : this.datum,
      ort: data.ort.present ? data.ort.value : this.ort,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LebensereignisseData(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('art: $art, ')
          ..write('datum: $datum, ')
          ..write('ort: $ort, ')
          ..write('notiz: $notiz')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, personId, art, datum, ort, notiz);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LebensereignisseData &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.art == this.art &&
          other.datum == this.datum &&
          other.ort == this.ort &&
          other.notiz == this.notiz);
}

class LebensereignisseCompanion extends UpdateCompanion<LebensereignisseData> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> art;
  final Value<DateTime?> datum;
  final Value<String?> ort;
  final Value<String?> notiz;
  final Value<int> rowid;
  const LebensereignisseCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.art = const Value.absent(),
    this.datum = const Value.absent(),
    this.ort = const Value.absent(),
    this.notiz = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LebensereignisseCompanion.insert({
    required String id,
    required String personId,
    required String art,
    this.datum = const Value.absent(),
    this.ort = const Value.absent(),
    this.notiz = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        personId = Value(personId),
        art = Value(art);
  static Insertable<LebensereignisseData> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? art,
    Expression<DateTime>? datum,
    Expression<String>? ort,
    Expression<String>? notiz,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (art != null) 'art': art,
      if (datum != null) 'datum': datum,
      if (ort != null) 'ort': ort,
      if (notiz != null) 'notiz': notiz,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LebensereignisseCompanion copyWith(
      {Value<String>? id,
      Value<String>? personId,
      Value<String>? art,
      Value<DateTime?>? datum,
      Value<String?>? ort,
      Value<String?>? notiz,
      Value<int>? rowid}) {
    return LebensereignisseCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      art: art ?? this.art,
      datum: datum ?? this.datum,
      ort: ort ?? this.ort,
      notiz: notiz ?? this.notiz,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (datum.present) {
      map['datum'] = Variable<DateTime>(datum.value);
    }
    if (ort.present) {
      map['ort'] = Variable<String>(ort.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LebensereignisseCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('art: $art, ')
          ..write('datum: $datum, ')
          ..write('ort: $ort, ')
          ..write('notiz: $notiz, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $AlbumAssetsTable albumAssets = $AlbumAssetsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $AssetTagsTable assetTags = $AssetTagsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $FacesTable faces = $FacesTable(this);
  late final $FaceMatchFeedbackTable faceMatchFeedback =
      $FaceMatchFeedbackTable(this);
  late final $ImageEmbeddingsTable imageEmbeddings =
      $ImageEmbeddingsTable(this);
  late final $BackupRecordsTable backupRecords = $BackupRecordsTable(this);
  late final $PrivacySettingsTable privacySettings =
      $PrivacySettingsTable(this);
  late final $BackupSettingsTable backupSettings = $BackupSettingsTable(this);
  late final $SavedSearchesTable savedSearches = $SavedSearchesTable(this);
  late final $TrashSettingsTable trashSettings = $TrashSettingsTable(this);
  late final $DuplikatAusnahmenTable duplikatAusnahmen =
      $DuplikatAusnahmenTable(this);
  late final $CameraPresetsTable cameraPresets = $CameraPresetsTable(this);
  late final $CameraPresetTagsTable cameraPresetTags =
      $CameraPresetTagsTable(this);
  late final $DevelopSettingsTable developSettings =
      $DevelopSettingsTable(this);
  late final $DevelopHistoryTable developHistory = $DevelopHistoryTable(this);
  late final $VideoTrimsTable videoTrims = $VideoTrimsTable(this);
  late final $DevelopMasksTable developMasks = $DevelopMasksTable(this);
  late final $RestoreJobsTable restoreJobs = $RestoreJobsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $AiTagVocabularyTable aiTagVocabulary =
      $AiTagVocabularyTable(this);
  late final $AutomationRulesTable automationRules =
      $AutomationRulesTable(this);
  late final $AutomationRuleTagsTable automationRuleTags =
      $AutomationRuleTagsTable(this);
  late final $ExportPresetsTable exportPresets = $ExportPresetsTable(this);
  late final $PersonBeziehungenTable personBeziehungen =
      $PersonBeziehungenTable(this);
  late final $LebensereignisseTable lebensereignisse =
      $LebensereignisseTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        assets,
        albums,
        albumAssets,
        tags,
        assetTags,
        people,
        faces,
        faceMatchFeedback,
        imageEmbeddings,
        backupRecords,
        privacySettings,
        backupSettings,
        savedSearches,
        trashSettings,
        duplikatAusnahmen,
        cameraPresets,
        cameraPresetTags,
        developSettings,
        developHistory,
        videoTrims,
        developMasks,
        restoreJobs,
        appSettings,
        aiTagVocabulary,
        automationRules,
        automationRuleTags,
        exportPresets,
        personBeziehungen,
        lebensereignisse
      ];
}

typedef $$AssetsTableCreateCompanionBuilder = AssetsCompanion Function({
  required String id,
  required String originalFileName,
  required String relativePath,
  Value<String?> thumbnailRelativePath,
  Value<String?> previewRelativePath,
  Value<String?> developedRelativePath,
  Value<String?> trimmedRelativePath,
  Value<String?> restoredRelativePath,
  required String checksum,
  required String type,
  required DateTime fileCreatedAt,
  required DateTime importedAt,
  Value<bool> isFavorite,
  Value<bool> isTrashed,
  Value<DateTime?> trashedAt,
  Value<bool> isLocked,
  Value<String?> description,
  Value<int?> widthPx,
  Value<int?> heightPx,
  Value<double?> durationSeconds,
  Value<int> fileSizeBytes,
  Value<bool> backedUp,
  Value<bool> autoBackedUp,
  Value<bool> facesScanned,
  Value<String?> linkedAssetId,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> cameraMake,
  Value<String?> cameraModel,
  Value<String?> lensModel,
  Value<double?> focalLengthMm,
  Value<double?> fNumber,
  Value<int?> iso,
  Value<double?> exposureTimeSeconds,
  Value<double?> exposureBiasEv,
  Value<double?> focalLength35mm,
  Value<String?> locationCountry,
  Value<String?> locationState,
  Value<String?> locationCity,
  Value<int> rating,
  Value<String?> colorLabel,
  Value<String?> ocrText,
  Value<bool> ocrScanned,
  Value<String?> aiCaption,
  Value<String?> aiCaptionDe,
  Value<bool> aiCaptionScanned,
  Value<bool> aiCaptionEdited,
  Value<bool> aiTagsScanned,
  Value<double?> sharpnessScore,
  Value<String?> stackId,
  Value<bool> isStackCover,
  Value<int?> stackSize,
  Value<int> rowid,
});
typedef $$AssetsTableUpdateCompanionBuilder = AssetsCompanion Function({
  Value<String> id,
  Value<String> originalFileName,
  Value<String> relativePath,
  Value<String?> thumbnailRelativePath,
  Value<String?> previewRelativePath,
  Value<String?> developedRelativePath,
  Value<String?> trimmedRelativePath,
  Value<String?> restoredRelativePath,
  Value<String> checksum,
  Value<String> type,
  Value<DateTime> fileCreatedAt,
  Value<DateTime> importedAt,
  Value<bool> isFavorite,
  Value<bool> isTrashed,
  Value<DateTime?> trashedAt,
  Value<bool> isLocked,
  Value<String?> description,
  Value<int?> widthPx,
  Value<int?> heightPx,
  Value<double?> durationSeconds,
  Value<int> fileSizeBytes,
  Value<bool> backedUp,
  Value<bool> autoBackedUp,
  Value<bool> facesScanned,
  Value<String?> linkedAssetId,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> cameraMake,
  Value<String?> cameraModel,
  Value<String?> lensModel,
  Value<double?> focalLengthMm,
  Value<double?> fNumber,
  Value<int?> iso,
  Value<double?> exposureTimeSeconds,
  Value<double?> exposureBiasEv,
  Value<double?> focalLength35mm,
  Value<String?> locationCountry,
  Value<String?> locationState,
  Value<String?> locationCity,
  Value<int> rating,
  Value<String?> colorLabel,
  Value<String?> ocrText,
  Value<bool> ocrScanned,
  Value<String?> aiCaption,
  Value<String?> aiCaptionDe,
  Value<bool> aiCaptionScanned,
  Value<bool> aiCaptionEdited,
  Value<bool> aiTagsScanned,
  Value<double?> sharpnessScore,
  Value<String?> stackId,
  Value<bool> isStackCover,
  Value<int?> stackSize,
  Value<int> rowid,
});

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailRelativePath => $composableBuilder(
      column: $table.thumbnailRelativePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewRelativePath => $composableBuilder(
      column: $table.previewRelativePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get developedRelativePath => $composableBuilder(
      column: $table.developedRelativePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trimmedRelativePath => $composableBuilder(
      column: $table.trimmedRelativePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get restoredRelativePath => $composableBuilder(
      column: $table.restoredRelativePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fileCreatedAt => $composableBuilder(
      column: $table.fileCreatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTrashed => $composableBuilder(
      column: $table.isTrashed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get trashedAt => $composableBuilder(
      column: $table.trashedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get widthPx => $composableBuilder(
      column: $table.widthPx, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get heightPx => $composableBuilder(
      column: $table.heightPx, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get backedUp => $composableBuilder(
      column: $table.backedUp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoBackedUp => $composableBuilder(
      column: $table.autoBackedUp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get facesScanned => $composableBuilder(
      column: $table.facesScanned, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedAssetId => $composableBuilder(
      column: $table.linkedAssetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cameraMake => $composableBuilder(
      column: $table.cameraMake, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cameraModel => $composableBuilder(
      column: $table.cameraModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lensModel => $composableBuilder(
      column: $table.lensModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get focalLengthMm => $composableBuilder(
      column: $table.focalLengthMm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fNumber => $composableBuilder(
      column: $table.fNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iso => $composableBuilder(
      column: $table.iso, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exposureTimeSeconds => $composableBuilder(
      column: $table.exposureTimeSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exposureBiasEv => $composableBuilder(
      column: $table.exposureBiasEv,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get focalLength35mm => $composableBuilder(
      column: $table.focalLength35mm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationCountry => $composableBuilder(
      column: $table.locationCountry,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationState => $composableBuilder(
      column: $table.locationState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationCity => $composableBuilder(
      column: $table.locationCity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorLabel => $composableBuilder(
      column: $table.colorLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ocrText => $composableBuilder(
      column: $table.ocrText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ocrScanned => $composableBuilder(
      column: $table.ocrScanned, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiCaption => $composableBuilder(
      column: $table.aiCaption, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiCaptionDe => $composableBuilder(
      column: $table.aiCaptionDe, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get aiCaptionScanned => $composableBuilder(
      column: $table.aiCaptionScanned,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get aiCaptionEdited => $composableBuilder(
      column: $table.aiCaptionEdited,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get aiTagsScanned => $composableBuilder(
      column: $table.aiTagsScanned, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sharpnessScore => $composableBuilder(
      column: $table.sharpnessScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stackId => $composableBuilder(
      column: $table.stackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isStackCover => $composableBuilder(
      column: $table.isStackCover, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stackSize => $composableBuilder(
      column: $table.stackSize, builder: (column) => ColumnFilters(column));
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relativePath => $composableBuilder(
      column: $table.relativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailRelativePath => $composableBuilder(
      column: $table.thumbnailRelativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewRelativePath => $composableBuilder(
      column: $table.previewRelativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get developedRelativePath => $composableBuilder(
      column: $table.developedRelativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trimmedRelativePath => $composableBuilder(
      column: $table.trimmedRelativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get restoredRelativePath => $composableBuilder(
      column: $table.restoredRelativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fileCreatedAt => $composableBuilder(
      column: $table.fileCreatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTrashed => $composableBuilder(
      column: $table.isTrashed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get trashedAt => $composableBuilder(
      column: $table.trashedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get widthPx => $composableBuilder(
      column: $table.widthPx, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get heightPx => $composableBuilder(
      column: $table.heightPx, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get backedUp => $composableBuilder(
      column: $table.backedUp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoBackedUp => $composableBuilder(
      column: $table.autoBackedUp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get facesScanned => $composableBuilder(
      column: $table.facesScanned,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedAssetId => $composableBuilder(
      column: $table.linkedAssetId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cameraMake => $composableBuilder(
      column: $table.cameraMake, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cameraModel => $composableBuilder(
      column: $table.cameraModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lensModel => $composableBuilder(
      column: $table.lensModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get focalLengthMm => $composableBuilder(
      column: $table.focalLengthMm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fNumber => $composableBuilder(
      column: $table.fNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iso => $composableBuilder(
      column: $table.iso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exposureTimeSeconds => $composableBuilder(
      column: $table.exposureTimeSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exposureBiasEv => $composableBuilder(
      column: $table.exposureBiasEv,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get focalLength35mm => $composableBuilder(
      column: $table.focalLength35mm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationCountry => $composableBuilder(
      column: $table.locationCountry,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationState => $composableBuilder(
      column: $table.locationState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationCity => $composableBuilder(
      column: $table.locationCity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorLabel => $composableBuilder(
      column: $table.colorLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ocrText => $composableBuilder(
      column: $table.ocrText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ocrScanned => $composableBuilder(
      column: $table.ocrScanned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiCaption => $composableBuilder(
      column: $table.aiCaption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiCaptionDe => $composableBuilder(
      column: $table.aiCaptionDe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get aiCaptionScanned => $composableBuilder(
      column: $table.aiCaptionScanned,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get aiCaptionEdited => $composableBuilder(
      column: $table.aiCaptionEdited,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get aiTagsScanned => $composableBuilder(
      column: $table.aiTagsScanned,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sharpnessScore => $composableBuilder(
      column: $table.sharpnessScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stackId => $composableBuilder(
      column: $table.stackId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isStackCover => $composableBuilder(
      column: $table.isStackCover,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stackSize => $composableBuilder(
      column: $table.stackSize, builder: (column) => ColumnOrderings(column));
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailRelativePath => $composableBuilder(
      column: $table.thumbnailRelativePath, builder: (column) => column);

  GeneratedColumn<String> get previewRelativePath => $composableBuilder(
      column: $table.previewRelativePath, builder: (column) => column);

  GeneratedColumn<String> get developedRelativePath => $composableBuilder(
      column: $table.developedRelativePath, builder: (column) => column);

  GeneratedColumn<String> get trimmedRelativePath => $composableBuilder(
      column: $table.trimmedRelativePath, builder: (column) => column);

  GeneratedColumn<String> get restoredRelativePath => $composableBuilder(
      column: $table.restoredRelativePath, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get fileCreatedAt => $composableBuilder(
      column: $table.fileCreatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isTrashed =>
      $composableBuilder(column: $table.isTrashed, builder: (column) => column);

  GeneratedColumn<DateTime> get trashedAt =>
      $composableBuilder(column: $table.trashedAt, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get widthPx =>
      $composableBuilder(column: $table.widthPx, builder: (column) => column);

  GeneratedColumn<int> get heightPx =>
      $composableBuilder(column: $table.heightPx, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get backedUp =>
      $composableBuilder(column: $table.backedUp, builder: (column) => column);

  GeneratedColumn<bool> get autoBackedUp => $composableBuilder(
      column: $table.autoBackedUp, builder: (column) => column);

  GeneratedColumn<bool> get facesScanned => $composableBuilder(
      column: $table.facesScanned, builder: (column) => column);

  GeneratedColumn<String> get linkedAssetId => $composableBuilder(
      column: $table.linkedAssetId, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get cameraMake => $composableBuilder(
      column: $table.cameraMake, builder: (column) => column);

  GeneratedColumn<String> get cameraModel => $composableBuilder(
      column: $table.cameraModel, builder: (column) => column);

  GeneratedColumn<String> get lensModel =>
      $composableBuilder(column: $table.lensModel, builder: (column) => column);

  GeneratedColumn<double> get focalLengthMm => $composableBuilder(
      column: $table.focalLengthMm, builder: (column) => column);

  GeneratedColumn<double> get fNumber =>
      $composableBuilder(column: $table.fNumber, builder: (column) => column);

  GeneratedColumn<int> get iso =>
      $composableBuilder(column: $table.iso, builder: (column) => column);

  GeneratedColumn<double> get exposureTimeSeconds => $composableBuilder(
      column: $table.exposureTimeSeconds, builder: (column) => column);

  GeneratedColumn<double> get exposureBiasEv => $composableBuilder(
      column: $table.exposureBiasEv, builder: (column) => column);

  GeneratedColumn<double> get focalLength35mm => $composableBuilder(
      column: $table.focalLength35mm, builder: (column) => column);

  GeneratedColumn<String> get locationCountry => $composableBuilder(
      column: $table.locationCountry, builder: (column) => column);

  GeneratedColumn<String> get locationState => $composableBuilder(
      column: $table.locationState, builder: (column) => column);

  GeneratedColumn<String> get locationCity => $composableBuilder(
      column: $table.locationCity, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get colorLabel => $composableBuilder(
      column: $table.colorLabel, builder: (column) => column);

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<bool> get ocrScanned => $composableBuilder(
      column: $table.ocrScanned, builder: (column) => column);

  GeneratedColumn<String> get aiCaption =>
      $composableBuilder(column: $table.aiCaption, builder: (column) => column);

  GeneratedColumn<String> get aiCaptionDe => $composableBuilder(
      column: $table.aiCaptionDe, builder: (column) => column);

  GeneratedColumn<bool> get aiCaptionScanned => $composableBuilder(
      column: $table.aiCaptionScanned, builder: (column) => column);

  GeneratedColumn<bool> get aiCaptionEdited => $composableBuilder(
      column: $table.aiCaptionEdited, builder: (column) => column);

  GeneratedColumn<bool> get aiTagsScanned => $composableBuilder(
      column: $table.aiTagsScanned, builder: (column) => column);

  GeneratedColumn<double> get sharpnessScore => $composableBuilder(
      column: $table.sharpnessScore, builder: (column) => column);

  GeneratedColumn<String> get stackId =>
      $composableBuilder(column: $table.stackId, builder: (column) => column);

  GeneratedColumn<bool> get isStackCover => $composableBuilder(
      column: $table.isStackCover, builder: (column) => column);

  GeneratedColumn<int> get stackSize =>
      $composableBuilder(column: $table.stackSize, builder: (column) => column);
}

class $$AssetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssetsTable,
    AssetData,
    $$AssetsTableFilterComposer,
    $$AssetsTableOrderingComposer,
    $$AssetsTableAnnotationComposer,
    $$AssetsTableCreateCompanionBuilder,
    $$AssetsTableUpdateCompanionBuilder,
    (AssetData, BaseReferences<_$AppDatabase, $AssetsTable, AssetData>),
    AssetData,
    PrefetchHooks Function()> {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> originalFileName = const Value.absent(),
            Value<String> relativePath = const Value.absent(),
            Value<String?> thumbnailRelativePath = const Value.absent(),
            Value<String?> previewRelativePath = const Value.absent(),
            Value<String?> developedRelativePath = const Value.absent(),
            Value<String?> trimmedRelativePath = const Value.absent(),
            Value<String?> restoredRelativePath = const Value.absent(),
            Value<String> checksum = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> fileCreatedAt = const Value.absent(),
            Value<DateTime> importedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isTrashed = const Value.absent(),
            Value<DateTime?> trashedAt = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int?> widthPx = const Value.absent(),
            Value<int?> heightPx = const Value.absent(),
            Value<double?> durationSeconds = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<bool> backedUp = const Value.absent(),
            Value<bool> autoBackedUp = const Value.absent(),
            Value<bool> facesScanned = const Value.absent(),
            Value<String?> linkedAssetId = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> cameraMake = const Value.absent(),
            Value<String?> cameraModel = const Value.absent(),
            Value<String?> lensModel = const Value.absent(),
            Value<double?> focalLengthMm = const Value.absent(),
            Value<double?> fNumber = const Value.absent(),
            Value<int?> iso = const Value.absent(),
            Value<double?> exposureTimeSeconds = const Value.absent(),
            Value<double?> exposureBiasEv = const Value.absent(),
            Value<double?> focalLength35mm = const Value.absent(),
            Value<String?> locationCountry = const Value.absent(),
            Value<String?> locationState = const Value.absent(),
            Value<String?> locationCity = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<String?> colorLabel = const Value.absent(),
            Value<String?> ocrText = const Value.absent(),
            Value<bool> ocrScanned = const Value.absent(),
            Value<String?> aiCaption = const Value.absent(),
            Value<String?> aiCaptionDe = const Value.absent(),
            Value<bool> aiCaptionScanned = const Value.absent(),
            Value<bool> aiCaptionEdited = const Value.absent(),
            Value<bool> aiTagsScanned = const Value.absent(),
            Value<double?> sharpnessScore = const Value.absent(),
            Value<String?> stackId = const Value.absent(),
            Value<bool> isStackCover = const Value.absent(),
            Value<int?> stackSize = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetsCompanion(
            id: id,
            originalFileName: originalFileName,
            relativePath: relativePath,
            thumbnailRelativePath: thumbnailRelativePath,
            previewRelativePath: previewRelativePath,
            developedRelativePath: developedRelativePath,
            trimmedRelativePath: trimmedRelativePath,
            restoredRelativePath: restoredRelativePath,
            checksum: checksum,
            type: type,
            fileCreatedAt: fileCreatedAt,
            importedAt: importedAt,
            isFavorite: isFavorite,
            isTrashed: isTrashed,
            trashedAt: trashedAt,
            isLocked: isLocked,
            description: description,
            widthPx: widthPx,
            heightPx: heightPx,
            durationSeconds: durationSeconds,
            fileSizeBytes: fileSizeBytes,
            backedUp: backedUp,
            autoBackedUp: autoBackedUp,
            facesScanned: facesScanned,
            linkedAssetId: linkedAssetId,
            latitude: latitude,
            longitude: longitude,
            cameraMake: cameraMake,
            cameraModel: cameraModel,
            lensModel: lensModel,
            focalLengthMm: focalLengthMm,
            fNumber: fNumber,
            iso: iso,
            exposureTimeSeconds: exposureTimeSeconds,
            exposureBiasEv: exposureBiasEv,
            focalLength35mm: focalLength35mm,
            locationCountry: locationCountry,
            locationState: locationState,
            locationCity: locationCity,
            rating: rating,
            colorLabel: colorLabel,
            ocrText: ocrText,
            ocrScanned: ocrScanned,
            aiCaption: aiCaption,
            aiCaptionDe: aiCaptionDe,
            aiCaptionScanned: aiCaptionScanned,
            aiCaptionEdited: aiCaptionEdited,
            aiTagsScanned: aiTagsScanned,
            sharpnessScore: sharpnessScore,
            stackId: stackId,
            isStackCover: isStackCover,
            stackSize: stackSize,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String originalFileName,
            required String relativePath,
            Value<String?> thumbnailRelativePath = const Value.absent(),
            Value<String?> previewRelativePath = const Value.absent(),
            Value<String?> developedRelativePath = const Value.absent(),
            Value<String?> trimmedRelativePath = const Value.absent(),
            Value<String?> restoredRelativePath = const Value.absent(),
            required String checksum,
            required String type,
            required DateTime fileCreatedAt,
            required DateTime importedAt,
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isTrashed = const Value.absent(),
            Value<DateTime?> trashedAt = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int?> widthPx = const Value.absent(),
            Value<int?> heightPx = const Value.absent(),
            Value<double?> durationSeconds = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<bool> backedUp = const Value.absent(),
            Value<bool> autoBackedUp = const Value.absent(),
            Value<bool> facesScanned = const Value.absent(),
            Value<String?> linkedAssetId = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> cameraMake = const Value.absent(),
            Value<String?> cameraModel = const Value.absent(),
            Value<String?> lensModel = const Value.absent(),
            Value<double?> focalLengthMm = const Value.absent(),
            Value<double?> fNumber = const Value.absent(),
            Value<int?> iso = const Value.absent(),
            Value<double?> exposureTimeSeconds = const Value.absent(),
            Value<double?> exposureBiasEv = const Value.absent(),
            Value<double?> focalLength35mm = const Value.absent(),
            Value<String?> locationCountry = const Value.absent(),
            Value<String?> locationState = const Value.absent(),
            Value<String?> locationCity = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<String?> colorLabel = const Value.absent(),
            Value<String?> ocrText = const Value.absent(),
            Value<bool> ocrScanned = const Value.absent(),
            Value<String?> aiCaption = const Value.absent(),
            Value<String?> aiCaptionDe = const Value.absent(),
            Value<bool> aiCaptionScanned = const Value.absent(),
            Value<bool> aiCaptionEdited = const Value.absent(),
            Value<bool> aiTagsScanned = const Value.absent(),
            Value<double?> sharpnessScore = const Value.absent(),
            Value<String?> stackId = const Value.absent(),
            Value<bool> isStackCover = const Value.absent(),
            Value<int?> stackSize = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetsCompanion.insert(
            id: id,
            originalFileName: originalFileName,
            relativePath: relativePath,
            thumbnailRelativePath: thumbnailRelativePath,
            previewRelativePath: previewRelativePath,
            developedRelativePath: developedRelativePath,
            trimmedRelativePath: trimmedRelativePath,
            restoredRelativePath: restoredRelativePath,
            checksum: checksum,
            type: type,
            fileCreatedAt: fileCreatedAt,
            importedAt: importedAt,
            isFavorite: isFavorite,
            isTrashed: isTrashed,
            trashedAt: trashedAt,
            isLocked: isLocked,
            description: description,
            widthPx: widthPx,
            heightPx: heightPx,
            durationSeconds: durationSeconds,
            fileSizeBytes: fileSizeBytes,
            backedUp: backedUp,
            autoBackedUp: autoBackedUp,
            facesScanned: facesScanned,
            linkedAssetId: linkedAssetId,
            latitude: latitude,
            longitude: longitude,
            cameraMake: cameraMake,
            cameraModel: cameraModel,
            lensModel: lensModel,
            focalLengthMm: focalLengthMm,
            fNumber: fNumber,
            iso: iso,
            exposureTimeSeconds: exposureTimeSeconds,
            exposureBiasEv: exposureBiasEv,
            focalLength35mm: focalLength35mm,
            locationCountry: locationCountry,
            locationState: locationState,
            locationCity: locationCity,
            rating: rating,
            colorLabel: colorLabel,
            ocrText: ocrText,
            ocrScanned: ocrScanned,
            aiCaption: aiCaption,
            aiCaptionDe: aiCaptionDe,
            aiCaptionScanned: aiCaptionScanned,
            aiCaptionEdited: aiCaptionEdited,
            aiTagsScanned: aiTagsScanned,
            sharpnessScore: sharpnessScore,
            stackId: stackId,
            isStackCover: isStackCover,
            stackSize: stackSize,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AssetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssetsTable,
    AssetData,
    $$AssetsTableFilterComposer,
    $$AssetsTableOrderingComposer,
    $$AssetsTableAnnotationComposer,
    $$AssetsTableCreateCompanionBuilder,
    $$AssetsTableUpdateCompanionBuilder,
    (AssetData, BaseReferences<_$AppDatabase, $AssetsTable, AssetData>),
    AssetData,
    PrefetchHooks Function()>;
typedef $$AlbumsTableCreateCompanionBuilder = AlbumsCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  Value<String?> coverAssetId,
  Value<int> rowid,
});
typedef $$AlbumsTableUpdateCompanionBuilder = AlbumsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<String?> coverAssetId,
  Value<int> rowid,
});

class $$AlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverAssetId => $composableBuilder(
      column: $table.coverAssetId, builder: (column) => ColumnFilters(column));
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverAssetId => $composableBuilder(
      column: $table.coverAssetId,
      builder: (column) => ColumnOrderings(column));
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get coverAssetId => $composableBuilder(
      column: $table.coverAssetId, builder: (column) => column);
}

class $$AlbumsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlbumsTable,
    AlbumData,
    $$AlbumsTableFilterComposer,
    $$AlbumsTableOrderingComposer,
    $$AlbumsTableAnnotationComposer,
    $$AlbumsTableCreateCompanionBuilder,
    $$AlbumsTableUpdateCompanionBuilder,
    (AlbumData, BaseReferences<_$AppDatabase, $AlbumsTable, AlbumData>),
    AlbumData,
    PrefetchHooks Function()> {
  $$AlbumsTableTableManager(_$AppDatabase db, $AlbumsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> coverAssetId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlbumsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            coverAssetId: coverAssetId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime createdAt,
            Value<String?> coverAssetId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlbumsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            coverAssetId: coverAssetId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AlbumsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlbumsTable,
    AlbumData,
    $$AlbumsTableFilterComposer,
    $$AlbumsTableOrderingComposer,
    $$AlbumsTableAnnotationComposer,
    $$AlbumsTableCreateCompanionBuilder,
    $$AlbumsTableUpdateCompanionBuilder,
    (AlbumData, BaseReferences<_$AppDatabase, $AlbumsTable, AlbumData>),
    AlbumData,
    PrefetchHooks Function()>;
typedef $$AlbumAssetsTableCreateCompanionBuilder = AlbumAssetsCompanion
    Function({
  required String albumId,
  required String assetId,
  Value<int> rowid,
});
typedef $$AlbumAssetsTableUpdateCompanionBuilder = AlbumAssetsCompanion
    Function({
  Value<String> albumId,
  Value<String> assetId,
  Value<int> rowid,
});

class $$AlbumAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumAssetsTable> {
  $$AlbumAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));
}

class $$AlbumAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumAssetsTable> {
  $$AlbumAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));
}

class $$AlbumAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumAssetsTable> {
  $$AlbumAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);
}

class $$AlbumAssetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlbumAssetsTable,
    AlbumAsset,
    $$AlbumAssetsTableFilterComposer,
    $$AlbumAssetsTableOrderingComposer,
    $$AlbumAssetsTableAnnotationComposer,
    $$AlbumAssetsTableCreateCompanionBuilder,
    $$AlbumAssetsTableUpdateCompanionBuilder,
    (AlbumAsset, BaseReferences<_$AppDatabase, $AlbumAssetsTable, AlbumAsset>),
    AlbumAsset,
    PrefetchHooks Function()> {
  $$AlbumAssetsTableTableManager(_$AppDatabase db, $AlbumAssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> albumId = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlbumAssetsCompanion(
            albumId: albumId,
            assetId: assetId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String albumId,
            required String assetId,
            Value<int> rowid = const Value.absent(),
          }) =>
              AlbumAssetsCompanion.insert(
            albumId: albumId,
            assetId: assetId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AlbumAssetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlbumAssetsTable,
    AlbumAsset,
    $$AlbumAssetsTableFilterComposer,
    $$AlbumAssetsTableOrderingComposer,
    $$AlbumAssetsTableAnnotationComposer,
    $$AlbumAssetsTableCreateCompanionBuilder,
    $$AlbumAssetsTableUpdateCompanionBuilder,
    (AlbumAsset, BaseReferences<_$AppDatabase, $AlbumAssetsTable, AlbumAsset>),
    AlbumAsset,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    TagData,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagData, BaseReferences<_$AppDatabase, $TagsTable, TagData>),
    TagData,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    TagData,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagData, BaseReferences<_$AppDatabase, $TagsTable, TagData>),
    TagData,
    PrefetchHooks Function()>;
typedef $$AssetTagsTableCreateCompanionBuilder = AssetTagsCompanion Function({
  required String assetId,
  required String tagId,
  Value<int> rowid,
});
typedef $$AssetTagsTableUpdateCompanionBuilder = AssetTagsCompanion Function({
  Value<String> assetId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$AssetTagsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetTagsTable> {
  $$AssetTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$AssetTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetTagsTable> {
  $$AssetTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$AssetTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetTagsTable> {
  $$AssetTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$AssetTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssetTagsTable,
    AssetTag,
    $$AssetTagsTableFilterComposer,
    $$AssetTagsTableOrderingComposer,
    $$AssetTagsTableAnnotationComposer,
    $$AssetTagsTableCreateCompanionBuilder,
    $$AssetTagsTableUpdateCompanionBuilder,
    (AssetTag, BaseReferences<_$AppDatabase, $AssetTagsTable, AssetTag>),
    AssetTag,
    PrefetchHooks Function()> {
  $$AssetTagsTableTableManager(_$AppDatabase db, $AssetTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> assetId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetTagsCompanion(
            assetId: assetId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String assetId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetTagsCompanion.insert(
            assetId: assetId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AssetTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssetTagsTable,
    AssetTag,
    $$AssetTagsTableFilterComposer,
    $$AssetTagsTableOrderingComposer,
    $$AssetTagsTableAnnotationComposer,
    $$AssetTagsTableCreateCompanionBuilder,
    $$AssetTagsTableUpdateCompanionBuilder,
    (AssetTag, BaseReferences<_$AppDatabase, $AssetTagsTable, AssetTag>),
    AssetTag,
    PrefetchHooks Function()>;
typedef $$PeopleTableCreateCompanionBuilder = PeopleCompanion Function({
  required String id,
  required String name,
  Value<String?> coverFaceCropPath,
  Value<double?> similarityThreshold,
  Value<DateTime?> geburtsdatum,
  Value<DateTime?> sterbedatum,
  Value<String?> geschlecht,
  Value<int> rowid,
});
typedef $$PeopleTableUpdateCompanionBuilder = PeopleCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> coverFaceCropPath,
  Value<double?> similarityThreshold,
  Value<DateTime?> geburtsdatum,
  Value<DateTime?> sterbedatum,
  Value<String?> geschlecht,
  Value<int> rowid,
});

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverFaceCropPath => $composableBuilder(
      column: $table.coverFaceCropPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get similarityThreshold => $composableBuilder(
      column: $table.similarityThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get geburtsdatum => $composableBuilder(
      column: $table.geburtsdatum, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sterbedatum => $composableBuilder(
      column: $table.sterbedatum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geschlecht => $composableBuilder(
      column: $table.geschlecht, builder: (column) => ColumnFilters(column));
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverFaceCropPath => $composableBuilder(
      column: $table.coverFaceCropPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get similarityThreshold => $composableBuilder(
      column: $table.similarityThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get geburtsdatum => $composableBuilder(
      column: $table.geburtsdatum,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sterbedatum => $composableBuilder(
      column: $table.sterbedatum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geschlecht => $composableBuilder(
      column: $table.geschlecht, builder: (column) => ColumnOrderings(column));
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverFaceCropPath => $composableBuilder(
      column: $table.coverFaceCropPath, builder: (column) => column);

  GeneratedColumn<double> get similarityThreshold => $composableBuilder(
      column: $table.similarityThreshold, builder: (column) => column);

  GeneratedColumn<DateTime> get geburtsdatum => $composableBuilder(
      column: $table.geburtsdatum, builder: (column) => column);

  GeneratedColumn<DateTime> get sterbedatum => $composableBuilder(
      column: $table.sterbedatum, builder: (column) => column);

  GeneratedColumn<String> get geschlecht => $composableBuilder(
      column: $table.geschlecht, builder: (column) => column);
}

class $$PeopleTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PeopleTable,
    PersonData,
    $$PeopleTableFilterComposer,
    $$PeopleTableOrderingComposer,
    $$PeopleTableAnnotationComposer,
    $$PeopleTableCreateCompanionBuilder,
    $$PeopleTableUpdateCompanionBuilder,
    (PersonData, BaseReferences<_$AppDatabase, $PeopleTable, PersonData>),
    PersonData,
    PrefetchHooks Function()> {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> coverFaceCropPath = const Value.absent(),
            Value<double?> similarityThreshold = const Value.absent(),
            Value<DateTime?> geburtsdatum = const Value.absent(),
            Value<DateTime?> sterbedatum = const Value.absent(),
            Value<String?> geschlecht = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeopleCompanion(
            id: id,
            name: name,
            coverFaceCropPath: coverFaceCropPath,
            similarityThreshold: similarityThreshold,
            geburtsdatum: geburtsdatum,
            sterbedatum: sterbedatum,
            geschlecht: geschlecht,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> coverFaceCropPath = const Value.absent(),
            Value<double?> similarityThreshold = const Value.absent(),
            Value<DateTime?> geburtsdatum = const Value.absent(),
            Value<DateTime?> sterbedatum = const Value.absent(),
            Value<String?> geschlecht = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeopleCompanion.insert(
            id: id,
            name: name,
            coverFaceCropPath: coverFaceCropPath,
            similarityThreshold: similarityThreshold,
            geburtsdatum: geburtsdatum,
            sterbedatum: sterbedatum,
            geschlecht: geschlecht,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PeopleTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PeopleTable,
    PersonData,
    $$PeopleTableFilterComposer,
    $$PeopleTableOrderingComposer,
    $$PeopleTableAnnotationComposer,
    $$PeopleTableCreateCompanionBuilder,
    $$PeopleTableUpdateCompanionBuilder,
    (PersonData, BaseReferences<_$AppDatabase, $PeopleTable, PersonData>),
    PersonData,
    PrefetchHooks Function()>;
typedef $$FacesTableCreateCompanionBuilder = FacesCompanion Function({
  required String id,
  required String assetId,
  Value<String?> personId,
  required double boxX,
  required double boxY,
  required double boxW,
  required double boxH,
  Value<String?> cropRelativePath,
  Value<Uint8List?> embedding,
  Value<double?> eyeOpenScore,
  Value<bool> isIgnored,
  Value<int> rowid,
});
typedef $$FacesTableUpdateCompanionBuilder = FacesCompanion Function({
  Value<String> id,
  Value<String> assetId,
  Value<String?> personId,
  Value<double> boxX,
  Value<double> boxY,
  Value<double> boxW,
  Value<double> boxH,
  Value<String?> cropRelativePath,
  Value<Uint8List?> embedding,
  Value<double?> eyeOpenScore,
  Value<bool> isIgnored,
  Value<int> rowid,
});

class $$FacesTableFilterComposer extends Composer<_$AppDatabase, $FacesTable> {
  $$FacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boxX => $composableBuilder(
      column: $table.boxX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boxY => $composableBuilder(
      column: $table.boxY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boxW => $composableBuilder(
      column: $table.boxW, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boxH => $composableBuilder(
      column: $table.boxH, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropRelativePath => $composableBuilder(
      column: $table.cropRelativePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get eyeOpenScore => $composableBuilder(
      column: $table.eyeOpenScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isIgnored => $composableBuilder(
      column: $table.isIgnored, builder: (column) => ColumnFilters(column));
}

class $$FacesTableOrderingComposer
    extends Composer<_$AppDatabase, $FacesTable> {
  $$FacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boxX => $composableBuilder(
      column: $table.boxX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boxY => $composableBuilder(
      column: $table.boxY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boxW => $composableBuilder(
      column: $table.boxW, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boxH => $composableBuilder(
      column: $table.boxH, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropRelativePath => $composableBuilder(
      column: $table.cropRelativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get eyeOpenScore => $composableBuilder(
      column: $table.eyeOpenScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
      column: $table.isIgnored, builder: (column) => ColumnOrderings(column));
}

class $$FacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacesTable> {
  $$FacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<double> get boxX =>
      $composableBuilder(column: $table.boxX, builder: (column) => column);

  GeneratedColumn<double> get boxY =>
      $composableBuilder(column: $table.boxY, builder: (column) => column);

  GeneratedColumn<double> get boxW =>
      $composableBuilder(column: $table.boxW, builder: (column) => column);

  GeneratedColumn<double> get boxH =>
      $composableBuilder(column: $table.boxH, builder: (column) => column);

  GeneratedColumn<String> get cropRelativePath => $composableBuilder(
      column: $table.cropRelativePath, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<double> get eyeOpenScore => $composableBuilder(
      column: $table.eyeOpenScore, builder: (column) => column);

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);
}

class $$FacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FacesTable,
    FaceData,
    $$FacesTableFilterComposer,
    $$FacesTableOrderingComposer,
    $$FacesTableAnnotationComposer,
    $$FacesTableCreateCompanionBuilder,
    $$FacesTableUpdateCompanionBuilder,
    (FaceData, BaseReferences<_$AppDatabase, $FacesTable, FaceData>),
    FaceData,
    PrefetchHooks Function()> {
  $$FacesTableTableManager(_$AppDatabase db, $FacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<double> boxX = const Value.absent(),
            Value<double> boxY = const Value.absent(),
            Value<double> boxW = const Value.absent(),
            Value<double> boxH = const Value.absent(),
            Value<String?> cropRelativePath = const Value.absent(),
            Value<Uint8List?> embedding = const Value.absent(),
            Value<double?> eyeOpenScore = const Value.absent(),
            Value<bool> isIgnored = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FacesCompanion(
            id: id,
            assetId: assetId,
            personId: personId,
            boxX: boxX,
            boxY: boxY,
            boxW: boxW,
            boxH: boxH,
            cropRelativePath: cropRelativePath,
            embedding: embedding,
            eyeOpenScore: eyeOpenScore,
            isIgnored: isIgnored,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String assetId,
            Value<String?> personId = const Value.absent(),
            required double boxX,
            required double boxY,
            required double boxW,
            required double boxH,
            Value<String?> cropRelativePath = const Value.absent(),
            Value<Uint8List?> embedding = const Value.absent(),
            Value<double?> eyeOpenScore = const Value.absent(),
            Value<bool> isIgnored = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FacesCompanion.insert(
            id: id,
            assetId: assetId,
            personId: personId,
            boxX: boxX,
            boxY: boxY,
            boxW: boxW,
            boxH: boxH,
            cropRelativePath: cropRelativePath,
            embedding: embedding,
            eyeOpenScore: eyeOpenScore,
            isIgnored: isIgnored,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FacesTable,
    FaceData,
    $$FacesTableFilterComposer,
    $$FacesTableOrderingComposer,
    $$FacesTableAnnotationComposer,
    $$FacesTableCreateCompanionBuilder,
    $$FacesTableUpdateCompanionBuilder,
    (FaceData, BaseReferences<_$AppDatabase, $FacesTable, FaceData>),
    FaceData,
    PrefetchHooks Function()>;
typedef $$FaceMatchFeedbackTableCreateCompanionBuilder
    = FaceMatchFeedbackCompanion Function({
  Value<int> id,
  required String personId,
  required String faceId,
  required bool accepted,
  required double similarity,
  required DateTime createdAt,
});
typedef $$FaceMatchFeedbackTableUpdateCompanionBuilder
    = FaceMatchFeedbackCompanion Function({
  Value<int> id,
  Value<String> personId,
  Value<String> faceId,
  Value<bool> accepted,
  Value<double> similarity,
  Value<DateTime> createdAt,
});

class $$FaceMatchFeedbackTableFilterComposer
    extends Composer<_$AppDatabase, $FaceMatchFeedbackTable> {
  $$FaceMatchFeedbackTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get faceId => $composableBuilder(
      column: $table.faceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get accepted => $composableBuilder(
      column: $table.accepted, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get similarity => $composableBuilder(
      column: $table.similarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FaceMatchFeedbackTableOrderingComposer
    extends Composer<_$AppDatabase, $FaceMatchFeedbackTable> {
  $$FaceMatchFeedbackTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get faceId => $composableBuilder(
      column: $table.faceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get accepted => $composableBuilder(
      column: $table.accepted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get similarity => $composableBuilder(
      column: $table.similarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FaceMatchFeedbackTableAnnotationComposer
    extends Composer<_$AppDatabase, $FaceMatchFeedbackTable> {
  $$FaceMatchFeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get faceId =>
      $composableBuilder(column: $table.faceId, builder: (column) => column);

  GeneratedColumn<bool> get accepted =>
      $composableBuilder(column: $table.accepted, builder: (column) => column);

  GeneratedColumn<double> get similarity => $composableBuilder(
      column: $table.similarity, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FaceMatchFeedbackTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FaceMatchFeedbackTable,
    FaceMatchFeedbackData,
    $$FaceMatchFeedbackTableFilterComposer,
    $$FaceMatchFeedbackTableOrderingComposer,
    $$FaceMatchFeedbackTableAnnotationComposer,
    $$FaceMatchFeedbackTableCreateCompanionBuilder,
    $$FaceMatchFeedbackTableUpdateCompanionBuilder,
    (
      FaceMatchFeedbackData,
      BaseReferences<_$AppDatabase, $FaceMatchFeedbackTable,
          FaceMatchFeedbackData>
    ),
    FaceMatchFeedbackData,
    PrefetchHooks Function()> {
  $$FaceMatchFeedbackTableTableManager(
      _$AppDatabase db, $FaceMatchFeedbackTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaceMatchFeedbackTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaceMatchFeedbackTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaceMatchFeedbackTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> personId = const Value.absent(),
            Value<String> faceId = const Value.absent(),
            Value<bool> accepted = const Value.absent(),
            Value<double> similarity = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FaceMatchFeedbackCompanion(
            id: id,
            personId: personId,
            faceId: faceId,
            accepted: accepted,
            similarity: similarity,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String personId,
            required String faceId,
            required bool accepted,
            required double similarity,
            required DateTime createdAt,
          }) =>
              FaceMatchFeedbackCompanion.insert(
            id: id,
            personId: personId,
            faceId: faceId,
            accepted: accepted,
            similarity: similarity,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FaceMatchFeedbackTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FaceMatchFeedbackTable,
    FaceMatchFeedbackData,
    $$FaceMatchFeedbackTableFilterComposer,
    $$FaceMatchFeedbackTableOrderingComposer,
    $$FaceMatchFeedbackTableAnnotationComposer,
    $$FaceMatchFeedbackTableCreateCompanionBuilder,
    $$FaceMatchFeedbackTableUpdateCompanionBuilder,
    (
      FaceMatchFeedbackData,
      BaseReferences<_$AppDatabase, $FaceMatchFeedbackTable,
          FaceMatchFeedbackData>
    ),
    FaceMatchFeedbackData,
    PrefetchHooks Function()>;
typedef $$ImageEmbeddingsTableCreateCompanionBuilder = ImageEmbeddingsCompanion
    Function({
  required String assetId,
  required Uint8List vector,
  Value<int> rowid,
});
typedef $$ImageEmbeddingsTableUpdateCompanionBuilder = ImageEmbeddingsCompanion
    Function({
  Value<String> assetId,
  Value<Uint8List> vector,
  Value<int> rowid,
});

class $$ImageEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $ImageEmbeddingsTable> {
  $$ImageEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get vector => $composableBuilder(
      column: $table.vector, builder: (column) => ColumnFilters(column));
}

class $$ImageEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageEmbeddingsTable> {
  $$ImageEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
      column: $table.vector, builder: (column) => ColumnOrderings(column));
}

class $$ImageEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageEmbeddingsTable> {
  $$ImageEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);
}

class $$ImageEmbeddingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageEmbeddingsTable,
    ImageEmbedding,
    $$ImageEmbeddingsTableFilterComposer,
    $$ImageEmbeddingsTableOrderingComposer,
    $$ImageEmbeddingsTableAnnotationComposer,
    $$ImageEmbeddingsTableCreateCompanionBuilder,
    $$ImageEmbeddingsTableUpdateCompanionBuilder,
    (
      ImageEmbedding,
      BaseReferences<_$AppDatabase, $ImageEmbeddingsTable, ImageEmbedding>
    ),
    ImageEmbedding,
    PrefetchHooks Function()> {
  $$ImageEmbeddingsTableTableManager(
      _$AppDatabase db, $ImageEmbeddingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> assetId = const Value.absent(),
            Value<Uint8List> vector = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageEmbeddingsCompanion(
            assetId: assetId,
            vector: vector,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String assetId,
            required Uint8List vector,
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageEmbeddingsCompanion.insert(
            assetId: assetId,
            vector: vector,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ImageEmbeddingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImageEmbeddingsTable,
    ImageEmbedding,
    $$ImageEmbeddingsTableFilterComposer,
    $$ImageEmbeddingsTableOrderingComposer,
    $$ImageEmbeddingsTableAnnotationComposer,
    $$ImageEmbeddingsTableCreateCompanionBuilder,
    $$ImageEmbeddingsTableUpdateCompanionBuilder,
    (
      ImageEmbedding,
      BaseReferences<_$AppDatabase, $ImageEmbeddingsTable, ImageEmbedding>
    ),
    ImageEmbedding,
    PrefetchHooks Function()>;
typedef $$BackupRecordsTableCreateCompanionBuilder = BackupRecordsCompanion
    Function({
  required String id,
  required DateTime performedAt,
  required String destinationPath,
  required int fileCount,
  required int totalBytes,
  Value<int> rowid,
});
typedef $$BackupRecordsTableUpdateCompanionBuilder = BackupRecordsCompanion
    Function({
  Value<String> id,
  Value<DateTime> performedAt,
  Value<String> destinationPath,
  Value<int> fileCount,
  Value<int> totalBytes,
  Value<int> rowid,
});

class $$BackupRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
      column: $table.performedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationPath => $composableBuilder(
      column: $table.destinationPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileCount => $composableBuilder(
      column: $table.fileCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnFilters(column));
}

class $$BackupRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
      column: $table.performedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationPath => $composableBuilder(
      column: $table.destinationPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileCount => $composableBuilder(
      column: $table.fileCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnOrderings(column));
}

class $$BackupRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
      column: $table.performedAt, builder: (column) => column);

  GeneratedColumn<String> get destinationPath => $composableBuilder(
      column: $table.destinationPath, builder: (column) => column);

  GeneratedColumn<int> get fileCount =>
      $composableBuilder(column: $table.fileCount, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => column);
}

class $$BackupRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BackupRecordsTable,
    BackupRecordData,
    $$BackupRecordsTableFilterComposer,
    $$BackupRecordsTableOrderingComposer,
    $$BackupRecordsTableAnnotationComposer,
    $$BackupRecordsTableCreateCompanionBuilder,
    $$BackupRecordsTableUpdateCompanionBuilder,
    (
      BackupRecordData,
      BaseReferences<_$AppDatabase, $BackupRecordsTable, BackupRecordData>
    ),
    BackupRecordData,
    PrefetchHooks Function()> {
  $$BackupRecordsTableTableManager(_$AppDatabase db, $BackupRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> performedAt = const Value.absent(),
            Value<String> destinationPath = const Value.absent(),
            Value<int> fileCount = const Value.absent(),
            Value<int> totalBytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupRecordsCompanion(
            id: id,
            performedAt: performedAt,
            destinationPath: destinationPath,
            fileCount: fileCount,
            totalBytes: totalBytes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime performedAt,
            required String destinationPath,
            required int fileCount,
            required int totalBytes,
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupRecordsCompanion.insert(
            id: id,
            performedAt: performedAt,
            destinationPath: destinationPath,
            fileCount: fileCount,
            totalBytes: totalBytes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BackupRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BackupRecordsTable,
    BackupRecordData,
    $$BackupRecordsTableFilterComposer,
    $$BackupRecordsTableOrderingComposer,
    $$BackupRecordsTableAnnotationComposer,
    $$BackupRecordsTableCreateCompanionBuilder,
    $$BackupRecordsTableUpdateCompanionBuilder,
    (
      BackupRecordData,
      BaseReferences<_$AppDatabase, $BackupRecordsTable, BackupRecordData>
    ),
    BackupRecordData,
    PrefetchHooks Function()>;
typedef $$PrivacySettingsTableCreateCompanionBuilder = PrivacySettingsCompanion
    Function({
  Value<int> id,
  Value<String?> pinHash,
  Value<String?> pinSalt,
  Value<Uint8List?> kdfSalt,
  Value<Uint8List?> wrappedMasterKeyNonce,
  Value<Uint8List?> wrappedMasterKey,
});
typedef $$PrivacySettingsTableUpdateCompanionBuilder = PrivacySettingsCompanion
    Function({
  Value<int> id,
  Value<String?> pinHash,
  Value<String?> pinSalt,
  Value<Uint8List?> kdfSalt,
  Value<Uint8List?> wrappedMasterKeyNonce,
  Value<Uint8List?> wrappedMasterKey,
});

class $$PrivacySettingsTableFilterComposer
    extends Composer<_$AppDatabase, $PrivacySettingsTable> {
  $$PrivacySettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinSalt => $composableBuilder(
      column: $table.pinSalt, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get kdfSalt => $composableBuilder(
      column: $table.kdfSalt, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get wrappedMasterKeyNonce => $composableBuilder(
      column: $table.wrappedMasterKeyNonce,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get wrappedMasterKey => $composableBuilder(
      column: $table.wrappedMasterKey,
      builder: (column) => ColumnFilters(column));
}

class $$PrivacySettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrivacySettingsTable> {
  $$PrivacySettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinSalt => $composableBuilder(
      column: $table.pinSalt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get kdfSalt => $composableBuilder(
      column: $table.kdfSalt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get wrappedMasterKeyNonce => $composableBuilder(
      column: $table.wrappedMasterKeyNonce,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get wrappedMasterKey => $composableBuilder(
      column: $table.wrappedMasterKey,
      builder: (column) => ColumnOrderings(column));
}

class $$PrivacySettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrivacySettingsTable> {
  $$PrivacySettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<Uint8List> get kdfSalt =>
      $composableBuilder(column: $table.kdfSalt, builder: (column) => column);

  GeneratedColumn<Uint8List> get wrappedMasterKeyNonce => $composableBuilder(
      column: $table.wrappedMasterKeyNonce, builder: (column) => column);

  GeneratedColumn<Uint8List> get wrappedMasterKey => $composableBuilder(
      column: $table.wrappedMasterKey, builder: (column) => column);
}

class $$PrivacySettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrivacySettingsTable,
    PrivacySettingsData,
    $$PrivacySettingsTableFilterComposer,
    $$PrivacySettingsTableOrderingComposer,
    $$PrivacySettingsTableAnnotationComposer,
    $$PrivacySettingsTableCreateCompanionBuilder,
    $$PrivacySettingsTableUpdateCompanionBuilder,
    (
      PrivacySettingsData,
      BaseReferences<_$AppDatabase, $PrivacySettingsTable, PrivacySettingsData>
    ),
    PrivacySettingsData,
    PrefetchHooks Function()> {
  $$PrivacySettingsTableTableManager(
      _$AppDatabase db, $PrivacySettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrivacySettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrivacySettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrivacySettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<String?> pinSalt = const Value.absent(),
            Value<Uint8List?> kdfSalt = const Value.absent(),
            Value<Uint8List?> wrappedMasterKeyNonce = const Value.absent(),
            Value<Uint8List?> wrappedMasterKey = const Value.absent(),
          }) =>
              PrivacySettingsCompanion(
            id: id,
            pinHash: pinHash,
            pinSalt: pinSalt,
            kdfSalt: kdfSalt,
            wrappedMasterKeyNonce: wrappedMasterKeyNonce,
            wrappedMasterKey: wrappedMasterKey,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<String?> pinSalt = const Value.absent(),
            Value<Uint8List?> kdfSalt = const Value.absent(),
            Value<Uint8List?> wrappedMasterKeyNonce = const Value.absent(),
            Value<Uint8List?> wrappedMasterKey = const Value.absent(),
          }) =>
              PrivacySettingsCompanion.insert(
            id: id,
            pinHash: pinHash,
            pinSalt: pinSalt,
            kdfSalt: kdfSalt,
            wrappedMasterKeyNonce: wrappedMasterKeyNonce,
            wrappedMasterKey: wrappedMasterKey,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PrivacySettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrivacySettingsTable,
    PrivacySettingsData,
    $$PrivacySettingsTableFilterComposer,
    $$PrivacySettingsTableOrderingComposer,
    $$PrivacySettingsTableAnnotationComposer,
    $$PrivacySettingsTableCreateCompanionBuilder,
    $$PrivacySettingsTableUpdateCompanionBuilder,
    (
      PrivacySettingsData,
      BaseReferences<_$AppDatabase, $PrivacySettingsTable, PrivacySettingsData>
    ),
    PrivacySettingsData,
    PrefetchHooks Function()>;
typedef $$BackupSettingsTableCreateCompanionBuilder = BackupSettingsCompanion
    Function({
  Value<int> id,
  Value<Uint8List?> kdfSalt,
  Value<Uint8List?> wrappedMasterKeyNonce,
  Value<Uint8List?> wrappedMasterKey,
  Value<bool> autoBackupEnabled,
  Value<String?> autoBackupDestination,
  Value<int> autoBackupIntervalHours,
  Value<DateTime?> lastAutoBackupAt,
  Value<int> autoBackupMaxMbPerRun,
});
typedef $$BackupSettingsTableUpdateCompanionBuilder = BackupSettingsCompanion
    Function({
  Value<int> id,
  Value<Uint8List?> kdfSalt,
  Value<Uint8List?> wrappedMasterKeyNonce,
  Value<Uint8List?> wrappedMasterKey,
  Value<bool> autoBackupEnabled,
  Value<String?> autoBackupDestination,
  Value<int> autoBackupIntervalHours,
  Value<DateTime?> lastAutoBackupAt,
  Value<int> autoBackupMaxMbPerRun,
});

class $$BackupSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupSettingsTable> {
  $$BackupSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get kdfSalt => $composableBuilder(
      column: $table.kdfSalt, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get wrappedMasterKeyNonce => $composableBuilder(
      column: $table.wrappedMasterKeyNonce,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get wrappedMasterKey => $composableBuilder(
      column: $table.wrappedMasterKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoBackupEnabled => $composableBuilder(
      column: $table.autoBackupEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get autoBackupDestination => $composableBuilder(
      column: $table.autoBackupDestination,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get autoBackupIntervalHours => $composableBuilder(
      column: $table.autoBackupIntervalHours,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAutoBackupAt => $composableBuilder(
      column: $table.lastAutoBackupAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get autoBackupMaxMbPerRun => $composableBuilder(
      column: $table.autoBackupMaxMbPerRun,
      builder: (column) => ColumnFilters(column));
}

class $$BackupSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupSettingsTable> {
  $$BackupSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get kdfSalt => $composableBuilder(
      column: $table.kdfSalt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get wrappedMasterKeyNonce => $composableBuilder(
      column: $table.wrappedMasterKeyNonce,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get wrappedMasterKey => $composableBuilder(
      column: $table.wrappedMasterKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoBackupEnabled => $composableBuilder(
      column: $table.autoBackupEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get autoBackupDestination => $composableBuilder(
      column: $table.autoBackupDestination,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get autoBackupIntervalHours => $composableBuilder(
      column: $table.autoBackupIntervalHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAutoBackupAt => $composableBuilder(
      column: $table.lastAutoBackupAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get autoBackupMaxMbPerRun => $composableBuilder(
      column: $table.autoBackupMaxMbPerRun,
      builder: (column) => ColumnOrderings(column));
}

class $$BackupSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupSettingsTable> {
  $$BackupSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get kdfSalt =>
      $composableBuilder(column: $table.kdfSalt, builder: (column) => column);

  GeneratedColumn<Uint8List> get wrappedMasterKeyNonce => $composableBuilder(
      column: $table.wrappedMasterKeyNonce, builder: (column) => column);

  GeneratedColumn<Uint8List> get wrappedMasterKey => $composableBuilder(
      column: $table.wrappedMasterKey, builder: (column) => column);

  GeneratedColumn<bool> get autoBackupEnabled => $composableBuilder(
      column: $table.autoBackupEnabled, builder: (column) => column);

  GeneratedColumn<String> get autoBackupDestination => $composableBuilder(
      column: $table.autoBackupDestination, builder: (column) => column);

  GeneratedColumn<int> get autoBackupIntervalHours => $composableBuilder(
      column: $table.autoBackupIntervalHours, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAutoBackupAt => $composableBuilder(
      column: $table.lastAutoBackupAt, builder: (column) => column);

  GeneratedColumn<int> get autoBackupMaxMbPerRun => $composableBuilder(
      column: $table.autoBackupMaxMbPerRun, builder: (column) => column);
}

class $$BackupSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BackupSettingsTable,
    BackupSettingsData,
    $$BackupSettingsTableFilterComposer,
    $$BackupSettingsTableOrderingComposer,
    $$BackupSettingsTableAnnotationComposer,
    $$BackupSettingsTableCreateCompanionBuilder,
    $$BackupSettingsTableUpdateCompanionBuilder,
    (
      BackupSettingsData,
      BaseReferences<_$AppDatabase, $BackupSettingsTable, BackupSettingsData>
    ),
    BackupSettingsData,
    PrefetchHooks Function()> {
  $$BackupSettingsTableTableManager(
      _$AppDatabase db, $BackupSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Uint8List?> kdfSalt = const Value.absent(),
            Value<Uint8List?> wrappedMasterKeyNonce = const Value.absent(),
            Value<Uint8List?> wrappedMasterKey = const Value.absent(),
            Value<bool> autoBackupEnabled = const Value.absent(),
            Value<String?> autoBackupDestination = const Value.absent(),
            Value<int> autoBackupIntervalHours = const Value.absent(),
            Value<DateTime?> lastAutoBackupAt = const Value.absent(),
            Value<int> autoBackupMaxMbPerRun = const Value.absent(),
          }) =>
              BackupSettingsCompanion(
            id: id,
            kdfSalt: kdfSalt,
            wrappedMasterKeyNonce: wrappedMasterKeyNonce,
            wrappedMasterKey: wrappedMasterKey,
            autoBackupEnabled: autoBackupEnabled,
            autoBackupDestination: autoBackupDestination,
            autoBackupIntervalHours: autoBackupIntervalHours,
            lastAutoBackupAt: lastAutoBackupAt,
            autoBackupMaxMbPerRun: autoBackupMaxMbPerRun,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Uint8List?> kdfSalt = const Value.absent(),
            Value<Uint8List?> wrappedMasterKeyNonce = const Value.absent(),
            Value<Uint8List?> wrappedMasterKey = const Value.absent(),
            Value<bool> autoBackupEnabled = const Value.absent(),
            Value<String?> autoBackupDestination = const Value.absent(),
            Value<int> autoBackupIntervalHours = const Value.absent(),
            Value<DateTime?> lastAutoBackupAt = const Value.absent(),
            Value<int> autoBackupMaxMbPerRun = const Value.absent(),
          }) =>
              BackupSettingsCompanion.insert(
            id: id,
            kdfSalt: kdfSalt,
            wrappedMasterKeyNonce: wrappedMasterKeyNonce,
            wrappedMasterKey: wrappedMasterKey,
            autoBackupEnabled: autoBackupEnabled,
            autoBackupDestination: autoBackupDestination,
            autoBackupIntervalHours: autoBackupIntervalHours,
            lastAutoBackupAt: lastAutoBackupAt,
            autoBackupMaxMbPerRun: autoBackupMaxMbPerRun,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BackupSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BackupSettingsTable,
    BackupSettingsData,
    $$BackupSettingsTableFilterComposer,
    $$BackupSettingsTableOrderingComposer,
    $$BackupSettingsTableAnnotationComposer,
    $$BackupSettingsTableCreateCompanionBuilder,
    $$BackupSettingsTableUpdateCompanionBuilder,
    (
      BackupSettingsData,
      BaseReferences<_$AppDatabase, $BackupSettingsTable, BackupSettingsData>
    ),
    BackupSettingsData,
    PrefetchHooks Function()>;
typedef $$SavedSearchesTableCreateCompanionBuilder = SavedSearchesCompanion
    Function({
  required String id,
  required String name,
  required String filtersJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SavedSearchesTableUpdateCompanionBuilder = SavedSearchesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> filtersJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SavedSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedSearchesTable> {
  $$SavedSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filtersJson => $composableBuilder(
      column: $table.filtersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SavedSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedSearchesTable> {
  $$SavedSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filtersJson => $composableBuilder(
      column: $table.filtersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SavedSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedSearchesTable> {
  $$SavedSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filtersJson => $composableBuilder(
      column: $table.filtersJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavedSearchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedSearchesTable,
    SavedSearchData,
    $$SavedSearchesTableFilterComposer,
    $$SavedSearchesTableOrderingComposer,
    $$SavedSearchesTableAnnotationComposer,
    $$SavedSearchesTableCreateCompanionBuilder,
    $$SavedSearchesTableUpdateCompanionBuilder,
    (
      SavedSearchData,
      BaseReferences<_$AppDatabase, $SavedSearchesTable, SavedSearchData>
    ),
    SavedSearchData,
    PrefetchHooks Function()> {
  $$SavedSearchesTableTableManager(_$AppDatabase db, $SavedSearchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> filtersJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedSearchesCompanion(
            id: id,
            name: name,
            filtersJson: filtersJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String filtersJson,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedSearchesCompanion.insert(
            id: id,
            name: name,
            filtersJson: filtersJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavedSearchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavedSearchesTable,
    SavedSearchData,
    $$SavedSearchesTableFilterComposer,
    $$SavedSearchesTableOrderingComposer,
    $$SavedSearchesTableAnnotationComposer,
    $$SavedSearchesTableCreateCompanionBuilder,
    $$SavedSearchesTableUpdateCompanionBuilder,
    (
      SavedSearchData,
      BaseReferences<_$AppDatabase, $SavedSearchesTable, SavedSearchData>
    ),
    SavedSearchData,
    PrefetchHooks Function()>;
typedef $$TrashSettingsTableCreateCompanionBuilder = TrashSettingsCompanion
    Function({
  Value<int> id,
  Value<bool> autoDeleteEnabled,
  Value<int> autoDeleteAfterDays,
  Value<DateTime?> lastPurgeAt,
});
typedef $$TrashSettingsTableUpdateCompanionBuilder = TrashSettingsCompanion
    Function({
  Value<int> id,
  Value<bool> autoDeleteEnabled,
  Value<int> autoDeleteAfterDays,
  Value<DateTime?> lastPurgeAt,
});

class $$TrashSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $TrashSettingsTable> {
  $$TrashSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoDeleteEnabled => $composableBuilder(
      column: $table.autoDeleteEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get autoDeleteAfterDays => $composableBuilder(
      column: $table.autoDeleteAfterDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPurgeAt => $composableBuilder(
      column: $table.lastPurgeAt, builder: (column) => ColumnFilters(column));
}

class $$TrashSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrashSettingsTable> {
  $$TrashSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoDeleteEnabled => $composableBuilder(
      column: $table.autoDeleteEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get autoDeleteAfterDays => $composableBuilder(
      column: $table.autoDeleteAfterDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPurgeAt => $composableBuilder(
      column: $table.lastPurgeAt, builder: (column) => ColumnOrderings(column));
}

class $$TrashSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrashSettingsTable> {
  $$TrashSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get autoDeleteEnabled => $composableBuilder(
      column: $table.autoDeleteEnabled, builder: (column) => column);

  GeneratedColumn<int> get autoDeleteAfterDays => $composableBuilder(
      column: $table.autoDeleteAfterDays, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPurgeAt => $composableBuilder(
      column: $table.lastPurgeAt, builder: (column) => column);
}

class $$TrashSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrashSettingsTable,
    TrashSettingsData,
    $$TrashSettingsTableFilterComposer,
    $$TrashSettingsTableOrderingComposer,
    $$TrashSettingsTableAnnotationComposer,
    $$TrashSettingsTableCreateCompanionBuilder,
    $$TrashSettingsTableUpdateCompanionBuilder,
    (
      TrashSettingsData,
      BaseReferences<_$AppDatabase, $TrashSettingsTable, TrashSettingsData>
    ),
    TrashSettingsData,
    PrefetchHooks Function()> {
  $$TrashSettingsTableTableManager(_$AppDatabase db, $TrashSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrashSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrashSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrashSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> autoDeleteEnabled = const Value.absent(),
            Value<int> autoDeleteAfterDays = const Value.absent(),
            Value<DateTime?> lastPurgeAt = const Value.absent(),
          }) =>
              TrashSettingsCompanion(
            id: id,
            autoDeleteEnabled: autoDeleteEnabled,
            autoDeleteAfterDays: autoDeleteAfterDays,
            lastPurgeAt: lastPurgeAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> autoDeleteEnabled = const Value.absent(),
            Value<int> autoDeleteAfterDays = const Value.absent(),
            Value<DateTime?> lastPurgeAt = const Value.absent(),
          }) =>
              TrashSettingsCompanion.insert(
            id: id,
            autoDeleteEnabled: autoDeleteEnabled,
            autoDeleteAfterDays: autoDeleteAfterDays,
            lastPurgeAt: lastPurgeAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrashSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrashSettingsTable,
    TrashSettingsData,
    $$TrashSettingsTableFilterComposer,
    $$TrashSettingsTableOrderingComposer,
    $$TrashSettingsTableAnnotationComposer,
    $$TrashSettingsTableCreateCompanionBuilder,
    $$TrashSettingsTableUpdateCompanionBuilder,
    (
      TrashSettingsData,
      BaseReferences<_$AppDatabase, $TrashSettingsTable, TrashSettingsData>
    ),
    TrashSettingsData,
    PrefetchHooks Function()>;
typedef $$DuplikatAusnahmenTableCreateCompanionBuilder
    = DuplikatAusnahmenCompanion Function({
  required String assetA,
  required String assetB,
  required DateTime angelegtAm,
  Value<int> rowid,
});
typedef $$DuplikatAusnahmenTableUpdateCompanionBuilder
    = DuplikatAusnahmenCompanion Function({
  Value<String> assetA,
  Value<String> assetB,
  Value<DateTime> angelegtAm,
  Value<int> rowid,
});

class $$DuplikatAusnahmenTableFilterComposer
    extends Composer<_$AppDatabase, $DuplikatAusnahmenTable> {
  $$DuplikatAusnahmenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetA => $composableBuilder(
      column: $table.assetA, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetB => $composableBuilder(
      column: $table.assetB, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get angelegtAm => $composableBuilder(
      column: $table.angelegtAm, builder: (column) => ColumnFilters(column));
}

class $$DuplikatAusnahmenTableOrderingComposer
    extends Composer<_$AppDatabase, $DuplikatAusnahmenTable> {
  $$DuplikatAusnahmenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetA => $composableBuilder(
      column: $table.assetA, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetB => $composableBuilder(
      column: $table.assetB, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get angelegtAm => $composableBuilder(
      column: $table.angelegtAm, builder: (column) => ColumnOrderings(column));
}

class $$DuplikatAusnahmenTableAnnotationComposer
    extends Composer<_$AppDatabase, $DuplikatAusnahmenTable> {
  $$DuplikatAusnahmenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetA =>
      $composableBuilder(column: $table.assetA, builder: (column) => column);

  GeneratedColumn<String> get assetB =>
      $composableBuilder(column: $table.assetB, builder: (column) => column);

  GeneratedColumn<DateTime> get angelegtAm => $composableBuilder(
      column: $table.angelegtAm, builder: (column) => column);
}

class $$DuplikatAusnahmenTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DuplikatAusnahmenTable,
    DuplikatAusnahmeData,
    $$DuplikatAusnahmenTableFilterComposer,
    $$DuplikatAusnahmenTableOrderingComposer,
    $$DuplikatAusnahmenTableAnnotationComposer,
    $$DuplikatAusnahmenTableCreateCompanionBuilder,
    $$DuplikatAusnahmenTableUpdateCompanionBuilder,
    (
      DuplikatAusnahmeData,
      BaseReferences<_$AppDatabase, $DuplikatAusnahmenTable,
          DuplikatAusnahmeData>
    ),
    DuplikatAusnahmeData,
    PrefetchHooks Function()> {
  $$DuplikatAusnahmenTableTableManager(
      _$AppDatabase db, $DuplikatAusnahmenTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DuplikatAusnahmenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DuplikatAusnahmenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DuplikatAusnahmenTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> assetA = const Value.absent(),
            Value<String> assetB = const Value.absent(),
            Value<DateTime> angelegtAm = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DuplikatAusnahmenCompanion(
            assetA: assetA,
            assetB: assetB,
            angelegtAm: angelegtAm,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String assetA,
            required String assetB,
            required DateTime angelegtAm,
            Value<int> rowid = const Value.absent(),
          }) =>
              DuplikatAusnahmenCompanion.insert(
            assetA: assetA,
            assetB: assetB,
            angelegtAm: angelegtAm,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DuplikatAusnahmenTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DuplikatAusnahmenTable,
    DuplikatAusnahmeData,
    $$DuplikatAusnahmenTableFilterComposer,
    $$DuplikatAusnahmenTableOrderingComposer,
    $$DuplikatAusnahmenTableAnnotationComposer,
    $$DuplikatAusnahmenTableCreateCompanionBuilder,
    $$DuplikatAusnahmenTableUpdateCompanionBuilder,
    (
      DuplikatAusnahmeData,
      BaseReferences<_$AppDatabase, $DuplikatAusnahmenTable,
          DuplikatAusnahmeData>
    ),
    DuplikatAusnahmeData,
    PrefetchHooks Function()>;
typedef $$CameraPresetsTableCreateCompanionBuilder = CameraPresetsCompanion
    Function({
  required String id,
  required String cameraMake,
  required String cameraModel,
  Value<String?> targetAlbumId,
  Value<bool> autoFavorite,
  Value<int> rowid,
});
typedef $$CameraPresetsTableUpdateCompanionBuilder = CameraPresetsCompanion
    Function({
  Value<String> id,
  Value<String> cameraMake,
  Value<String> cameraModel,
  Value<String?> targetAlbumId,
  Value<bool> autoFavorite,
  Value<int> rowid,
});

class $$CameraPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $CameraPresetsTable> {
  $$CameraPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cameraMake => $composableBuilder(
      column: $table.cameraMake, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cameraModel => $composableBuilder(
      column: $table.cameraModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetAlbumId => $composableBuilder(
      column: $table.targetAlbumId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoFavorite => $composableBuilder(
      column: $table.autoFavorite, builder: (column) => ColumnFilters(column));
}

class $$CameraPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CameraPresetsTable> {
  $$CameraPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cameraMake => $composableBuilder(
      column: $table.cameraMake, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cameraModel => $composableBuilder(
      column: $table.cameraModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetAlbumId => $composableBuilder(
      column: $table.targetAlbumId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoFavorite => $composableBuilder(
      column: $table.autoFavorite,
      builder: (column) => ColumnOrderings(column));
}

class $$CameraPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CameraPresetsTable> {
  $$CameraPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cameraMake => $composableBuilder(
      column: $table.cameraMake, builder: (column) => column);

  GeneratedColumn<String> get cameraModel => $composableBuilder(
      column: $table.cameraModel, builder: (column) => column);

  GeneratedColumn<String> get targetAlbumId => $composableBuilder(
      column: $table.targetAlbumId, builder: (column) => column);

  GeneratedColumn<bool> get autoFavorite => $composableBuilder(
      column: $table.autoFavorite, builder: (column) => column);
}

class $$CameraPresetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CameraPresetsTable,
    CameraPresetData,
    $$CameraPresetsTableFilterComposer,
    $$CameraPresetsTableOrderingComposer,
    $$CameraPresetsTableAnnotationComposer,
    $$CameraPresetsTableCreateCompanionBuilder,
    $$CameraPresetsTableUpdateCompanionBuilder,
    (
      CameraPresetData,
      BaseReferences<_$AppDatabase, $CameraPresetsTable, CameraPresetData>
    ),
    CameraPresetData,
    PrefetchHooks Function()> {
  $$CameraPresetsTableTableManager(_$AppDatabase db, $CameraPresetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CameraPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CameraPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CameraPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cameraMake = const Value.absent(),
            Value<String> cameraModel = const Value.absent(),
            Value<String?> targetAlbumId = const Value.absent(),
            Value<bool> autoFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CameraPresetsCompanion(
            id: id,
            cameraMake: cameraMake,
            cameraModel: cameraModel,
            targetAlbumId: targetAlbumId,
            autoFavorite: autoFavorite,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cameraMake,
            required String cameraModel,
            Value<String?> targetAlbumId = const Value.absent(),
            Value<bool> autoFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CameraPresetsCompanion.insert(
            id: id,
            cameraMake: cameraMake,
            cameraModel: cameraModel,
            targetAlbumId: targetAlbumId,
            autoFavorite: autoFavorite,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CameraPresetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CameraPresetsTable,
    CameraPresetData,
    $$CameraPresetsTableFilterComposer,
    $$CameraPresetsTableOrderingComposer,
    $$CameraPresetsTableAnnotationComposer,
    $$CameraPresetsTableCreateCompanionBuilder,
    $$CameraPresetsTableUpdateCompanionBuilder,
    (
      CameraPresetData,
      BaseReferences<_$AppDatabase, $CameraPresetsTable, CameraPresetData>
    ),
    CameraPresetData,
    PrefetchHooks Function()>;
typedef $$CameraPresetTagsTableCreateCompanionBuilder
    = CameraPresetTagsCompanion Function({
  required String presetId,
  required String tagId,
  Value<int> rowid,
});
typedef $$CameraPresetTagsTableUpdateCompanionBuilder
    = CameraPresetTagsCompanion Function({
  Value<String> presetId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$CameraPresetTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CameraPresetTagsTable> {
  $$CameraPresetTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get presetId => $composableBuilder(
      column: $table.presetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$CameraPresetTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CameraPresetTagsTable> {
  $$CameraPresetTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get presetId => $composableBuilder(
      column: $table.presetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$CameraPresetTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CameraPresetTagsTable> {
  $$CameraPresetTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$CameraPresetTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CameraPresetTagsTable,
    CameraPresetTag,
    $$CameraPresetTagsTableFilterComposer,
    $$CameraPresetTagsTableOrderingComposer,
    $$CameraPresetTagsTableAnnotationComposer,
    $$CameraPresetTagsTableCreateCompanionBuilder,
    $$CameraPresetTagsTableUpdateCompanionBuilder,
    (
      CameraPresetTag,
      BaseReferences<_$AppDatabase, $CameraPresetTagsTable, CameraPresetTag>
    ),
    CameraPresetTag,
    PrefetchHooks Function()> {
  $$CameraPresetTagsTableTableManager(
      _$AppDatabase db, $CameraPresetTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CameraPresetTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CameraPresetTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CameraPresetTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> presetId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CameraPresetTagsCompanion(
            presetId: presetId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String presetId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              CameraPresetTagsCompanion.insert(
            presetId: presetId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CameraPresetTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CameraPresetTagsTable,
    CameraPresetTag,
    $$CameraPresetTagsTableFilterComposer,
    $$CameraPresetTagsTableOrderingComposer,
    $$CameraPresetTagsTableAnnotationComposer,
    $$CameraPresetTagsTableCreateCompanionBuilder,
    $$CameraPresetTagsTableUpdateCompanionBuilder,
    (
      CameraPresetTag,
      BaseReferences<_$AppDatabase, $CameraPresetTagsTable, CameraPresetTag>
    ),
    CameraPresetTag,
    PrefetchHooks Function()>;
typedef $$DevelopSettingsTableCreateCompanionBuilder = DevelopSettingsCompanion
    Function({
  required String assetId,
  Value<double> exposure,
  Value<double?> temperature,
  Value<double?> tint,
  Value<double> contrast,
  Value<double> shadows,
  Value<double> sharpness,
  Value<double> noiseReduction,
  Value<bool> lensCorrectionEnabled,
  Value<double> clarity,
  Value<double> vignette,
  Value<String?> lutPath,
  Value<double> lutStrength,
  Value<String?> toneCurveJson,
  Value<String?> colorMixerJson,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DevelopSettingsTableUpdateCompanionBuilder = DevelopSettingsCompanion
    Function({
  Value<String> assetId,
  Value<double> exposure,
  Value<double?> temperature,
  Value<double?> tint,
  Value<double> contrast,
  Value<double> shadows,
  Value<double> sharpness,
  Value<double> noiseReduction,
  Value<bool> lensCorrectionEnabled,
  Value<double> clarity,
  Value<double> vignette,
  Value<String?> lutPath,
  Value<double> lutStrength,
  Value<String?> toneCurveJson,
  Value<String?> colorMixerJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DevelopSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DevelopSettingsTable> {
  $$DevelopSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exposure => $composableBuilder(
      column: $table.exposure, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tint => $composableBuilder(
      column: $table.tint, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shadows => $composableBuilder(
      column: $table.shadows, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sharpness => $composableBuilder(
      column: $table.sharpness, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get clarity => $composableBuilder(
      column: $table.clarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vignette => $composableBuilder(
      column: $table.vignette, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lutPath => $composableBuilder(
      column: $table.lutPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lutStrength => $composableBuilder(
      column: $table.lutStrength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toneCurveJson => $composableBuilder(
      column: $table.toneCurveJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorMixerJson => $composableBuilder(
      column: $table.colorMixerJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DevelopSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DevelopSettingsTable> {
  $$DevelopSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exposure => $composableBuilder(
      column: $table.exposure, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tint => $composableBuilder(
      column: $table.tint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shadows => $composableBuilder(
      column: $table.shadows, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sharpness => $composableBuilder(
      column: $table.sharpness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get clarity => $composableBuilder(
      column: $table.clarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vignette => $composableBuilder(
      column: $table.vignette, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lutPath => $composableBuilder(
      column: $table.lutPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lutStrength => $composableBuilder(
      column: $table.lutStrength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toneCurveJson => $composableBuilder(
      column: $table.toneCurveJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorMixerJson => $composableBuilder(
      column: $table.colorMixerJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DevelopSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevelopSettingsTable> {
  $$DevelopSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<double> get exposure =>
      $composableBuilder(column: $table.exposure, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => column);

  GeneratedColumn<double> get tint =>
      $composableBuilder(column: $table.tint, builder: (column) => column);

  GeneratedColumn<double> get contrast =>
      $composableBuilder(column: $table.contrast, builder: (column) => column);

  GeneratedColumn<double> get shadows =>
      $composableBuilder(column: $table.shadows, builder: (column) => column);

  GeneratedColumn<double> get sharpness =>
      $composableBuilder(column: $table.sharpness, builder: (column) => column);

  GeneratedColumn<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction, builder: (column) => column);

  GeneratedColumn<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled, builder: (column) => column);

  GeneratedColumn<double> get clarity =>
      $composableBuilder(column: $table.clarity, builder: (column) => column);

  GeneratedColumn<double> get vignette =>
      $composableBuilder(column: $table.vignette, builder: (column) => column);

  GeneratedColumn<String> get lutPath =>
      $composableBuilder(column: $table.lutPath, builder: (column) => column);

  GeneratedColumn<double> get lutStrength => $composableBuilder(
      column: $table.lutStrength, builder: (column) => column);

  GeneratedColumn<String> get toneCurveJson => $composableBuilder(
      column: $table.toneCurveJson, builder: (column) => column);

  GeneratedColumn<String> get colorMixerJson => $composableBuilder(
      column: $table.colorMixerJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DevelopSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevelopSettingsTable,
    DevelopSettingsData,
    $$DevelopSettingsTableFilterComposer,
    $$DevelopSettingsTableOrderingComposer,
    $$DevelopSettingsTableAnnotationComposer,
    $$DevelopSettingsTableCreateCompanionBuilder,
    $$DevelopSettingsTableUpdateCompanionBuilder,
    (
      DevelopSettingsData,
      BaseReferences<_$AppDatabase, $DevelopSettingsTable, DevelopSettingsData>
    ),
    DevelopSettingsData,
    PrefetchHooks Function()> {
  $$DevelopSettingsTableTableManager(
      _$AppDatabase db, $DevelopSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevelopSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevelopSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevelopSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> assetId = const Value.absent(),
            Value<double> exposure = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<double?> tint = const Value.absent(),
            Value<double> contrast = const Value.absent(),
            Value<double> shadows = const Value.absent(),
            Value<double> sharpness = const Value.absent(),
            Value<double> noiseReduction = const Value.absent(),
            Value<bool> lensCorrectionEnabled = const Value.absent(),
            Value<double> clarity = const Value.absent(),
            Value<double> vignette = const Value.absent(),
            Value<String?> lutPath = const Value.absent(),
            Value<double> lutStrength = const Value.absent(),
            Value<String?> toneCurveJson = const Value.absent(),
            Value<String?> colorMixerJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevelopSettingsCompanion(
            assetId: assetId,
            exposure: exposure,
            temperature: temperature,
            tint: tint,
            contrast: contrast,
            shadows: shadows,
            sharpness: sharpness,
            noiseReduction: noiseReduction,
            lensCorrectionEnabled: lensCorrectionEnabled,
            clarity: clarity,
            vignette: vignette,
            lutPath: lutPath,
            lutStrength: lutStrength,
            toneCurveJson: toneCurveJson,
            colorMixerJson: colorMixerJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String assetId,
            Value<double> exposure = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<double?> tint = const Value.absent(),
            Value<double> contrast = const Value.absent(),
            Value<double> shadows = const Value.absent(),
            Value<double> sharpness = const Value.absent(),
            Value<double> noiseReduction = const Value.absent(),
            Value<bool> lensCorrectionEnabled = const Value.absent(),
            Value<double> clarity = const Value.absent(),
            Value<double> vignette = const Value.absent(),
            Value<String?> lutPath = const Value.absent(),
            Value<double> lutStrength = const Value.absent(),
            Value<String?> toneCurveJson = const Value.absent(),
            Value<String?> colorMixerJson = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DevelopSettingsCompanion.insert(
            assetId: assetId,
            exposure: exposure,
            temperature: temperature,
            tint: tint,
            contrast: contrast,
            shadows: shadows,
            sharpness: sharpness,
            noiseReduction: noiseReduction,
            lensCorrectionEnabled: lensCorrectionEnabled,
            clarity: clarity,
            vignette: vignette,
            lutPath: lutPath,
            lutStrength: lutStrength,
            toneCurveJson: toneCurveJson,
            colorMixerJson: colorMixerJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevelopSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevelopSettingsTable,
    DevelopSettingsData,
    $$DevelopSettingsTableFilterComposer,
    $$DevelopSettingsTableOrderingComposer,
    $$DevelopSettingsTableAnnotationComposer,
    $$DevelopSettingsTableCreateCompanionBuilder,
    $$DevelopSettingsTableUpdateCompanionBuilder,
    (
      DevelopSettingsData,
      BaseReferences<_$AppDatabase, $DevelopSettingsTable, DevelopSettingsData>
    ),
    DevelopSettingsData,
    PrefetchHooks Function()>;
typedef $$DevelopHistoryTableCreateCompanionBuilder = DevelopHistoryCompanion
    Function({
  Value<int> id,
  required String assetId,
  required double exposure,
  Value<double?> temperature,
  Value<double?> tint,
  required double contrast,
  required double shadows,
  required double sharpness,
  required double noiseReduction,
  required bool lensCorrectionEnabled,
  Value<double> clarity,
  Value<double> vignette,
  Value<String?> lutPath,
  Value<double> lutStrength,
  Value<String?> toneCurveJson,
  Value<String?> colorMixerJson,
  required DateTime createdAt,
});
typedef $$DevelopHistoryTableUpdateCompanionBuilder = DevelopHistoryCompanion
    Function({
  Value<int> id,
  Value<String> assetId,
  Value<double> exposure,
  Value<double?> temperature,
  Value<double?> tint,
  Value<double> contrast,
  Value<double> shadows,
  Value<double> sharpness,
  Value<double> noiseReduction,
  Value<bool> lensCorrectionEnabled,
  Value<double> clarity,
  Value<double> vignette,
  Value<String?> lutPath,
  Value<double> lutStrength,
  Value<String?> toneCurveJson,
  Value<String?> colorMixerJson,
  Value<DateTime> createdAt,
});

class $$DevelopHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DevelopHistoryTable> {
  $$DevelopHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exposure => $composableBuilder(
      column: $table.exposure, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tint => $composableBuilder(
      column: $table.tint, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shadows => $composableBuilder(
      column: $table.shadows, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sharpness => $composableBuilder(
      column: $table.sharpness, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get clarity => $composableBuilder(
      column: $table.clarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vignette => $composableBuilder(
      column: $table.vignette, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lutPath => $composableBuilder(
      column: $table.lutPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lutStrength => $composableBuilder(
      column: $table.lutStrength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toneCurveJson => $composableBuilder(
      column: $table.toneCurveJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorMixerJson => $composableBuilder(
      column: $table.colorMixerJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DevelopHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DevelopHistoryTable> {
  $$DevelopHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exposure => $composableBuilder(
      column: $table.exposure, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tint => $composableBuilder(
      column: $table.tint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shadows => $composableBuilder(
      column: $table.shadows, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sharpness => $composableBuilder(
      column: $table.sharpness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get clarity => $composableBuilder(
      column: $table.clarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vignette => $composableBuilder(
      column: $table.vignette, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lutPath => $composableBuilder(
      column: $table.lutPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lutStrength => $composableBuilder(
      column: $table.lutStrength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toneCurveJson => $composableBuilder(
      column: $table.toneCurveJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorMixerJson => $composableBuilder(
      column: $table.colorMixerJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DevelopHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevelopHistoryTable> {
  $$DevelopHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<double> get exposure =>
      $composableBuilder(column: $table.exposure, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => column);

  GeneratedColumn<double> get tint =>
      $composableBuilder(column: $table.tint, builder: (column) => column);

  GeneratedColumn<double> get contrast =>
      $composableBuilder(column: $table.contrast, builder: (column) => column);

  GeneratedColumn<double> get shadows =>
      $composableBuilder(column: $table.shadows, builder: (column) => column);

  GeneratedColumn<double> get sharpness =>
      $composableBuilder(column: $table.sharpness, builder: (column) => column);

  GeneratedColumn<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction, builder: (column) => column);

  GeneratedColumn<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled, builder: (column) => column);

  GeneratedColumn<double> get clarity =>
      $composableBuilder(column: $table.clarity, builder: (column) => column);

  GeneratedColumn<double> get vignette =>
      $composableBuilder(column: $table.vignette, builder: (column) => column);

  GeneratedColumn<String> get lutPath =>
      $composableBuilder(column: $table.lutPath, builder: (column) => column);

  GeneratedColumn<double> get lutStrength => $composableBuilder(
      column: $table.lutStrength, builder: (column) => column);

  GeneratedColumn<String> get toneCurveJson => $composableBuilder(
      column: $table.toneCurveJson, builder: (column) => column);

  GeneratedColumn<String> get colorMixerJson => $composableBuilder(
      column: $table.colorMixerJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DevelopHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevelopHistoryTable,
    DevelopHistoryData,
    $$DevelopHistoryTableFilterComposer,
    $$DevelopHistoryTableOrderingComposer,
    $$DevelopHistoryTableAnnotationComposer,
    $$DevelopHistoryTableCreateCompanionBuilder,
    $$DevelopHistoryTableUpdateCompanionBuilder,
    (
      DevelopHistoryData,
      BaseReferences<_$AppDatabase, $DevelopHistoryTable, DevelopHistoryData>
    ),
    DevelopHistoryData,
    PrefetchHooks Function()> {
  $$DevelopHistoryTableTableManager(
      _$AppDatabase db, $DevelopHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevelopHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevelopHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevelopHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<double> exposure = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<double?> tint = const Value.absent(),
            Value<double> contrast = const Value.absent(),
            Value<double> shadows = const Value.absent(),
            Value<double> sharpness = const Value.absent(),
            Value<double> noiseReduction = const Value.absent(),
            Value<bool> lensCorrectionEnabled = const Value.absent(),
            Value<double> clarity = const Value.absent(),
            Value<double> vignette = const Value.absent(),
            Value<String?> lutPath = const Value.absent(),
            Value<double> lutStrength = const Value.absent(),
            Value<String?> toneCurveJson = const Value.absent(),
            Value<String?> colorMixerJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DevelopHistoryCompanion(
            id: id,
            assetId: assetId,
            exposure: exposure,
            temperature: temperature,
            tint: tint,
            contrast: contrast,
            shadows: shadows,
            sharpness: sharpness,
            noiseReduction: noiseReduction,
            lensCorrectionEnabled: lensCorrectionEnabled,
            clarity: clarity,
            vignette: vignette,
            lutPath: lutPath,
            lutStrength: lutStrength,
            toneCurveJson: toneCurveJson,
            colorMixerJson: colorMixerJson,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String assetId,
            required double exposure,
            Value<double?> temperature = const Value.absent(),
            Value<double?> tint = const Value.absent(),
            required double contrast,
            required double shadows,
            required double sharpness,
            required double noiseReduction,
            required bool lensCorrectionEnabled,
            Value<double> clarity = const Value.absent(),
            Value<double> vignette = const Value.absent(),
            Value<String?> lutPath = const Value.absent(),
            Value<double> lutStrength = const Value.absent(),
            Value<String?> toneCurveJson = const Value.absent(),
            Value<String?> colorMixerJson = const Value.absent(),
            required DateTime createdAt,
          }) =>
              DevelopHistoryCompanion.insert(
            id: id,
            assetId: assetId,
            exposure: exposure,
            temperature: temperature,
            tint: tint,
            contrast: contrast,
            shadows: shadows,
            sharpness: sharpness,
            noiseReduction: noiseReduction,
            lensCorrectionEnabled: lensCorrectionEnabled,
            clarity: clarity,
            vignette: vignette,
            lutPath: lutPath,
            lutStrength: lutStrength,
            toneCurveJson: toneCurveJson,
            colorMixerJson: colorMixerJson,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevelopHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevelopHistoryTable,
    DevelopHistoryData,
    $$DevelopHistoryTableFilterComposer,
    $$DevelopHistoryTableOrderingComposer,
    $$DevelopHistoryTableAnnotationComposer,
    $$DevelopHistoryTableCreateCompanionBuilder,
    $$DevelopHistoryTableUpdateCompanionBuilder,
    (
      DevelopHistoryData,
      BaseReferences<_$AppDatabase, $DevelopHistoryTable, DevelopHistoryData>
    ),
    DevelopHistoryData,
    PrefetchHooks Function()>;
typedef $$VideoTrimsTableCreateCompanionBuilder = VideoTrimsCompanion Function({
  required String assetId,
  required double startSeconds,
  required double endSeconds,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$VideoTrimsTableUpdateCompanionBuilder = VideoTrimsCompanion Function({
  Value<String> assetId,
  Value<double> startSeconds,
  Value<double> endSeconds,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$VideoTrimsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoTrimsTable> {
  $$VideoTrimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get startSeconds => $composableBuilder(
      column: $table.startSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get endSeconds => $composableBuilder(
      column: $table.endSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$VideoTrimsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoTrimsTable> {
  $$VideoTrimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get startSeconds => $composableBuilder(
      column: $table.startSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get endSeconds => $composableBuilder(
      column: $table.endSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$VideoTrimsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoTrimsTable> {
  $$VideoTrimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<double> get startSeconds => $composableBuilder(
      column: $table.startSeconds, builder: (column) => column);

  GeneratedColumn<double> get endSeconds => $composableBuilder(
      column: $table.endSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VideoTrimsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VideoTrimsTable,
    VideoTrimData,
    $$VideoTrimsTableFilterComposer,
    $$VideoTrimsTableOrderingComposer,
    $$VideoTrimsTableAnnotationComposer,
    $$VideoTrimsTableCreateCompanionBuilder,
    $$VideoTrimsTableUpdateCompanionBuilder,
    (
      VideoTrimData,
      BaseReferences<_$AppDatabase, $VideoTrimsTable, VideoTrimData>
    ),
    VideoTrimData,
    PrefetchHooks Function()> {
  $$VideoTrimsTableTableManager(_$AppDatabase db, $VideoTrimsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoTrimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoTrimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoTrimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> assetId = const Value.absent(),
            Value<double> startSeconds = const Value.absent(),
            Value<double> endSeconds = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VideoTrimsCompanion(
            assetId: assetId,
            startSeconds: startSeconds,
            endSeconds: endSeconds,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String assetId,
            required double startSeconds,
            required double endSeconds,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VideoTrimsCompanion.insert(
            assetId: assetId,
            startSeconds: startSeconds,
            endSeconds: endSeconds,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VideoTrimsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VideoTrimsTable,
    VideoTrimData,
    $$VideoTrimsTableFilterComposer,
    $$VideoTrimsTableOrderingComposer,
    $$VideoTrimsTableAnnotationComposer,
    $$VideoTrimsTableCreateCompanionBuilder,
    $$VideoTrimsTableUpdateCompanionBuilder,
    (
      VideoTrimData,
      BaseReferences<_$AppDatabase, $VideoTrimsTable, VideoTrimData>
    ),
    VideoTrimData,
    PrefetchHooks Function()>;
typedef $$DevelopMasksTableCreateCompanionBuilder = DevelopMasksCompanion
    Function({
  Value<int> id,
  required String assetId,
  required String maskRelativePath,
  required String label,
  Value<double> exposure,
  Value<double?> temperature,
  Value<double?> tint,
  Value<double> contrast,
  Value<double> shadows,
  Value<double> sharpness,
  Value<double> noiseReduction,
  Value<bool> lensCorrectionEnabled,
  required DateTime createdAt,
  Value<String?> shapeDefinitionJson,
});
typedef $$DevelopMasksTableUpdateCompanionBuilder = DevelopMasksCompanion
    Function({
  Value<int> id,
  Value<String> assetId,
  Value<String> maskRelativePath,
  Value<String> label,
  Value<double> exposure,
  Value<double?> temperature,
  Value<double?> tint,
  Value<double> contrast,
  Value<double> shadows,
  Value<double> sharpness,
  Value<double> noiseReduction,
  Value<bool> lensCorrectionEnabled,
  Value<DateTime> createdAt,
  Value<String?> shapeDefinitionJson,
});

class $$DevelopMasksTableFilterComposer
    extends Composer<_$AppDatabase, $DevelopMasksTable> {
  $$DevelopMasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get maskRelativePath => $composableBuilder(
      column: $table.maskRelativePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exposure => $composableBuilder(
      column: $table.exposure, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tint => $composableBuilder(
      column: $table.tint, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shadows => $composableBuilder(
      column: $table.shadows, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sharpness => $composableBuilder(
      column: $table.sharpness, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shapeDefinitionJson => $composableBuilder(
      column: $table.shapeDefinitionJson,
      builder: (column) => ColumnFilters(column));
}

class $$DevelopMasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DevelopMasksTable> {
  $$DevelopMasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get maskRelativePath => $composableBuilder(
      column: $table.maskRelativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exposure => $composableBuilder(
      column: $table.exposure, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tint => $composableBuilder(
      column: $table.tint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shadows => $composableBuilder(
      column: $table.shadows, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sharpness => $composableBuilder(
      column: $table.sharpness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shapeDefinitionJson => $composableBuilder(
      column: $table.shapeDefinitionJson,
      builder: (column) => ColumnOrderings(column));
}

class $$DevelopMasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevelopMasksTable> {
  $$DevelopMasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get maskRelativePath => $composableBuilder(
      column: $table.maskRelativePath, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get exposure =>
      $composableBuilder(column: $table.exposure, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => column);

  GeneratedColumn<double> get tint =>
      $composableBuilder(column: $table.tint, builder: (column) => column);

  GeneratedColumn<double> get contrast =>
      $composableBuilder(column: $table.contrast, builder: (column) => column);

  GeneratedColumn<double> get shadows =>
      $composableBuilder(column: $table.shadows, builder: (column) => column);

  GeneratedColumn<double> get sharpness =>
      $composableBuilder(column: $table.sharpness, builder: (column) => column);

  GeneratedColumn<double> get noiseReduction => $composableBuilder(
      column: $table.noiseReduction, builder: (column) => column);

  GeneratedColumn<bool> get lensCorrectionEnabled => $composableBuilder(
      column: $table.lensCorrectionEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get shapeDefinitionJson => $composableBuilder(
      column: $table.shapeDefinitionJson, builder: (column) => column);
}

class $$DevelopMasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevelopMasksTable,
    DevelopMaskData,
    $$DevelopMasksTableFilterComposer,
    $$DevelopMasksTableOrderingComposer,
    $$DevelopMasksTableAnnotationComposer,
    $$DevelopMasksTableCreateCompanionBuilder,
    $$DevelopMasksTableUpdateCompanionBuilder,
    (
      DevelopMaskData,
      BaseReferences<_$AppDatabase, $DevelopMasksTable, DevelopMaskData>
    ),
    DevelopMaskData,
    PrefetchHooks Function()> {
  $$DevelopMasksTableTableManager(_$AppDatabase db, $DevelopMasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevelopMasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevelopMasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevelopMasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<String> maskRelativePath = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<double> exposure = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<double?> tint = const Value.absent(),
            Value<double> contrast = const Value.absent(),
            Value<double> shadows = const Value.absent(),
            Value<double> sharpness = const Value.absent(),
            Value<double> noiseReduction = const Value.absent(),
            Value<bool> lensCorrectionEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> shapeDefinitionJson = const Value.absent(),
          }) =>
              DevelopMasksCompanion(
            id: id,
            assetId: assetId,
            maskRelativePath: maskRelativePath,
            label: label,
            exposure: exposure,
            temperature: temperature,
            tint: tint,
            contrast: contrast,
            shadows: shadows,
            sharpness: sharpness,
            noiseReduction: noiseReduction,
            lensCorrectionEnabled: lensCorrectionEnabled,
            createdAt: createdAt,
            shapeDefinitionJson: shapeDefinitionJson,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String assetId,
            required String maskRelativePath,
            required String label,
            Value<double> exposure = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<double?> tint = const Value.absent(),
            Value<double> contrast = const Value.absent(),
            Value<double> shadows = const Value.absent(),
            Value<double> sharpness = const Value.absent(),
            Value<double> noiseReduction = const Value.absent(),
            Value<bool> lensCorrectionEnabled = const Value.absent(),
            required DateTime createdAt,
            Value<String?> shapeDefinitionJson = const Value.absent(),
          }) =>
              DevelopMasksCompanion.insert(
            id: id,
            assetId: assetId,
            maskRelativePath: maskRelativePath,
            label: label,
            exposure: exposure,
            temperature: temperature,
            tint: tint,
            contrast: contrast,
            shadows: shadows,
            sharpness: sharpness,
            noiseReduction: noiseReduction,
            lensCorrectionEnabled: lensCorrectionEnabled,
            createdAt: createdAt,
            shapeDefinitionJson: shapeDefinitionJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevelopMasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevelopMasksTable,
    DevelopMaskData,
    $$DevelopMasksTableFilterComposer,
    $$DevelopMasksTableOrderingComposer,
    $$DevelopMasksTableAnnotationComposer,
    $$DevelopMasksTableCreateCompanionBuilder,
    $$DevelopMasksTableUpdateCompanionBuilder,
    (
      DevelopMaskData,
      BaseReferences<_$AppDatabase, $DevelopMasksTable, DevelopMaskData>
    ),
    DevelopMaskData,
    PrefetchHooks Function()>;
typedef $$RestoreJobsTableCreateCompanionBuilder = RestoreJobsCompanion
    Function({
  required String id,
  required String assetId,
  required String status,
  Value<int> tilesDone,
  Value<int> tilesTotal,
  Value<String?> errorMessage,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$RestoreJobsTableUpdateCompanionBuilder = RestoreJobsCompanion
    Function({
  Value<String> id,
  Value<String> assetId,
  Value<String> status,
  Value<int> tilesDone,
  Value<int> tilesTotal,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$RestoreJobsTableFilterComposer
    extends Composer<_$AppDatabase, $RestoreJobsTable> {
  $$RestoreJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tilesDone => $composableBuilder(
      column: $table.tilesDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tilesTotal => $composableBuilder(
      column: $table.tilesTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$RestoreJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $RestoreJobsTable> {
  $$RestoreJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tilesDone => $composableBuilder(
      column: $table.tilesDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tilesTotal => $composableBuilder(
      column: $table.tilesTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$RestoreJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RestoreJobsTable> {
  $$RestoreJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get tilesDone =>
      $composableBuilder(column: $table.tilesDone, builder: (column) => column);

  GeneratedColumn<int> get tilesTotal => $composableBuilder(
      column: $table.tilesTotal, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$RestoreJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RestoreJobsTable,
    RestoreJobData,
    $$RestoreJobsTableFilterComposer,
    $$RestoreJobsTableOrderingComposer,
    $$RestoreJobsTableAnnotationComposer,
    $$RestoreJobsTableCreateCompanionBuilder,
    $$RestoreJobsTableUpdateCompanionBuilder,
    (
      RestoreJobData,
      BaseReferences<_$AppDatabase, $RestoreJobsTable, RestoreJobData>
    ),
    RestoreJobData,
    PrefetchHooks Function()> {
  $$RestoreJobsTableTableManager(_$AppDatabase db, $RestoreJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestoreJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestoreJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestoreJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> tilesDone = const Value.absent(),
            Value<int> tilesTotal = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RestoreJobsCompanion(
            id: id,
            assetId: assetId,
            status: status,
            tilesDone: tilesDone,
            tilesTotal: tilesTotal,
            errorMessage: errorMessage,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String assetId,
            required String status,
            Value<int> tilesDone = const Value.absent(),
            Value<int> tilesTotal = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RestoreJobsCompanion.insert(
            id: id,
            assetId: assetId,
            status: status,
            tilesDone: tilesDone,
            tilesTotal: tilesTotal,
            errorMessage: errorMessage,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RestoreJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RestoreJobsTable,
    RestoreJobData,
    $$RestoreJobsTableFilterComposer,
    $$RestoreJobsTableOrderingComposer,
    $$RestoreJobsTableAnnotationComposer,
    $$RestoreJobsTableCreateCompanionBuilder,
    $$RestoreJobsTableUpdateCompanionBuilder,
    (
      RestoreJobData,
      BaseReferences<_$AppDatabase, $RestoreJobsTable, RestoreJobData>
    ),
    RestoreJobData,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  Value<String> themeMode,
  Value<String> sprache,
  Value<bool> autoAnalyzeAfterImport,
  Value<String?> watchedFolderPath,
  Value<String?> watchedFolderToken,
  Value<double> faceSimilarityThreshold,
  Value<bool> translateCaptions,
  Value<bool> translateSearchAndTags,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  Value<String> themeMode,
  Value<String> sprache,
  Value<bool> autoAnalyzeAfterImport,
  Value<String?> watchedFolderPath,
  Value<String?> watchedFolderToken,
  Value<double> faceSimilarityThreshold,
  Value<bool> translateCaptions,
  Value<bool> translateSearchAndTags,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sprache => $composableBuilder(
      column: $table.sprache, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoAnalyzeAfterImport => $composableBuilder(
      column: $table.autoAnalyzeAfterImport,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get watchedFolderPath => $composableBuilder(
      column: $table.watchedFolderPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get watchedFolderToken => $composableBuilder(
      column: $table.watchedFolderToken,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get faceSimilarityThreshold => $composableBuilder(
      column: $table.faceSimilarityThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get translateCaptions => $composableBuilder(
      column: $table.translateCaptions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get translateSearchAndTags => $composableBuilder(
      column: $table.translateSearchAndTags,
      builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sprache => $composableBuilder(
      column: $table.sprache, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoAnalyzeAfterImport => $composableBuilder(
      column: $table.autoAnalyzeAfterImport,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get watchedFolderPath => $composableBuilder(
      column: $table.watchedFolderPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get watchedFolderToken => $composableBuilder(
      column: $table.watchedFolderToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get faceSimilarityThreshold => $composableBuilder(
      column: $table.faceSimilarityThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get translateCaptions => $composableBuilder(
      column: $table.translateCaptions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get translateSearchAndTags => $composableBuilder(
      column: $table.translateSearchAndTags,
      builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get sprache =>
      $composableBuilder(column: $table.sprache, builder: (column) => column);

  GeneratedColumn<bool> get autoAnalyzeAfterImport => $composableBuilder(
      column: $table.autoAnalyzeAfterImport, builder: (column) => column);

  GeneratedColumn<String> get watchedFolderPath => $composableBuilder(
      column: $table.watchedFolderPath, builder: (column) => column);

  GeneratedColumn<String> get watchedFolderToken => $composableBuilder(
      column: $table.watchedFolderToken, builder: (column) => column);

  GeneratedColumn<double> get faceSimilarityThreshold => $composableBuilder(
      column: $table.faceSimilarityThreshold, builder: (column) => column);

  GeneratedColumn<bool> get translateCaptions => $composableBuilder(
      column: $table.translateCaptions, builder: (column) => column);

  GeneratedColumn<bool> get translateSearchAndTags => $composableBuilder(
      column: $table.translateSearchAndTags, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingsData,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingsData,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsData>
    ),
    AppSettingsData,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<String> sprache = const Value.absent(),
            Value<bool> autoAnalyzeAfterImport = const Value.absent(),
            Value<String?> watchedFolderPath = const Value.absent(),
            Value<String?> watchedFolderToken = const Value.absent(),
            Value<double> faceSimilarityThreshold = const Value.absent(),
            Value<bool> translateCaptions = const Value.absent(),
            Value<bool> translateSearchAndTags = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            id: id,
            themeMode: themeMode,
            sprache: sprache,
            autoAnalyzeAfterImport: autoAnalyzeAfterImport,
            watchedFolderPath: watchedFolderPath,
            watchedFolderToken: watchedFolderToken,
            faceSimilarityThreshold: faceSimilarityThreshold,
            translateCaptions: translateCaptions,
            translateSearchAndTags: translateSearchAndTags,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<String> sprache = const Value.absent(),
            Value<bool> autoAnalyzeAfterImport = const Value.absent(),
            Value<String?> watchedFolderPath = const Value.absent(),
            Value<String?> watchedFolderToken = const Value.absent(),
            Value<double> faceSimilarityThreshold = const Value.absent(),
            Value<bool> translateCaptions = const Value.absent(),
            Value<bool> translateSearchAndTags = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            id: id,
            themeMode: themeMode,
            sprache: sprache,
            autoAnalyzeAfterImport: autoAnalyzeAfterImport,
            watchedFolderPath: watchedFolderPath,
            watchedFolderToken: watchedFolderToken,
            faceSimilarityThreshold: faceSimilarityThreshold,
            translateCaptions: translateCaptions,
            translateSearchAndTags: translateSearchAndTags,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingsData,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingsData,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsData>
    ),
    AppSettingsData,
    PrefetchHooks Function()>;
typedef $$AiTagVocabularyTableCreateCompanionBuilder = AiTagVocabularyCompanion
    Function({
  Value<int> id,
  required String term,
});
typedef $$AiTagVocabularyTableUpdateCompanionBuilder = AiTagVocabularyCompanion
    Function({
  Value<int> id,
  Value<String> term,
});

class $$AiTagVocabularyTableFilterComposer
    extends Composer<_$AppDatabase, $AiTagVocabularyTable> {
  $$AiTagVocabularyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get term => $composableBuilder(
      column: $table.term, builder: (column) => ColumnFilters(column));
}

class $$AiTagVocabularyTableOrderingComposer
    extends Composer<_$AppDatabase, $AiTagVocabularyTable> {
  $$AiTagVocabularyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get term => $composableBuilder(
      column: $table.term, builder: (column) => ColumnOrderings(column));
}

class $$AiTagVocabularyTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiTagVocabularyTable> {
  $$AiTagVocabularyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);
}

class $$AiTagVocabularyTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiTagVocabularyTable,
    AiTagVocabularyData,
    $$AiTagVocabularyTableFilterComposer,
    $$AiTagVocabularyTableOrderingComposer,
    $$AiTagVocabularyTableAnnotationComposer,
    $$AiTagVocabularyTableCreateCompanionBuilder,
    $$AiTagVocabularyTableUpdateCompanionBuilder,
    (
      AiTagVocabularyData,
      BaseReferences<_$AppDatabase, $AiTagVocabularyTable, AiTagVocabularyData>
    ),
    AiTagVocabularyData,
    PrefetchHooks Function()> {
  $$AiTagVocabularyTableTableManager(
      _$AppDatabase db, $AiTagVocabularyTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiTagVocabularyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiTagVocabularyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiTagVocabularyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> term = const Value.absent(),
          }) =>
              AiTagVocabularyCompanion(
            id: id,
            term: term,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String term,
          }) =>
              AiTagVocabularyCompanion.insert(
            id: id,
            term: term,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiTagVocabularyTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiTagVocabularyTable,
    AiTagVocabularyData,
    $$AiTagVocabularyTableFilterComposer,
    $$AiTagVocabularyTableOrderingComposer,
    $$AiTagVocabularyTableAnnotationComposer,
    $$AiTagVocabularyTableCreateCompanionBuilder,
    $$AiTagVocabularyTableUpdateCompanionBuilder,
    (
      AiTagVocabularyData,
      BaseReferences<_$AppDatabase, $AiTagVocabularyTable, AiTagVocabularyData>
    ),
    AiTagVocabularyData,
    PrefetchHooks Function()>;
typedef $$AutomationRulesTableCreateCompanionBuilder = AutomationRulesCompanion
    Function({
  required String id,
  required String name,
  required String triggerType,
  Value<double?> regionCenterLat,
  Value<double?> regionCenterLon,
  Value<double?> regionRadiusKm,
  Value<String?> aiTagTerm,
  Value<DateTime?> dateFrom,
  Value<DateTime?> dateTo,
  Value<String?> targetAlbumId,
  Value<bool> autoFavorite,
  Value<int> rowid,
});
typedef $$AutomationRulesTableUpdateCompanionBuilder = AutomationRulesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> triggerType,
  Value<double?> regionCenterLat,
  Value<double?> regionCenterLon,
  Value<double?> regionRadiusKm,
  Value<String?> aiTagTerm,
  Value<DateTime?> dateFrom,
  Value<DateTime?> dateTo,
  Value<String?> targetAlbumId,
  Value<bool> autoFavorite,
  Value<int> rowid,
});

class $$AutomationRulesTableFilterComposer
    extends Composer<_$AppDatabase, $AutomationRulesTable> {
  $$AutomationRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get regionCenterLat => $composableBuilder(
      column: $table.regionCenterLat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get regionCenterLon => $composableBuilder(
      column: $table.regionCenterLon,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get regionRadiusKm => $composableBuilder(
      column: $table.regionRadiusKm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiTagTerm => $composableBuilder(
      column: $table.aiTagTerm, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateFrom => $composableBuilder(
      column: $table.dateFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateTo => $composableBuilder(
      column: $table.dateTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetAlbumId => $composableBuilder(
      column: $table.targetAlbumId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoFavorite => $composableBuilder(
      column: $table.autoFavorite, builder: (column) => ColumnFilters(column));
}

class $$AutomationRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $AutomationRulesTable> {
  $$AutomationRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get regionCenterLat => $composableBuilder(
      column: $table.regionCenterLat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get regionCenterLon => $composableBuilder(
      column: $table.regionCenterLon,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get regionRadiusKm => $composableBuilder(
      column: $table.regionRadiusKm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiTagTerm => $composableBuilder(
      column: $table.aiTagTerm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateFrom => $composableBuilder(
      column: $table.dateFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateTo => $composableBuilder(
      column: $table.dateTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetAlbumId => $composableBuilder(
      column: $table.targetAlbumId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoFavorite => $composableBuilder(
      column: $table.autoFavorite,
      builder: (column) => ColumnOrderings(column));
}

class $$AutomationRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AutomationRulesTable> {
  $$AutomationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => column);

  GeneratedColumn<double> get regionCenterLat => $composableBuilder(
      column: $table.regionCenterLat, builder: (column) => column);

  GeneratedColumn<double> get regionCenterLon => $composableBuilder(
      column: $table.regionCenterLon, builder: (column) => column);

  GeneratedColumn<double> get regionRadiusKm => $composableBuilder(
      column: $table.regionRadiusKm, builder: (column) => column);

  GeneratedColumn<String> get aiTagTerm =>
      $composableBuilder(column: $table.aiTagTerm, builder: (column) => column);

  GeneratedColumn<DateTime> get dateFrom =>
      $composableBuilder(column: $table.dateFrom, builder: (column) => column);

  GeneratedColumn<DateTime> get dateTo =>
      $composableBuilder(column: $table.dateTo, builder: (column) => column);

  GeneratedColumn<String> get targetAlbumId => $composableBuilder(
      column: $table.targetAlbumId, builder: (column) => column);

  GeneratedColumn<bool> get autoFavorite => $composableBuilder(
      column: $table.autoFavorite, builder: (column) => column);
}

class $$AutomationRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AutomationRulesTable,
    AutomationRuleData,
    $$AutomationRulesTableFilterComposer,
    $$AutomationRulesTableOrderingComposer,
    $$AutomationRulesTableAnnotationComposer,
    $$AutomationRulesTableCreateCompanionBuilder,
    $$AutomationRulesTableUpdateCompanionBuilder,
    (
      AutomationRuleData,
      BaseReferences<_$AppDatabase, $AutomationRulesTable, AutomationRuleData>
    ),
    AutomationRuleData,
    PrefetchHooks Function()> {
  $$AutomationRulesTableTableManager(
      _$AppDatabase db, $AutomationRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutomationRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AutomationRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AutomationRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> triggerType = const Value.absent(),
            Value<double?> regionCenterLat = const Value.absent(),
            Value<double?> regionCenterLon = const Value.absent(),
            Value<double?> regionRadiusKm = const Value.absent(),
            Value<String?> aiTagTerm = const Value.absent(),
            Value<DateTime?> dateFrom = const Value.absent(),
            Value<DateTime?> dateTo = const Value.absent(),
            Value<String?> targetAlbumId = const Value.absent(),
            Value<bool> autoFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AutomationRulesCompanion(
            id: id,
            name: name,
            triggerType: triggerType,
            regionCenterLat: regionCenterLat,
            regionCenterLon: regionCenterLon,
            regionRadiusKm: regionRadiusKm,
            aiTagTerm: aiTagTerm,
            dateFrom: dateFrom,
            dateTo: dateTo,
            targetAlbumId: targetAlbumId,
            autoFavorite: autoFavorite,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String triggerType,
            Value<double?> regionCenterLat = const Value.absent(),
            Value<double?> regionCenterLon = const Value.absent(),
            Value<double?> regionRadiusKm = const Value.absent(),
            Value<String?> aiTagTerm = const Value.absent(),
            Value<DateTime?> dateFrom = const Value.absent(),
            Value<DateTime?> dateTo = const Value.absent(),
            Value<String?> targetAlbumId = const Value.absent(),
            Value<bool> autoFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AutomationRulesCompanion.insert(
            id: id,
            name: name,
            triggerType: triggerType,
            regionCenterLat: regionCenterLat,
            regionCenterLon: regionCenterLon,
            regionRadiusKm: regionRadiusKm,
            aiTagTerm: aiTagTerm,
            dateFrom: dateFrom,
            dateTo: dateTo,
            targetAlbumId: targetAlbumId,
            autoFavorite: autoFavorite,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AutomationRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AutomationRulesTable,
    AutomationRuleData,
    $$AutomationRulesTableFilterComposer,
    $$AutomationRulesTableOrderingComposer,
    $$AutomationRulesTableAnnotationComposer,
    $$AutomationRulesTableCreateCompanionBuilder,
    $$AutomationRulesTableUpdateCompanionBuilder,
    (
      AutomationRuleData,
      BaseReferences<_$AppDatabase, $AutomationRulesTable, AutomationRuleData>
    ),
    AutomationRuleData,
    PrefetchHooks Function()>;
typedef $$AutomationRuleTagsTableCreateCompanionBuilder
    = AutomationRuleTagsCompanion Function({
  required String ruleId,
  required String tagId,
  Value<int> rowid,
});
typedef $$AutomationRuleTagsTableUpdateCompanionBuilder
    = AutomationRuleTagsCompanion Function({
  Value<String> ruleId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$AutomationRuleTagsTableFilterComposer
    extends Composer<_$AppDatabase, $AutomationRuleTagsTable> {
  $$AutomationRuleTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$AutomationRuleTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $AutomationRuleTagsTable> {
  $$AutomationRuleTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$AutomationRuleTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AutomationRuleTagsTable> {
  $$AutomationRuleTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$AutomationRuleTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AutomationRuleTagsTable,
    AutomationRuleTag,
    $$AutomationRuleTagsTableFilterComposer,
    $$AutomationRuleTagsTableOrderingComposer,
    $$AutomationRuleTagsTableAnnotationComposer,
    $$AutomationRuleTagsTableCreateCompanionBuilder,
    $$AutomationRuleTagsTableUpdateCompanionBuilder,
    (
      AutomationRuleTag,
      BaseReferences<_$AppDatabase, $AutomationRuleTagsTable, AutomationRuleTag>
    ),
    AutomationRuleTag,
    PrefetchHooks Function()> {
  $$AutomationRuleTagsTableTableManager(
      _$AppDatabase db, $AutomationRuleTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutomationRuleTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AutomationRuleTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AutomationRuleTagsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ruleId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AutomationRuleTagsCompanion(
            ruleId: ruleId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ruleId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              AutomationRuleTagsCompanion.insert(
            ruleId: ruleId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AutomationRuleTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AutomationRuleTagsTable,
    AutomationRuleTag,
    $$AutomationRuleTagsTableFilterComposer,
    $$AutomationRuleTagsTableOrderingComposer,
    $$AutomationRuleTagsTableAnnotationComposer,
    $$AutomationRuleTagsTableCreateCompanionBuilder,
    $$AutomationRuleTagsTableUpdateCompanionBuilder,
    (
      AutomationRuleTag,
      BaseReferences<_$AppDatabase, $AutomationRuleTagsTable, AutomationRuleTag>
    ),
    AutomationRuleTag,
    PrefetchHooks Function()>;
typedef $$ExportPresetsTableCreateCompanionBuilder = ExportPresetsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<bool> nachJpeg,
  Value<int?> maxKante,
  Value<double> qualitaet,
  Value<String> namensmuster,
  Value<bool> xmpDaneben,
  required DateTime erstelltAm,
});
typedef $$ExportPresetsTableUpdateCompanionBuilder = ExportPresetsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<bool> nachJpeg,
  Value<int?> maxKante,
  Value<double> qualitaet,
  Value<String> namensmuster,
  Value<bool> xmpDaneben,
  Value<DateTime> erstelltAm,
});

class $$ExportPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $ExportPresetsTable> {
  $$ExportPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get nachJpeg => $composableBuilder(
      column: $table.nachJpeg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxKante => $composableBuilder(
      column: $table.maxKante, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qualitaet => $composableBuilder(
      column: $table.qualitaet, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get namensmuster => $composableBuilder(
      column: $table.namensmuster, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get xmpDaneben => $composableBuilder(
      column: $table.xmpDaneben, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get erstelltAm => $composableBuilder(
      column: $table.erstelltAm, builder: (column) => ColumnFilters(column));
}

class $$ExportPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportPresetsTable> {
  $$ExportPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get nachJpeg => $composableBuilder(
      column: $table.nachJpeg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxKante => $composableBuilder(
      column: $table.maxKante, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qualitaet => $composableBuilder(
      column: $table.qualitaet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get namensmuster => $composableBuilder(
      column: $table.namensmuster,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get xmpDaneben => $composableBuilder(
      column: $table.xmpDaneben, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get erstelltAm => $composableBuilder(
      column: $table.erstelltAm, builder: (column) => ColumnOrderings(column));
}

class $$ExportPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportPresetsTable> {
  $$ExportPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get nachJpeg =>
      $composableBuilder(column: $table.nachJpeg, builder: (column) => column);

  GeneratedColumn<int> get maxKante =>
      $composableBuilder(column: $table.maxKante, builder: (column) => column);

  GeneratedColumn<double> get qualitaet =>
      $composableBuilder(column: $table.qualitaet, builder: (column) => column);

  GeneratedColumn<String> get namensmuster => $composableBuilder(
      column: $table.namensmuster, builder: (column) => column);

  GeneratedColumn<bool> get xmpDaneben => $composableBuilder(
      column: $table.xmpDaneben, builder: (column) => column);

  GeneratedColumn<DateTime> get erstelltAm => $composableBuilder(
      column: $table.erstelltAm, builder: (column) => column);
}

class $$ExportPresetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExportPresetsTable,
    ExportPresetData,
    $$ExportPresetsTableFilterComposer,
    $$ExportPresetsTableOrderingComposer,
    $$ExportPresetsTableAnnotationComposer,
    $$ExportPresetsTableCreateCompanionBuilder,
    $$ExportPresetsTableUpdateCompanionBuilder,
    (
      ExportPresetData,
      BaseReferences<_$AppDatabase, $ExportPresetsTable, ExportPresetData>
    ),
    ExportPresetData,
    PrefetchHooks Function()> {
  $$ExportPresetsTableTableManager(_$AppDatabase db, $ExportPresetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> nachJpeg = const Value.absent(),
            Value<int?> maxKante = const Value.absent(),
            Value<double> qualitaet = const Value.absent(),
            Value<String> namensmuster = const Value.absent(),
            Value<bool> xmpDaneben = const Value.absent(),
            Value<DateTime> erstelltAm = const Value.absent(),
          }) =>
              ExportPresetsCompanion(
            id: id,
            name: name,
            nachJpeg: nachJpeg,
            maxKante: maxKante,
            qualitaet: qualitaet,
            namensmuster: namensmuster,
            xmpDaneben: xmpDaneben,
            erstelltAm: erstelltAm,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> nachJpeg = const Value.absent(),
            Value<int?> maxKante = const Value.absent(),
            Value<double> qualitaet = const Value.absent(),
            Value<String> namensmuster = const Value.absent(),
            Value<bool> xmpDaneben = const Value.absent(),
            required DateTime erstelltAm,
          }) =>
              ExportPresetsCompanion.insert(
            id: id,
            name: name,
            nachJpeg: nachJpeg,
            maxKante: maxKante,
            qualitaet: qualitaet,
            namensmuster: namensmuster,
            xmpDaneben: xmpDaneben,
            erstelltAm: erstelltAm,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExportPresetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExportPresetsTable,
    ExportPresetData,
    $$ExportPresetsTableFilterComposer,
    $$ExportPresetsTableOrderingComposer,
    $$ExportPresetsTableAnnotationComposer,
    $$ExportPresetsTableCreateCompanionBuilder,
    $$ExportPresetsTableUpdateCompanionBuilder,
    (
      ExportPresetData,
      BaseReferences<_$AppDatabase, $ExportPresetsTable, ExportPresetData>
    ),
    ExportPresetData,
    PrefetchHooks Function()>;
typedef $$PersonBeziehungenTableCreateCompanionBuilder
    = PersonBeziehungenCompanion Function({
  required String personId,
  required String andereId,
  required String art,
  Value<int> rowid,
});
typedef $$PersonBeziehungenTableUpdateCompanionBuilder
    = PersonBeziehungenCompanion Function({
  Value<String> personId,
  Value<String> andereId,
  Value<String> art,
  Value<int> rowid,
});

class $$PersonBeziehungenTableFilterComposer
    extends Composer<_$AppDatabase, $PersonBeziehungenTable> {
  $$PersonBeziehungenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get andereId => $composableBuilder(
      column: $table.andereId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get art => $composableBuilder(
      column: $table.art, builder: (column) => ColumnFilters(column));
}

class $$PersonBeziehungenTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonBeziehungenTable> {
  $$PersonBeziehungenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get andereId => $composableBuilder(
      column: $table.andereId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get art => $composableBuilder(
      column: $table.art, builder: (column) => ColumnOrderings(column));
}

class $$PersonBeziehungenTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonBeziehungenTable> {
  $$PersonBeziehungenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get andereId =>
      $composableBuilder(column: $table.andereId, builder: (column) => column);

  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);
}

class $$PersonBeziehungenTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonBeziehungenTable,
    PersonBeziehungenData,
    $$PersonBeziehungenTableFilterComposer,
    $$PersonBeziehungenTableOrderingComposer,
    $$PersonBeziehungenTableAnnotationComposer,
    $$PersonBeziehungenTableCreateCompanionBuilder,
    $$PersonBeziehungenTableUpdateCompanionBuilder,
    (
      PersonBeziehungenData,
      BaseReferences<_$AppDatabase, $PersonBeziehungenTable,
          PersonBeziehungenData>
    ),
    PersonBeziehungenData,
    PrefetchHooks Function()> {
  $$PersonBeziehungenTableTableManager(
      _$AppDatabase db, $PersonBeziehungenTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonBeziehungenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonBeziehungenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonBeziehungenTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> personId = const Value.absent(),
            Value<String> andereId = const Value.absent(),
            Value<String> art = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonBeziehungenCompanion(
            personId: personId,
            andereId: andereId,
            art: art,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String personId,
            required String andereId,
            required String art,
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonBeziehungenCompanion.insert(
            personId: personId,
            andereId: andereId,
            art: art,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonBeziehungenTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonBeziehungenTable,
    PersonBeziehungenData,
    $$PersonBeziehungenTableFilterComposer,
    $$PersonBeziehungenTableOrderingComposer,
    $$PersonBeziehungenTableAnnotationComposer,
    $$PersonBeziehungenTableCreateCompanionBuilder,
    $$PersonBeziehungenTableUpdateCompanionBuilder,
    (
      PersonBeziehungenData,
      BaseReferences<_$AppDatabase, $PersonBeziehungenTable,
          PersonBeziehungenData>
    ),
    PersonBeziehungenData,
    PrefetchHooks Function()>;
typedef $$LebensereignisseTableCreateCompanionBuilder
    = LebensereignisseCompanion Function({
  required String id,
  required String personId,
  required String art,
  Value<DateTime?> datum,
  Value<String?> ort,
  Value<String?> notiz,
  Value<int> rowid,
});
typedef $$LebensereignisseTableUpdateCompanionBuilder
    = LebensereignisseCompanion Function({
  Value<String> id,
  Value<String> personId,
  Value<String> art,
  Value<DateTime?> datum,
  Value<String?> ort,
  Value<String?> notiz,
  Value<int> rowid,
});

class $$LebensereignisseTableFilterComposer
    extends Composer<_$AppDatabase, $LebensereignisseTable> {
  $$LebensereignisseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get art => $composableBuilder(
      column: $table.art, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get datum => $composableBuilder(
      column: $table.datum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ort => $composableBuilder(
      column: $table.ort, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notiz => $composableBuilder(
      column: $table.notiz, builder: (column) => ColumnFilters(column));
}

class $$LebensereignisseTableOrderingComposer
    extends Composer<_$AppDatabase, $LebensereignisseTable> {
  $$LebensereignisseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get art => $composableBuilder(
      column: $table.art, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get datum => $composableBuilder(
      column: $table.datum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ort => $composableBuilder(
      column: $table.ort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notiz => $composableBuilder(
      column: $table.notiz, builder: (column) => ColumnOrderings(column));
}

class $$LebensereignisseTableAnnotationComposer
    extends Composer<_$AppDatabase, $LebensereignisseTable> {
  $$LebensereignisseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);

  GeneratedColumn<DateTime> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumn<String> get ort =>
      $composableBuilder(column: $table.ort, builder: (column) => column);

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);
}

class $$LebensereignisseTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LebensereignisseTable,
    LebensereignisseData,
    $$LebensereignisseTableFilterComposer,
    $$LebensereignisseTableOrderingComposer,
    $$LebensereignisseTableAnnotationComposer,
    $$LebensereignisseTableCreateCompanionBuilder,
    $$LebensereignisseTableUpdateCompanionBuilder,
    (
      LebensereignisseData,
      BaseReferences<_$AppDatabase, $LebensereignisseTable,
          LebensereignisseData>
    ),
    LebensereignisseData,
    PrefetchHooks Function()> {
  $$LebensereignisseTableTableManager(
      _$AppDatabase db, $LebensereignisseTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LebensereignisseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LebensereignisseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LebensereignisseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> personId = const Value.absent(),
            Value<String> art = const Value.absent(),
            Value<DateTime?> datum = const Value.absent(),
            Value<String?> ort = const Value.absent(),
            Value<String?> notiz = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LebensereignisseCompanion(
            id: id,
            personId: personId,
            art: art,
            datum: datum,
            ort: ort,
            notiz: notiz,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String personId,
            required String art,
            Value<DateTime?> datum = const Value.absent(),
            Value<String?> ort = const Value.absent(),
            Value<String?> notiz = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LebensereignisseCompanion.insert(
            id: id,
            personId: personId,
            art: art,
            datum: datum,
            ort: ort,
            notiz: notiz,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LebensereignisseTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LebensereignisseTable,
    LebensereignisseData,
    $$LebensereignisseTableFilterComposer,
    $$LebensereignisseTableOrderingComposer,
    $$LebensereignisseTableAnnotationComposer,
    $$LebensereignisseTableCreateCompanionBuilder,
    $$LebensereignisseTableUpdateCompanionBuilder,
    (
      LebensereignisseData,
      BaseReferences<_$AppDatabase, $LebensereignisseTable,
          LebensereignisseData>
    ),
    LebensereignisseData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$AlbumAssetsTableTableManager get albumAssets =>
      $$AlbumAssetsTableTableManager(_db, _db.albumAssets);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$AssetTagsTableTableManager get assetTags =>
      $$AssetTagsTableTableManager(_db, _db.assetTags);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$FacesTableTableManager get faces =>
      $$FacesTableTableManager(_db, _db.faces);
  $$FaceMatchFeedbackTableTableManager get faceMatchFeedback =>
      $$FaceMatchFeedbackTableTableManager(_db, _db.faceMatchFeedback);
  $$ImageEmbeddingsTableTableManager get imageEmbeddings =>
      $$ImageEmbeddingsTableTableManager(_db, _db.imageEmbeddings);
  $$BackupRecordsTableTableManager get backupRecords =>
      $$BackupRecordsTableTableManager(_db, _db.backupRecords);
  $$PrivacySettingsTableTableManager get privacySettings =>
      $$PrivacySettingsTableTableManager(_db, _db.privacySettings);
  $$BackupSettingsTableTableManager get backupSettings =>
      $$BackupSettingsTableTableManager(_db, _db.backupSettings);
  $$SavedSearchesTableTableManager get savedSearches =>
      $$SavedSearchesTableTableManager(_db, _db.savedSearches);
  $$TrashSettingsTableTableManager get trashSettings =>
      $$TrashSettingsTableTableManager(_db, _db.trashSettings);
  $$DuplikatAusnahmenTableTableManager get duplikatAusnahmen =>
      $$DuplikatAusnahmenTableTableManager(_db, _db.duplikatAusnahmen);
  $$CameraPresetsTableTableManager get cameraPresets =>
      $$CameraPresetsTableTableManager(_db, _db.cameraPresets);
  $$CameraPresetTagsTableTableManager get cameraPresetTags =>
      $$CameraPresetTagsTableTableManager(_db, _db.cameraPresetTags);
  $$DevelopSettingsTableTableManager get developSettings =>
      $$DevelopSettingsTableTableManager(_db, _db.developSettings);
  $$DevelopHistoryTableTableManager get developHistory =>
      $$DevelopHistoryTableTableManager(_db, _db.developHistory);
  $$VideoTrimsTableTableManager get videoTrims =>
      $$VideoTrimsTableTableManager(_db, _db.videoTrims);
  $$DevelopMasksTableTableManager get developMasks =>
      $$DevelopMasksTableTableManager(_db, _db.developMasks);
  $$RestoreJobsTableTableManager get restoreJobs =>
      $$RestoreJobsTableTableManager(_db, _db.restoreJobs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$AiTagVocabularyTableTableManager get aiTagVocabulary =>
      $$AiTagVocabularyTableTableManager(_db, _db.aiTagVocabulary);
  $$AutomationRulesTableTableManager get automationRules =>
      $$AutomationRulesTableTableManager(_db, _db.automationRules);
  $$AutomationRuleTagsTableTableManager get automationRuleTags =>
      $$AutomationRuleTagsTableTableManager(_db, _db.automationRuleTags);
  $$ExportPresetsTableTableManager get exportPresets =>
      $$ExportPresetsTableTableManager(_db, _db.exportPresets);
  $$PersonBeziehungenTableTableManager get personBeziehungen =>
      $$PersonBeziehungenTableTableManager(_db, _db.personBeziehungen);
  $$LebensereignisseTableTableManager get lebensereignisse =>
      $$LebensereignisseTableTableManager(_db, _db.lebensereignisse);
}
