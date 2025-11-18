import 'dart:convert';
import 'package:http/http.dart' as http;

String _buildUrl({required int amount, int? categoryId, String? difficulty}) {
  final params = <String, String>{'amount': amount.toString()};
  if (categoryId != null) params['category'] = categoryId.toString();
  if (difficulty != null && difficulty.isNotEmpty) params['difficulty'] = difficulty;
  params['type'] = 'multiple';
  final query = params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
  return 'https://opentdb.com/api.php?$query';
}

Future<dynamic> getQuiz({int amount = 10, int? categoryId, String? difficulty}) async {
  final url = _buildUrl(amount: amount, categoryId: categoryId, difficulty: difficulty);
  final res = await http.get(Uri.parse(url));
  if (res.statusCode == 200) {
    return jsonDecode(res.body.toString());
  }
  throw Exception('Failed to fetch quiz: ${res.statusCode}');
}
