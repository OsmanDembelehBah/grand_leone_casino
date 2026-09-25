import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/main_suite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(410, 860),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Grand Leone Casino (iPhone Preview)',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const GrandLeoneApp());
}

class GrandLeoneApp extends StatelessWidget {
  const GrandLeoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grand Leone Casino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFFFF5200),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5200),
          primary: const Color(0xFFFF5200),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
