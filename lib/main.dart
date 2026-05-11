import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';

class _DriveTNHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'DriveTN/1.0 (Flutter; contact@drivetn.example)';
  }
}

Future<void> main() async {
  HttpOverrides.global = _DriveTNHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR');
  runApp(const DriveTNApp());
}
