import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String usersBoxName = 'users_box';
  static const String sessionBoxName = 'session_box';
  static const String sessionEmailKey = 'current_email';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(usersBoxName),
      Hive.openBox<String>(sessionBoxName),
    ]);
  }
}


