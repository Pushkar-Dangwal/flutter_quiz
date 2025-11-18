import 'package:supabase_flutter/supabase_flutter.dart';

class ScoreService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'scores';

  Future<void> saveScore({
    required int points,
    required int totalQuestions,
    int? categoryId,
    String? difficulty,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from(_table).insert({
      'user_id': user.id,
      'points': points,
      'total_questions': totalQuestions,
      'category_id': categoryId,
      'difficulty': difficulty,
    });
  }

  Future<List<Map<String, dynamic>>> fetchMyScores() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }
}


