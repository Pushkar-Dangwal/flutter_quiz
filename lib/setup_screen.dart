import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './const/colors.dart';
import './const/text_style.dart';
import './quiz_screen.dart';
import './scores_screen.dart';
import 'auth/login_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _amount = 10;
  // Basic subset of categories (OpenTDB IDs)
  final List<Map<String, dynamic>> _categories = const [
    {'id': null, 'name': 'Any Category'},
    {'id': 9, 'name': 'General Knowledge'},
    {'id': 18, 'name': 'Computer Science'},
    {'id': 23, 'name': 'History'},
    {'id': 21, 'name': 'Sports'},
  ];
  int? _categoryId;
  final List<String> _difficulties = const ['Any', 'Easy', 'Medium', 'Hard'];
  String _difficulty = 'Any';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScoresScreen()));
                          },
                          icon: const Icon(
                            CupertinoIcons.chart_bar,
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
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          headingText(color: Colors.white, size: 28, text: "Setup your quiz"),
                          const SizedBox(height: 8),
                          normalText(color: lightgrey, size: 14, text: "Customize your quiz experience"),
                          const SizedBox(height: 24),
                    // Amount
                    headingText(color: Colors.white, size: 16, text: "Number of questions"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<int>(
                        value: _amount,
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: const [5, 10, 15, 20, 25, 30]
                            .map((n) => DropdownMenuItem<int>(value: n, child: Text('$n')))
                            .toList(),
                        onChanged: (v) => setState(() => _amount = v ?? 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category
                    headingText(color: Colors.white, size: 16, text: "Category"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<int?>(
                        value: _categoryId,
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: _categories
                            .map((c) =>
                                DropdownMenuItem<int?>(value: c['id'] as int?, child: Text(c['name'] as String)))
                            .toList(),
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Difficulty
                    headingText(color: Colors.white, size: 16, text: "Difficulty"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<String>(
                        value: _difficulty,
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: _difficulties
                            .map((d) => DropdownMenuItem<String>(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) => setState(() => _difficulty = v ?? 'Any'),
                      ),
                    ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: size.width - 100,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                              ),
                              onPressed: () {
                                final diff = _difficulty == 'Any' ? null : _difficulty.toLowerCase();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      amount: _amount,
                                      categoryId: _categoryId,
                                      difficulty: diff,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  headingText(color: blue, size: 18, text: "Start Quiz"),
                                  const SizedBox(width: 8),
                                  const Icon(CupertinoIcons.play_fill, color: blue, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


