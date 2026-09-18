import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_router.dart';
import 'l10n/app_localizations.dart';
import 'src/providers.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: appOverrides(),
      child: const HifzTrackerApp(),
    ),
  );
}

/// Arabic-first shell: `ar` is the default locale, RTL comes from the
/// generated localizations, and Cairo is the UI font.
class HifzTrackerApp extends ConsumerWidget {
  const HifzTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }

  static ThemeData _theme(Brightness brightness) {
    final base = ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF059669),
        brightness: brightness,
      ),
    );
    return base.copyWith(textTheme: GoogleFonts.cairoTextTheme(base.textTheme));
  }
}
