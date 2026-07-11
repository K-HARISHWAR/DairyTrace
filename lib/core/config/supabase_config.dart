class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static void validate() {
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Supabase URL or Publishable Key is missing. '
        'Please run the app with --dart-define=SUPABASE_URL=YOUR_URL '
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_KEY',
      );
    }
  }
}
