// Impor library utama Flutter.
import 'package:flutter/material.dart';
// Impor halaman kuis level 2.
import 'package:myapp/level2_quiz_screen.dart';
// Impor halaman kuis level 3.
import 'package:myapp/level3_quiz_screen.dart';
// Impor halaman belajar.
import 'package:myapp/learn_screen.dart';

// 🔹 UBAH KE STATEFULWIDGET
// Kita mengubah ini menjadi StatefulWidget agar bisa merubah warna Level 2
// secara dinamis setelah Level 1 selesai.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel untuk melacak level tertinggi yang terbuka.
  // Awalnya level 1.
  int _unlockedLevel = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E497),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Judul Aplikasi
              const Text(
                'Kilas Bahasa Lampung',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA50000),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Kartu Sapaan
              _buildGreetingCard(),

              const SizedBox(height: 40),

              // =======================================================
              // 🔹 LEVEL 1 (Selalu Terbuka)
              // =======================================================
              GestureDetector(
                onTap: () async {
                  // Kita menggunakan 'await' untuk menunggu hasil dari LearnScreen.
                  // Jika LearnScreen mengirim balik 'true', artinya level selesai.
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LearnScreen()),
                  );

                  // Jika hasilnya true, kita buka Level 2.
                  if (result == true) {
                    setState(() {
                      // Ubah _unlockedLevel menjadi 2 jika belum mencapai 2.
                      if (_unlockedLevel < 2) {
                        _unlockedLevel = 2;
                      }
                    });

                    // (Opsional) Tampilkan pesan kecil
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Selamat! Level 2 Terbuka!")),
                    );
                  }
                },
                child: _buildLevelIndicator(
                  level: '1',
                  // Level 1 warnanya selalu merah (aktif).
                  color: const Color(0xFFA50000),
                  imagePath: 'assets/images/tiger.png',
                ),
              ),

              const SizedBox(height: 20),

              // =======================================================
              // 🔹 LEVEL 2 (Terkunci Awalnya)
              // =======================================================
              GestureDetector(
                onTap: _unlockedLevel >= 2
                    ? () async {
                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Level2QuizScreen()),
                        );

                        if (result == true) {
                          setState(() {
                            if (_unlockedLevel < 3) {
                              _unlockedLevel = 3;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Hebat! Level 3 Terbuka!")),
                          );
                        }
                      }
                    : null,
                child: _buildLevelIndicator(
                  level: '2',
                  color: _unlockedLevel >= 2
                      ? const Color(0xFFA50000)
                      : const Color(0xFF4C4545),
                  imagePath: 'assets/images/elephant.png',
                  isLeftAligned: false,
                ),
              ),

              const SizedBox(height: 20),

              // =======================================================
              // 🔹 LEVEL 3 (Terkunci Awalnya)
              // =======================================================
              GestureDetector(
                onTap: _unlockedLevel >= 3
                    ? () async {
                        // Navigasi ke Level 3
                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Level3QuizScreen()),
                        );

                        // Di sini Anda bisa menangani apa yang terjadi setelah Level 3 selesai,
                        // misalnya membuka Level 4.
                        if (result == true) {
                          setState(() {
                             if (_unlockedLevel < 4) {
                              _unlockedLevel = 4;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Luar Biasa! Sampai jumpa di level selanjutnya!")),
                          );
                        }
                      }
                    : null, // Jika level belum terbuka, onTap null (tidak bisa diklik)
                child: _buildLevelIndicator(
                  level: '3',
                  // Ganti warna berdasarkan status terkunci/terbuka
                  color: _unlockedLevel >= 3
                      ? const Color(0xFFA50000)
                      : const Color(0xFF4C4545),
                  imagePath: 'assets/images/rhino.png',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // 🔸 Widget Kartu Sapaan (Tidak Berubah)
  // =====================================================================
  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDB200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Image(image: AssetImage('assets/images/logo.png')),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tabik Pun 👋',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA50000),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 🔸 Widget Indikator Level (Tidak Berubah)
  // =====================================================================
  Widget _buildLevelIndicator({
    required String level,
    required Color color,
    required String imagePath,
    bool isLeftAligned = true,
  }) {
    final levelCircle = Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'Level $level',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final animalImage = Image.asset(
      imagePath,
      width: 100,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.pets, size: 50, color: Colors.grey);
      },
    );

    return Align(
      alignment: isLeftAligned ? Alignment.centerLeft : Alignment.centerRight,
      child: SizedBox(
        width: 200,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLeftAligned) ...[
              Positioned(left: 0, child: levelCircle),
              Positioned(right: 0, bottom: 0, child: animalImage),
            ] else ...[
              Positioned(right: 0, child: levelCircle),
              Positioned(left: 0, bottom: 0, child: animalImage),
            ]
          ],
        ),
      ),
    );
  }
}
