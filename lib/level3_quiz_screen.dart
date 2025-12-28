import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class Level3QuizScreen extends StatefulWidget {
  const Level3QuizScreen({super.key});

  @override
  State<Level3QuizScreen> createState() => _Level3QuizScreenState();
}

class _QuizQuestion {
  final String question;
  final String aksaraImagePath;
  final List<String> options;
  final int correctAnswerIndex;

  const _QuizQuestion({
    required this.question,
    required this.aksaraImagePath,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class _Level3QuizScreenState extends State<Level3QuizScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<_QuizQuestion> _questions = [
    const _QuizQuestion(
      question: 'ᬫᬮᬶ ᬓᬚᬗ᭄ ᬫᬘ', // "Nyak Lagi Belajagh"
      aksaraImagePath: 'assets/images/nyak_lagi_belajagh.jpg',
      options: [
        'Saya sedang belajar',
        'Saya sedang tidur',
        'Saya sedang makan',
        'Saya sedang memasak',
      ],
      correctAnswerIndex: 0,
    ),
    const _QuizQuestion(
      question: 'ᬩᬧᬓ᭄ ᬫᬫᬘ ᬩᬸᬓᬸ', // "Bapak Memaca Buku"
      aksaraImagePath: 'assets/images/bak_ngebaca_buku.jpg',
      options: [
        'Bapak mencuci baju',
        'Bapak membeli kue',
        'Bapak bermain bola',
        'Bapak membaca buku',
      ],
      correctAnswerIndex: 3,
    ),
    const _QuizQuestion(
      question: 'ᬅᬤᬶᬓ᭄ ᬫᬕᬮᬦᬶᬦ᭄ ᬩᭀᬮ', // "Adik Bermain Bola"
      aksaraImagePath: 'assets/images/adik_main_bal.jpg',
      options: [
        'Adik bermain bola',
        'Adik menonton tv',
        'Adik menyapu halaman',
        'Adik menggambar gunung',
      ],
      correctAnswerIndex: 0,
    ),
  ];

  int _currentQuestionIndex = 0;
  double _progress = 0.0;
  int? _selectedOptionIndex;
  bool? _isCorrect;
  bool _answerChecked = false;

  @override
  void initState() {
    super.initState();
    _updateProgress();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateProgress() {
    setState(() {
      _progress = (_currentQuestionIndex) / _questions.length;
    });
  }

  Future<void> _playSound(String soundAsset) async {
    try {
      await _audioPlayer.play(AssetSource(soundAsset));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _checkAnswer() {
    if (_answerChecked) return;

    bool isAnswerCorrect = false;
    if (_selectedOptionIndex != null) {
      isAnswerCorrect = _selectedOptionIndex == _questions[_currentQuestionIndex].correctAnswerIndex;
    }

    setState(() {
      _isCorrect = isAnswerCorrect;
      _answerChecked = true;
    });

    if (isAnswerCorrect) {
      _playSound('sounds/menang.mp3');
    } else {
      _playSound('sounds/kalah.mp3');
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _resetForNextQuestion();
        _updateProgress();
      });
    } else {
      Navigator.pop(context, true);
    }
  }

  void _resetCurrentQuestion() {
    setState(() {
      _resetForNextQuestion();
    });
  }

  void _resetForNextQuestion() {
    _isCorrect = null;
    _answerChecked = false;
    _selectedOptionIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E497),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: _buildQuizUI(_questions[_currentQuestionIndex]),
              ),
            ),
            _buildFeedbackOrCheckButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizUI(_QuizQuestion question) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFddb200),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF5D4037), width: 2),
          ),
          child: Center(
            child: Image.asset(
              question.aksaraImagePath,
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
            ),
          ),
        ),
        const SizedBox(height: 50),
        ListView.builder(
          itemCount: question.options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final option = question.options[index];
            bool isSelected = _selectedOptionIndex == index;
            Color buttonColor;
            Color textColor = const Color(0xFF5D4037);

            if (isSelected) {
              if (_answerChecked) {
                buttonColor = _isCorrect! ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                textColor = Colors.white;
              } else {
                buttonColor = const Color(0xFFC9A800);
                textColor = Colors.white;
              }
            } else {
              buttonColor = const Color(0xFFDDB200);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _answerChecked ? null : () => setState(() => _selectedOptionIndex = index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isSelected ? Colors.white : const Color(0xFF5D4037), width: 2),
                ),
                child: Text(
                  option,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4037)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xFFA50000),
                  minHeight: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackOrCheckButton() {
    if (_answerChecked) {
      final bool isCorrect = _isCorrect!;
      return _buildFeedbackSection(
        isCorrect: isCorrect,
        onTap: isCorrect ? _nextQuestion : _resetCurrentQuestion,
        text: isCorrect ? 'LANJUT' : 'COBA LAGI',
        feedbackText: isCorrect ? 'BENAR' : 'SALAH',
        color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
        child: ElevatedButton(
          onPressed: _checkAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDDB200),
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'CHECK',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
          ),
        ),
      );
    }
  }

  Widget _buildFeedbackSection({
    required bool isCorrect,
    required VoidCallback onTap,
    required String text,
    required String feedbackText,
    required Color color,
  }) {
    return Container(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            feedbackText,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
