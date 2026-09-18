import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: HifzTrackerApp()));
}

/// Arabic-first shell: `ar` is the only default locale, Material supplies RTL
/// through [GlobalMaterialLocalizations], and Cairo is the UI font.
class HifzTrackerApp extends StatelessWidget {
  const HifzTrackerApp({super.key});

  static const supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متابعة الحفظ',
      locale: const Locale('ar'),
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const _PlaceholderHome(),
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

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('متابعة الحفظ')),
    );
  }
}
