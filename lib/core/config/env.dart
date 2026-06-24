/// Compile-time environment configuration.
///
/// Values are injected via `--dart-define` (or `--dart-define-from-file=.env`)
/// so secrets never live in source control. See `.env.example`.
class Env {
  const Env._();

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static bool get isProduction => appEnv == 'production';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
