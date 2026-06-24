import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Thin wrapper around Supabase initialization & client access.
///
/// Keeping initialization here lets the rest of the app depend on an injected
/// [SupabaseClient] (via Riverpod) instead of the global singleton, which keeps
/// features testable.
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    if (!Env.isConfigured) {
      // Fail loudly in non-production so misconfiguration is obvious.
      assert(
        false,
        'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define-from-file=.env',
      );
      return;
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
