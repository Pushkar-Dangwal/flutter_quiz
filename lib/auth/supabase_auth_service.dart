import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotrue/gotrue.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> signup({required String name, required String email, required String password}) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
    );
    return res.user?.id;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return res.user != null;
    } on AuthApiException catch (e) {
      if (e.code == 'email_not_confirmed') {
        return Future.error('email_not_confirmed');
      }
      return Future.error(e.message);
    } catch (e) {
      return Future.error('auth_error');
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}


