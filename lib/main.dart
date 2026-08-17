import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'db/database.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_shell.dart';
import 'state/library_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muss vor der ersten Videowiedergabe laufen (siehe widgets/video_playback.dart).
  MediaKit.ensureInitialized();
  // Ohne Argument werden alle Locales vorbereitet – nötig, weil die
  // Sprache zur Laufzeit umschaltbar ist und die Datumsnamen sonst für
  // die jeweils andere fehlten.
  await initializeDateFormatting();
  runApp(const PhotoVaultApp());
}

class PhotoVaultApp extends StatelessWidget {
  const PhotoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryState()..initialize(),
      child: Consumer<LibraryState>(
        builder: (context, library, _) {
          // Kein Stream, solange die DB noch nicht bereit ist (initialize()
          // noch nicht durchgelaufen) – StreamBuilder bleibt dann einfach im
          // Anfangszustand (kein Fehler), themeModeFromString(null) liefert
          // ThemeMode.system als Default.
          return StreamBuilder<AppSettingsData?>(
            stream: library.isReady ? library.db.watchAppSettings() : null,
            builder: (context, settingsSnapshot) {
              return MaterialApp(
                title: 'Photo Vault',
                debugShowCheckedModeBanner: false,
                theme: buildLightTheme(),
                darkTheme: buildDarkTheme(),
                themeMode: themeModeFromString(settingsSnapshot.data?.themeMode),
                // null = Systemsprache, siehe localeFromString.
                locale: localeFromString(settingsSnapshot.data?.sprache),
                supportedLocales: AppTexte.supportedLocales,
                localizationsDelegates: const [
                  AppTexte.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: !library.isReady
                    ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                    : HomeShell(library: library),
              );
            },
          );
        },
      ),
    );
  }
}
