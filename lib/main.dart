import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/localia_provider.dart';
import 'theme/app_theme.dart';
import 'ui/splash_screen.dart';

void main() => runApp(
  MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => LocaliaProvider())],
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  ),
);