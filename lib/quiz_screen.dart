import 'dart:async';
import 'package:html_unescape/html_unescape.dart';
import './api_services.dart';
import './result_screen.dart';
import 'services/score_service.dart';
import './const/colors.dart';
import './const/images.dart';
import './const/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login_screen.dart';

class QuizScreen extends StatefulWidget {
  final int amount;
  final int? categoryId;
  final String? difficulty;
  const QuizScreen({Key? key, this.amount = 10, this.categoryId, this.difficulty}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var currentQuestionIndex = 0;
  int seconds = 60;
  Timer? timer;
  late Future quiz;
  final htmlUnescape = HtmlUnescape();
  int points = 0;

  var isLoaded = false;

  var optionsList = [];

  var optionsColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    () async {
      final user = Supabase.instance.client.auth.currentUser;
      if (!mounted) return;
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }
        });
        return;
      }
      quiz = getQuiz(amount: widget.amount, categoryId: widget.categoryId, difficulty: widget.difficulty);
      startTimer();
    }();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  resetColors() {
    optionsColor = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          gotoNextQuestion();
        }
      });
    });
  }

  gotoNextQuestion() {
    isLoaded = false;
    currentQuestionIndex++;
    resetColors();
    timer!.cancel();
    seconds = 60;
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
        )),
        child: FutureBuilder(
          future: quiz,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data["results"];

              if (isLoaded == false) {
                optionsList = data[currentQuestionIndex]["incorrect_answers"];
                optionsList.add(data[currentQuestionIndex]["correct_answer"]);
                optionsList.shuffle();
                isLoaded = true;
              }

              return SingleChildScrollView(
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
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                CupertinoIcons.xmark,
                                color: Colors.white,
                                size: 28,
                              )),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            normalText(color: Colors.white, size: 24, text: "$seconds"),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: seconds / 60,
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lightgrey, width: 2),
                          ),
                          child: TextButton.icon(
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                if (!mounted) return;
                                timer?.cancel();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              },
                              icon: const Icon(CupertinoIcons.square_arrow_right, color: Colors.white, size: 18),
                              label: normalText(color: Colors.white, size: 14, text: "Logout")),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Image.asset(ideas, width: 200),
                    const SizedBox(height: 20),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: normalText(
                            color: lightgrey,
                            size: 18,
                            text: "Question ${currentQuestionIndex + 1} of ${data.length}")),
                    const SizedBox(height: 20),
                    normalText(color: Colors.white, size: 20, text: htmlUnescape.convert(data[currentQuestionIndex]["question"])),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Prevents scrolling conflicts inside SingleChildScrollView
                      itemCount: optionsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        // 1. Decode both the correct answer and the current option for a clean comparison and display
                        var correctAnswer = htmlUnescape.convert(data[currentQuestionIndex]["correct_answer"]);
                        var currentOption = htmlUnescape.convert(optionsList[index].toString());

                        return GestureDetector(
                          onTap: () {
                            if (optionsColor[index] != Colors.white) {
                              return;
                            }

                            setState(() {
                              // 2. Use the clean, decoded variables for the comparison
                              if (correctAnswer == currentOption) {
                                optionsColor[index] = Colors.green;
                                points = points + 10;
                              } else {
                                optionsColor[index] = Colors.red;
                              }
                              if (currentQuestionIndex < data.length - 1) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  // Check if the widget is still in the tree before calling setState
                                  if (mounted) {
                                    gotoNextQuestion();
                                  }
                                });
                              } else {
                                timer?.cancel(); // Use ?. for safety
                                Future.delayed(const Duration(seconds: 1), () async {
                                  if (!mounted) return;
                                  // Save score to Supabase; do not block navigation on failure
                                  try {
                                    await ScoreService().saveScore(
                                      points: points,
                                      totalQuestions: data.length,
                                      categoryId: widget.categoryId,
                                      difficulty: widget.difficulty,
                                    );
                                  } catch (_) {}
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultScreen(
                                        points: points,
                                        totalQuestions: data.length,
                                      ),
                                    ),
                                  );
                                });

                              }
                            });
                        },
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.center,
                        width: size.width - 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                        color: optionsColor[index],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                        color: optionsColor[index] == Colors.white ? lightgrey : Colors.transparent,
                        width: 2,
                        ),
                        ),
                          child: headingText(
                            color: blue,
                            size: 18,
                            // 3. Display the clean, decoded option text to the user
                            text: currentOption,
                          ),
                        ),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            }
          },
        ),
      )),
    );
  }
}

