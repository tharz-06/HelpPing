import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'theme_notifier.dart';

// SET THIS ONCE PER RUN
//const String currentUserId = 'user1'; // emulator 1 = requester
const String currentUserId = 'user2'; // emulator 2 = helper

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const HelpPingApp(),
    ),
  );
}

class HelpPingApp extends StatelessWidget {
  const HelpPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    const Color primaryBrown = Color(0xFF8B5E3C);
    const Color lightBackground = Color(0xFFF5EDE4);
    const Color cardBrown = Color(0xFFB98B63);

    final ColorScheme lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryBrown,
      onPrimary: Colors.white,
      secondary: cardBrown,
      onSecondary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF3D2B20),
      surfaceDim: const Color(0xFFE9E0D8),
      surfaceBright: Colors.white,
      surfaceContainerLowest: const Color(0xFFF8F1EA),
      surfaceContainerLow: const Color(0xFFF2E7DE),
      surfaceContainer: const Color(0xFFEADCD1),
      surfaceContainerHigh: const Color(0xFFE0D0C3),
      surfaceContainerHighest: const Color(0xFFD5C2B2),
      onSurfaceVariant: const Color(0xFF7A6453),
      outline: const Color(0xFFC4B3A4),
      outlineVariant: const Color(0xFFDDCFC3),
      shadow: const Color(0x55000000),
      scrim: const Color(0x99000000),
      inverseSurface: const Color(0xFF3D2B20),
      onInverseSurface: const Color(0xFFF5EDE4),
      inversePrimary: const Color(0xFFE0B89A),
      surfaceTint: primaryBrown,
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: 'Montserrat',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBrown,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Montserrat',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HelpPing',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.themeMode,
      home: const SplashScreen(),
    );
  }
}
