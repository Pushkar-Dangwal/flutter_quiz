import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './const/colors.dart';
import './const/text_style.dart';
import 'services/score_service.dart';
import './setup_screen.dart';
import 'auth/login_screen.dart';

class ScoresScreen extends StatelessWidget {
  const ScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [blue, darkBlue],
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: lightgrey, width: 2),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        CupertinoIcons.arrow_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: lightgrey, width: 2),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen()));
                          },
                          icon: const Icon(
                            CupertinoIcons.play_fill,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.redAccent, width: 2),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              headingText(color: Colors.white, size: 28, text: "My Scores"),
              const SizedBox(height: 8),
              normalText(color: lightgrey, size: 14, text: "Track your quiz performance"),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
            future: ScoreService().fetchMyScores(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: headingText(
                    color: Colors.white,
                    size: 16,
                    text: "Error: ${snapshot.error}",
                  ),
                );
              }
              final scores = snapshot.data ?? [];
                  if (scores.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.chart_bar, color: Colors.white54, size: 80),
                          const SizedBox(height: 16),
                          headingText(color: Colors.white, size: 20, text: "No scores yet"),
                          const SizedBox(height: 8),
                          normalText(color: lightgrey, size: 14, text: "Take a quiz to see your scores here"),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: scores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = scores[index];
                      final points = s['points'] as int? ?? 0;
                      final total = s['total_questions'] as int? ?? 0;
                      final diff = (s['difficulty'] as String?) ?? 'any';
                      final cat = s['category_id']?.toString() ?? 'any';
                      final created = (s['created_at'] as String?) ?? '';
                      final percentage = ((points / (total * 10)) * 100).round();
                      
                      Color scoreColor = Colors.green;
                      if (percentage < 40) scoreColor = Colors.red;
                      else if (percentage < 60) scoreColor = Colors.orange;
                      else if (percentage < 80) scoreColor = Colors.blue;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: scoreColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(CupertinoIcons.star_fill, color: scoreColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        headingText(color: blue, size: 20, text: "$points pts"),
                                        Text("$percentage% • ${points ~/ 10}/$total correct", 
                                          style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: scoreColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$percentage%",
                                    style: TextStyle(
                                      color: scoreColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.tag, size: 14, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text("Category: $cat", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                const SizedBox(width: 12),
                                const Icon(CupertinoIcons.chart_bar, size: 14, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text("Difficulty: $diff", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                            if (created.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.clock, size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(created, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


