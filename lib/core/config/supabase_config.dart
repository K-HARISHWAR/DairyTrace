class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://fvjmkdvkmdyugnqgerib.supabase.co');
  static const String publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: 'sb_publishable_LiS3DEGFzotBdmjgxTxEPA_ZSXh3iJH');

  static void validate() {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw Exception(
        'Supabase URL or Publishable Key is missing. '
        'Please run the app with --dart-define=SUPABASE_URL=YOUR_URL '
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_KEY',
      );
    }
  }
}
