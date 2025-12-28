// Impor library yang diperlukan dari Flutter dan audioplayers.
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Model data untuk opsi kuis berbasis gambar.
class _ImageOption {
  final String name;
  final String imagePath;
  _ImageOption(this.name, this.imagePath);
}

// Model data untuk kuis melengkapi kata.
class _WordQuestion {
  final String title;
  final String word;
  final String correctAnswer;
  final Map<int, String> prefilledLetters;

  _WordQuestion({
    required this.title,
    required this.word,
    required this.correctAnswer,
    this.prefilledLetters = const {},
  });
}

// Model data untuk pertanyaan pilihan ganda (teks).
class _TextChoiceQuestion {
  final String title;
  final String imagePath;
  final List<String> options;
  final String correctAnswer;

  _TextChoiceQuestion({
    required this.title,
    required this.imagePath,
    required this.options,
    required this.correctAnswer,
  });
}

// LearnScreen adalah StatefulWidget yang menampilkan layar kuis.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // Menggunakan AudioCache untuk memutar efek suara dengan latensi rendah.
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _questionIndex = 0; // Indeks pertanyaan saat ini.

  @override
  void initState() {
    super.initState();
    // Mengatur mode latensi rendah untuk efek suara yang responsif.
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  // === Data untuk Pertanyaan 1 (Pilihan Gambar) ===
  final List<_ImageOption> _q1Options = [
    _ImageOption('tangan', 'assets/images/tangan.png'),
    _ImageOption('kaki', 'assets/images/kaki.png'),
    _ImageOption('telinga', 'assets/images/telinga.png'),
    _ImageOption('rambut', 'assets/images/rambut.png'),
  ];
  final String _q1CorrectAnswer = 'tangan';
  _ImageOption? _q1SelectedOption; // Opsi yang dipilih oleh pengguna.
  bool? _q1IsCorrect; // Status jawaban (benar/salah).

  // === Data untuk Pertanyaan 2 (Melengkapi Kata) ===
  final _question2 = _WordQuestion(
    title: 'Lengkapi kosa kata di bawah ini!',
    word: 'RAMBUT',
    correctAnswer: 'BUWOK',
    prefilledLetters: {0: 'B', 3: 'O'},
  );
  String _q2Input = ''; // Input dari pengguna.
  bool? _q2IsCorrect; // Status jawaban (benar/salah).

  // === Data untuk Pertanyaan 3 (Pilihan Ganda Teks) ===
  final _question3 = _TextChoiceQuestion(
    title: 'Pilih kata yang sesuai dengan gambar ini!',
    imagePath: 'assets/images/kaki.png',
    options: ['CUKUT', 'CULUK', 'BUWOK', 'CUPING'],
    correctAnswer: 'CUKUT',
  );
  String? _q3SelectedOption; // Opsi yang dipilih pengguna.
  bool? _q3IsCorrect; // Status jawaban (benar/salah).

  // === Data untuk Pertanyaan 4 (Pilihan Ganda Teks) ===
  final _question4 = _TextChoiceQuestion(
    title: 'Pilih kata yang sesuai dengan gambar ini!',
    imagePath: 'assets/images/aksara1.jpg',
    options: ['Sedih', 'Marah', 'Menangis', 'Bahagia'],
    correctAnswer: 'Menangis',
  );
  String? _q4SelectedOption; // Opsi yang dipilih pengguna.
  bool? _q4IsCorrect; // Status jawaban (benar/salah).

  @override
  void dispose() {
    _audioPlayer.dispose(); // Melepaskan resource audio player saat widget dihancurkan.
    super.dispose();
  }

  // Fungsi untuk memutar efek suara.
  void _playSound(String sound) {
    _audioPlayer.play(AssetSource('sounds/$sound'));
  }

  // Fungsi untuk pindah ke pertanyaan berikutnya dan mereset status.
  void _next() {
    // Jika ini adalah pertanyaan terakhir, jangan lakukan apa-apa di sini.
    // Navigasi akan ditangani oleh tombol 'SELESAI'.
    if (_questionIndex >= 3) {
      return;
    }

    setState(() {
      _questionIndex++;
      // Reset semua status jawaban dan pilihan.
      _q1SelectedOption = null;
      _q1IsCorrect = null;
      _q2Input = '';
      _q2IsCorrect = null;
      _q3SelectedOption = null;
      _q3IsCorrect = null;
      _q4SelectedOption = null;
      _q4IsCorrect = null;
    });
  }

  // Fungsi untuk mereset status pertanyaan saat ini (jika jawaban salah).
  void _resetCurrent() {
    setState(() {
      if (_questionIndex == 0) {
        _q1SelectedOption = null;
        _q1IsCorrect = null;
      } else if (_questionIndex == 1) {
        _q2Input = '';
        _q2IsCorrect = null;
      } else if (_questionIndex == 2) {
        _q3SelectedOption = null;
        _q3IsCorrect = null;
      } else if (_questionIndex == 3) {
        _q4SelectedOption = null;
        _q4IsCorrect = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE7E497), // Warna latar belakang utama.
        body: SafeArea(
          // IndexedStack digunakan untuk menampilkan satu dari tiga widget pertanyaan
          // berdasarkan `_questionIndex`.
          child: IndexedStack(
            index: _questionIndex,
            children: [
              _buildQuestion1(), // Tampilan untuk pertanyaan 1.
              _buildQuestion2(), // Tampilan untuk pertanyaan 2.
              _buildQuestion3(), // Tampilan untuk pertanyaan 3.
              _buildQuestion4(), // Tampilan untuk pertanyaan 4.
            ],
          ),
        ));
  }

  // ============== Pertanyaan 1 (Pilihan Gambar Grid) ============== // 
  void _onQ1OptionSelected(_ImageOption option) {
    if (_q1SelectedOption != null) return; // Mencegah pemilihan ulang.
    setState(() {
      _q1SelectedOption = option;
      _q1IsCorrect = option.name == _q1CorrectAnswer;
      if (_q1IsCorrect == true) {
        _playSound('menang.mp3'); // Suara jika benar.
      } else {
        _playSound('kalah.mp3'); // Suara jika salah.
      }
    });
  }

  Widget _buildQuestion1() {
    return Column(
      children: [
        _buildHeader(0.25), // Menampilkan header dengan progress bar.
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('CULUK', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF3D3A3A))),
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.9),
                    itemCount: _q1Options.length,
                    itemBuilder: (context, index) {
                      final option = _q1Options[index];
                      bool isSelected = _q1SelectedOption?.name == option.name;
                      // Mengubah warna border berdasarkan status jawaban (benar/salah).
                      Color borderColor = Colors.transparent;
                      if (isSelected) {
                        borderColor = _q1IsCorrect == true ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
                      }
                      return GestureDetector(
                        onTap: () => _onQ1OptionSelected(option),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFddb200),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: isSelected ? 4 : 0),
                            boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 8)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(option.imagePath, fit: BoxFit.contain),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Menampilkan banner feedback (benar/salah) setelah pengguna menjawab.
        if (_q1IsCorrect != null) 
          _buildFeedbackBanner(
            isCorrect: _q1IsCorrect!,
            correctText: 'BENAR',
            wrongText: 'SALAH',
            buttonText: _q1IsCorrect! ? 'LANJUT' : 'COBA LAGI',
            onButtonPressed: _q1IsCorrect! ? _next : _resetCurrent,
          ),
      ],
    ); 
  }

  // ============== Pertanyaan 2 (Melengkapi Kata) ============== //
  // Menambahkan karakter ke input.
  void _onQ2CharInput(String char) {
    int emptySlots = _question2.correctAnswer.length - _question2.prefilledLetters.length;
    if (_q2Input.length < emptySlots) {
      setState(() {
        _q2Input += char;
      });
    }
  }

  // Menghapus karakter terakhir dari input.
  void _onQ2Backspace() {
    if (_q2Input.isNotEmpty) {
      setState(() {
        _q2Input = _q2Input.substring(0, _q2Input.length - 1);
      });
    }
  }

  // Memeriksa apakah jawaban yang diinput benar.
  void _checkQ2Answer() {
    List<String> answerList = List.filled(_question2.correctAnswer.length, '');
    int inputIndex = 0;
    // Menggabungkan huruf yang sudah diisi dengan input pengguna.
    for (int i = 0; i < _question2.correctAnswer.length; i++) {
      if (_question2.prefilledLetters.containsKey(i)) {
        answerList[i] = _question2.prefilledLetters[i]!;
      } else {
        if (inputIndex < _q2Input.length) {
          answerList[i] = _q2Input[inputIndex];
          inputIndex++;
        }
      }
    }
    String finalAnswer = answerList.join('');
    setState(() {
      _q2IsCorrect = (finalAnswer.toUpperCase() == _question2.correctAnswer);
      if (_q2IsCorrect == true) {
        _playSound('menang.mp3');
      } else {
        _playSound('kalah.mp3');
      }
    });
  }

  Widget _buildQuestion2() {
    return Column(
      children: [
        _buildHeader(0.5), // Header dengan progress 50%.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(_question2.title, style: const TextStyle(fontSize: 18, color: Color(0xFF3D3A3A))),
                            const SizedBox(height: 10),
                            Text(_question2.word, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF3D3A3A))),
                            const SizedBox(height: 30),
                            _buildInputBoxes(), // Kotak-kotak untuk input huruf.
                          ],
                        ),
                        Column(
                          children: [
                            _buildKeyboard(), // Keyboard virtual.
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                // Tombol "CHECK" hanya aktif jika semua kotak terisi.
                                onPressed: _q2Input.length == (_question2.correctAnswer.length - _question2.prefilledLetters.length)
                                    ? _checkQ2Answer
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDDB200), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                child: const Text('CHECK'),
                              ), 
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Menampilkan banner feedback.
        if (_q2IsCorrect != null) 
          _buildFeedbackBanner(
            isCorrect: _q2IsCorrect!,
            correctText: 'BENAR',
            wrongText: 'SALAH',
            buttonText: _q2IsCorrect! ? 'LANJUT' : 'COBA LAGI',
            onButtonPressed: _q2IsCorrect! ? _next : _resetCurrent,
          ),
      ],
    );
  }

  // Membuat kotak-kotak input untuk pertanyaan melengkapi kata.
  Widget _buildInputBoxes() {
    List<Widget> boxes = [];
    int inputIndex = 0;
    for (int i = 0; i < _question2.correctAnswer.length; i++) {
      String text;
      // Mengisi kotak dengan huruf yang sudah ada atau dari input pengguna.
      if (_question2.prefilledLetters.containsKey(i)) {
        text = _question2.prefilledLetters[i]!;
      } else {
        text = (inputIndex < _q2Input.length) ? _q2Input[inputIndex++] : '';
      }
      boxes.add(
        Container(
          width: 50, height: 50, margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: const Color(0xFFDDB200), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: boxes);
  }

  // Membuat keyboard virtual.
  Widget _buildKeyboard() {
    final bool isInputFull = _q2Input.length >= (_question2.correctAnswer.length - _question2.prefilledLetters.length);
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: 'QWERTYUIOP'.split('').map((e) => _buildKey(e, isInputFull)).toList()),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: 'ASDFGHJKL'.split('').map((e) => _buildKey(e, isInputFull)).toList()),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [... 'ZXCVBNM'.split('').map((e) => _buildKey(e, isInputFull)), _buildKey('⌫', false, onTap: _onQ2Backspace)]),
      ],
    );
  }

  // Membuat satu tombol keyboard.
  Widget _buildKey(String char, bool isInputFull, {VoidCallback? onTap}) {
    // Tombol dinonaktifkan jika input sudah penuh.
    final bool isDisabled = isInputFull && onTap == null;
    return Expanded(
      child: InkWell(
        onTap: isDisabled ? null : (onTap ?? () => _onQ2CharInput(char)),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            height: 50, margin: const EdgeInsets.all(2), 
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(char, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );
  }
  
  // ============== Pertanyaan 3 (Pilihan Ganda Teks) ============== // 

  void _onQ3OptionSelected(String option) {
    if (_q3SelectedOption != null) return; // Mencegah pemilihan ulang.
    setState(() {
      _q3SelectedOption = option;
      _q3IsCorrect = option == _question3.correctAnswer;
      if (_q3IsCorrect == true) {
        _playSound('menang.mp3');
      } else {
        _playSound('kalah.mp3');
      }
    });
  }

  Widget _buildQuestion3() {
    return Column(
      children: [
        _buildHeader(0.75), // Header dengan progress 75%.
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_question3.title, style: const TextStyle(fontSize: 22, color: Color(0xFF3D3A3A), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFddb200),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Image.asset(_question3.imagePath, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 2.5),
                    itemCount: _question3.options.length,
                    itemBuilder: (context, index) {
                      final option = _question3.options[index];
                      bool isSelected = _q3SelectedOption == option;
                      // Mengubah warna tombol berdasarkan status jawaban.
                      Color? buttonColor;
                      if (isSelected) {
                        buttonColor = _q3IsCorrect == true ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                      }
                      return ElevatedButton(
                        onPressed: () => _onQ3OptionSelected(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor ?? const Color(0xFFddb200),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        child: Text(option),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Menampilkan banner feedback.
        if (_q3IsCorrect != null)
          _buildFeedbackBanner(
            isCorrect: _q3IsCorrect!,
            correctText: 'BENAR',
            wrongText: 'SALAH',
            buttonText: _q3IsCorrect! ? 'LANJUT' : 'COBA LAGI',
            onButtonPressed: _q3IsCorrect! ? _next : _resetCurrent,
          ),
      ],
    );
  }

  // ============== Pertanyaan 4 (Pilihan Ganda Teks) ============== // 

  void _onQ4OptionSelected(String option) {
    if (_q4SelectedOption != null) return; // Mencegah pemilihan ulang.
    setState(() {
      _q4SelectedOption = option;
      _q4IsCorrect = option == _question4.correctAnswer;
      if (_q4IsCorrect == true) {
        _playSound('menang.mp3');
      } else {
        _playSound('kalah.mp3');
      }
    });
  }

  Widget _buildQuestion4() {
    return Column(
      children: [
        _buildHeader(1.0), // Header dengan progress 100%.
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(_question4.title, style: const TextStyle(fontSize: 22, color: Color(0xFF3D3A3A), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    height: 100, // Adjusted height for this image
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFddb200),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Image.asset(_question4.imagePath, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 2.5),
                    itemCount: _question4.options.length,
                    itemBuilder: (context, index) {
                      final option = _question4.options[index];
                      bool isSelected = _q4SelectedOption == option;
                      // Mengubah warna tombol berdasarkan status jawaban.
                      Color? buttonColor;
                      if (isSelected) {
                         buttonColor = _q4IsCorrect == true ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                      } else {
                        buttonColor = const Color(0xFFddb200);
                      }

                      if(isSelected && _q4IsCorrect == true) {
                        buttonColor = Colors.green;
                      } else if (isSelected && _q4IsCorrect == false) {
                        buttonColor = Colors.red;
                      }

                      return ElevatedButton(
                        onPressed: () => _onQ4OptionSelected(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        child: Text(option),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Menampilkan banner feedback.
        // === PERUBAHAN LOGIKA DI SINI ===
        if (_q4IsCorrect != null)
          _buildFeedbackBanner(
            isCorrect: _q4IsCorrect!,
            correctText: 'BENAR',
            wrongText: 'SALAH',
            buttonText: _q4IsCorrect! ? 'SELESAI' : 'COBA LAGI',
            // Jika benar, panggil Navigator.pop dengan nilai 'true'.
            // Jika salah, panggil _resetCurrent seperti biasa.
            onButtonPressed: _q4IsCorrect! 
                ? () => Navigator.of(context).pop(true) 
                : _resetCurrent,
          ),
      ],
    );
  }
  // ============== Widget Umum ============== // 

  // Membuat header yang berisi tombol kembali dan progress bar.
  Widget _buildHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF3D3A3A), size: 30), onPressed: () => Navigator.of(context).pop()),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: Colors.black12, color: const Color(0xFF615E5E)),
            ),
          ),
        ],
      ),
    );
  }

  // Membuat banner feedback di bagian bawah layar.
  Widget _buildFeedbackBanner({
    required bool isCorrect,
    required String correctText,
    required String wrongText,
    String wrongSubText = '',
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      // Warna banner berubah sesuai jawaban (hijau untuk benar, merah untuk salah).
      decoration: BoxDecoration(color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isCorrect ? correctText : wrongText,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (!isCorrect && wrongSubText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(wrongSubText, style: const TextStyle(color: Colors.white70, fontSize: 18)),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, 
                foregroundColor: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
