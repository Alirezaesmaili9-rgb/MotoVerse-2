import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/network/supabase_service.dart';
import 'core/providers/core_providers.dart';

/// Shared startup sequence: initialize Supabase + SharedPreferences, then run
/// the app with the dependencies injected into the Riverpod container.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MotoVerseApp(),
    ),
  );
}
