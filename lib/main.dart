import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(393, 852),
      minimumSize: Size(393, 852),
      maximumSize: Size(393, 852),
      center: true,
      backgroundColor: Colors.transparent,
      title: 'Grand Leone Casino',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const GrandLeoneCasinoApp());
}

class GrandLeoneCasinoApp extends StatefulWidget {
  const GrandLeoneCasinoApp({super.key});

  @override
  State<GrandLeoneCasinoApp> createState() => _GrandLeoneCasinoAppState();
}

class _GrandLeoneCasinoAppState extends State<GrandLeoneCasinoApp> {
  Map<String, dynamic>? _currentUser;

  void _handleLogin(Map<String, dynamic> user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _handleLogout() {
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grand Leone Casino',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: _currentUser == null
          ? LoginScreen(onLoginSuccess: _handleLogin)
          : MainNavigationScreen(
              user: _currentUser,
              onLogout: _handleLogout,
            ),
    );
  }
}
