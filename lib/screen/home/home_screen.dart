import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_generator/model/history_model.dart';
import 'package:schedule_generator/network/gemini_service.dart';
import 'package:schedule_generator/screen/history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? errorMessage;
  final TextEditingController _stasiunAwalController = TextEditingController();
  final TextEditingController _stasiunAkhirController = TextEditingController();
  List<String> jadwalKRL = [];

  Future<void> generateSchedule() async {
    if (_stasiunAwalController.text.isEmpty || _stasiunAkhirController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      errorMessage = null;
      jadwalKRL.clear();
    });

    try {
      final result = await GeminiServices.getKRLSchedule(
        _stasiunAwalController.text,
        _stasiunAkhirController.text,
      );

      if (result.containsKey('error')) {
        setState(() {
          _isLoading = false;
          errorMessage = result['error'];
        });
        return;
      }

      setState(() {
        jadwalKRL = List<String>.from(result['jadwal'] ?? []);
        _isLoading = false;
      });

      final box = Hive.box('historyBox');
      final history = HistoryModel(
        stasiunAwal: _stasiunAwalController.text,
        stasiunAkhir: _stasiunAkhirController.text,
        jadwal: jadwalKRL,
      );
      box.add(history.toMap());
    } catch (e) {
      setState(() {
        _isLoading = false;
        errorMessage = 'Gagal mendapatkan jadwal KRL\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal KRL Jakarta'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'), // Path ke gambar
                fit: BoxFit.cover, // Sesuaikan ukuran gambar
              ),
            ),
          ),
          // Konten Utama
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _stasiunAwalController,
                          decoration: InputDecoration(
                            labelText: 'Stasiun Awal',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _stasiunAkhirController,
                          decoration: InputDecoration(
                            labelText: 'Stasiun Akhir',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : generateSchedule,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Mencari...' : 'Cari Jadwal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (jadwalKRL.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  // Informasi Harga KRL
                  _buildPriceCard("Harga KRL", "Rp 10.000"), // Harga KRL
                  const SizedBox(height: 16),
                  // Daftar Jadwal
                  _buildGlassCard("Jadwal KRL", jadwalKRL),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end, // FAB di sisi kanan layar
        children: [
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Rekomendasi'),
                  content: const Text('Fitur rekomendasi masih dalam pengembangan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.recommend),
          ),
          const SizedBox(width: 16), // Spasi antara FAB
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.history),
          ),
        ],
      ),
    );
  }

 Widget _buildGlassCard(String title, List<String> items) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded( // Pembungkusan teks otomatis
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis, // Tambahkan elipsis jika terlalu panjang
                      maxLines: 2, // Batasi maksimal 2 baris
                    ),
                  ),
                ],
              )),
        ],
      ),
    ),
  );
}


  Widget _buildPriceCard(String title, String price) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
