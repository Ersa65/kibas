import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

// =========================================================================
// 🔹 BASE CLASS & MODEL-MODEL PERTANYAAN
// =========================================================================

/// Kelas dasar abstrak untuk semua jenis pertanyaan.
abstract class QuizQuestion {
  const QuizQuestion();
}

/// Model untuk pertanyaan menyusun kalimat.
class SentenceQuestion extends QuizQuestion {
  final String questionText;
  final List<String> options;
  final List<String> correctAnswer;

  const SentenceQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

/// Model untuk pertanyaan pilihan ganda gambar aksara.
class AksaraQuestion extends QuizQuestion {
  final String aksaraImagePath;
  final List<String> options;
  final int correctOptionIndex;

  const AksaraQuestion({
    required this.aksaraImagePath,
    required this.options,
    required this.correctOptionIndex,
  });
}


// =========================================================================
// 🔹 WIDGET UTAMA
// =========================================================================

class Level2QuizScreen extends StatefulWidget {
  const Level2QuizScreen({super.key});

  @override
  State<Level2QuizScreen> createState() => _Level2QuizScreenState();
}

class _Level2QuizScreenState extends State<Level2QuizScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // =========================================================================
  // 🔸 STATE & DATA PERTANYAAN
  // =========================================================================

  // Gabungan dari kedua jenis soal.
  final List<QuizQuestion> _questions = [
    // Soal Tipe 1: Menyusun Kalimat
    const SentenceQuestion(
      questionText: 'Saya Tidur',
      options: ['Nyak', 'Haga', 'Pedom', 'Mengan'],
      correctAnswer: ['Nyak', 'Pedom'],
    ),
    const SentenceQuestion(
      questionText: 'Kamu Makan',
      options: ['Niku', 'Haga', 'Pedom', 'Mengan'],
      correctAnswer: ['Niku', 'Mengan'],
    ),
    const SentenceQuestion(
      questionText: 'Dia Pergi',
      options: ['Ia', 'Lapah', 'Pedom', 'Mengan'],
      correctAnswer: ['Ia', 'Lapah'],
    ),
    // Soal Tipe 2: Pilihan Ganda Aksara
    const AksaraQuestion(
      aksaraImagePath: 'assets/images/aksara_marah.jpg',
      options: ['Saya Marah', 'Saya Menangis', 'Saya Tertawa', 'Saya Terkejut'],
      correctOptionIndex: 0,
    ),
    const AksaraQuestion(
      aksaraImagePath: 'assets/images/aksara_menangis.jpg',
      options: ['Saya Marah', 'Saya Menangis', 'Saya Tertawa', 'Saya Terkejut'],
      correctOptionIndex: 1,
    ),
     const AksaraQuestion(
      aksaraImagePath: 'assets/images/aksara_tertawa.jpg',
      options: ['Saya Marah', 'Saya Menangis', 'Saya Tertawa', 'Saya Terkejut'],
      correctOptionIndex: 2,
    ),
  ];

  int _currentQuestionIndex = 0;
  double _progress = 0.0;

  // State untuk jawaban
  bool? _isCorrect;
  bool _answerChecked = false;
  
  // State untuk Soal Menyusun Kalimat
  List<String> _selectedWords = [];
  
  // State untuk Soal Pilihan Ganda Aksara
  int? _selectedOptionIndex;

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

  // =========================================================================
  // 🔸 LOGIKA KUIS
  // =========================================================================

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

  /// Memeriksa jawaban berdasarkan jenis pertanyaannya.
  void _checkAnswer() {
    if (_answerChecked) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    bool isAnswerCorrect = false;

    // Logika pengecekan untuk Soal Menyusun Kalimat
    if (currentQuestion is SentenceQuestion) {
      // Menggunakan listEquals untuk perbandingan yang sensitif terhadap urutan.
      isAnswerCorrect = listEquals(_selectedWords, currentQuestion.correctAnswer);
    } 
    // Logika pengecekan untuk Soal Pilihan Ganda Aksara
    else if (currentQuestion is AksaraQuestion) {
       if (_selectedOptionIndex != null) {
        isAnswerCorrect = _selectedOptionIndex == currentQuestion.correctOptionIndex;
       } else {
        isAnswerCorrect = false;
       }
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

  /// Pindah ke pertanyaan berikutnya.
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _resetForNextQuestion();
        _updateProgress();
      });
    } else {
      // Kuis selesai
      Navigator.pop(context, true);
    }
  }
  
  /// Mengulang pertanyaan yang salah.
  void _resetCurrentQuestion() {
      setState(() {
        _resetForNextQuestion();
      });
  }
  
  /// Mereset semua state jawaban untuk soal berikutnya atau saat mengulang.
  void _resetForNextQuestion() {
      _isCorrect = null;
      _answerChecked = false;
      _selectedWords = [];
      _selectedOptionIndex = null;
  }

  // =========================================================================
  // 🔹 UI BUILDERS
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE7E497),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            
            // Area konten yang dapat di-scroll
            Expanded(
              child: SingleChildScrollView(
                child: currentQuestion is SentenceQuestion
                    ? _buildSentenceQuestionUI(currentQuestion)
                    : _buildAksaraQuestionUI(currentQuestion as AksaraQuestion),
              ),
            ),
            
            _buildFeedbackOrCheckButton(),
          ],
        ),
      ),
    );
  }

  /// Membangun UI untuk soal menyusun kalimat.
  Widget _buildSentenceQuestionUI(SentenceQuestion question) {
    return Column(
      children: [
       const SizedBox(height: 20),
        Text(
          question.questionText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
        ),
        const SizedBox(height: 30),
        // Kotak Jawaban
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFddb200),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF5D4037), width: 2),
          ),
          child: Center(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selectedWords.map((word) => GestureDetector(
                onTap: () {
                  if (!_answerChecked) setState(() => _selectedWords.remove(word));
                },
                child: Chip(label: Text(word), backgroundColor: Colors.white, deleteIconColor: Colors.red.shade700, onDeleted: () {
                   if (!_answerChecked) setState(() => _selectedWords.remove(word));
                },),
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Pilihan Kata
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: question.options.map((option) {
              final bool isSelected = _selectedWords.contains(option);
              return GestureDetector(
                onTap: isSelected || _answerChecked ? null : () => setState(() => _selectedWords.add(option)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey.shade400 : const Color(0xFFddb200),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
                ),
              );
            }).toList(),
          ),
        ),
      ], 
    );
  }

  /// Membangun UI untuk soal pilihan ganda aksara.
  Widget _buildAksaraQuestionUI(AksaraQuestion question) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Gambar Aksara
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
        // Pilihan Jawaban
        ListView.builder(
          itemCount: question.options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final option = question.options[index];
            bool isSelected = _selectedOptionIndex == index;
            Color buttonColor;
            Color textColor = const Color(0xFF5D4037); // Warna teks default

            if (isSelected) {
              if (_answerChecked) {
                // Setelah jawaban dicek: Hijau/Merah dengan teks putih
                buttonColor = _isCorrect! ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                textColor = Colors.white;
              } else {
                // Sebelum dicek: Warna pilihan aktif
                buttonColor = const Color(0xFFC9A800); // Kuning lebih gelap
              }
            } else {
              // Warna default untuk pilihan yang tidak aktif
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
  
  /// Membangun AppBar (statis).
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
                  color: const Color(0xFFC62828),
                  minHeight: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menentukan apakah akan menampilkan tombol "CHECK" atau feedback "BENAR"/"SALAH".
  Widget _buildFeedbackOrCheckButton() {
    // Jika jawaban sudah dicek
    if (_answerChecked) {
      final bool isCorrect = _isCorrect!;
      return _buildFeedbackSection(
        isCorrect: isCorrect,
        onTap: isCorrect ? _nextQuestion : _resetCurrentQuestion,
        text: isCorrect ? 'LANJUT' : 'COBA LAGI',
        feedbackText: isCorrect ? 'BENAR' : 'SALAH',
        color: isCorrect ? const Color(0xFF2E7D32) :Color(0xFFC62828),
      );
    }
    // Jika belum dicek, tampilkan tombol Check
    else {
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

  /// Membangun UI untuk feedback "BENAR" atau "SALAH".
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
