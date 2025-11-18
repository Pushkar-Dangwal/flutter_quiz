import './const/colors.dart';
import './const/images.dart';
import './const/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './scores_screen.dart';
import './setup_screen.dart';
import 'auth/login_screen.dart';

class ResultScreen extends StatelessWidget {
  final int points;
  final int totalQuestions;

  const ResultScreen({
    Key? key,
    required this.points,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    int percentage = ((points / (totalQuestions * 10)) * 100).round();

    String resultMessage;
    String resultImage;

    if (percentage >= 80) {
      resultMessage = "Excellent! You're a quiz master!";
      resultImage = balloon2;
    } else if (percentage >= 60) {
      resultMessage = "Great job! Keep it up!";
      resultImage = ideas;
    } else if (percentage >= 40) {
      resultMessage = "Good effort! Practice makes perfect!";
      resultImage = ideas;
    } else {
      resultMessage = "Don't give up! Try again!";
      resultImage = ideas;
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [blue, darkBlue],
            ),
          ),
          child: SingleChildScrollView(
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
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: const Icon(
                          CupertinoIcons.house_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lightgrey, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              normalText(
                                color: Colors.white,
                                size: 16,
                                text: "$percentage%",
                              ),
                            ],
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
                const SizedBox(height: 40),
                headingText(
                  color: Colors.white,
                  size: 32,
                  text: "Quiz Completed!",
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: lightgrey, width: 2),
                  ),
                  child: Column(
                    children: [
                      Image.asset(resultImage, width: 150, height: 150),
                      const SizedBox(height: 24),
                      normalText(
                        color: lightgrey,
                        size: 18,
                        text: "Your Score",
                      ),
                      const SizedBox(height: 8),
                      headingText(
                        color: Colors.white,
                        size: 48,
                        text: "$points",
                      ),
                      const SizedBox(height: 8),
                      normalText(
                        color: lightgrey,
                        size: 16,
                        text: "out of ${totalQuestions * 10} points",
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                normalText(
                                  color: lightgrey,
                                  size: 14,
                                  text: "Correct Answers:",
                                ),
                                headingText(
                                  color: Colors.green,
                                  size: 18,
                                  text: "${points ~/ 10}/${totalQuestions}",
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                normalText(
                                  color: lightgrey,
                                  size: 14,
                                  text: "Accuracy:",
                                ),
                                headingText(
                                  color: Colors.white,
                                  size: 18,
                                  text: "$percentage%",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                normalText(color: Colors.white, size: 18, text: resultMessage),
                const SizedBox(height: 40),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SetupScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: blue,
                        minimumSize: Size(size.width - 100, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      icon: const Icon(CupertinoIcons.refresh, size: 20),
                      label: headingText(color: blue, size: 18, text: "New Quiz"),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ScoresScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: blue,
                        minimumSize: Size(size.width - 100, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      icon: const Icon(CupertinoIcons.chart_bar_fill, size: 20),
                      label: headingText(color: blue, size: 18, text: "View Scores"),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        minimumSize: Size(size.width - 100, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(CupertinoIcons.house_fill, size: 20),
                      label: headingText(color: Colors.white, size: 18, text: "Home"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
