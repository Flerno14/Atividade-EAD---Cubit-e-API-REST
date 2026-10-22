class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cefzxbeyewupfxowchac.supabase.co',
  );
  static const publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
}
