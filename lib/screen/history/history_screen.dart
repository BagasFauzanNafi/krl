import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:schedule_generator/model/history_model.dart';
import 'package:schedule_generator/screen/history/history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box('historyBox');
  }

  void deleteHistory(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Riwayat"),
        content: const Text("Apakah Anda yakin ingin menghapus riwayat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                historyBox.deleteAt(index);
              });
              Navigator.pop(context); // Tutup dialog setelah menghapus
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pencarian KRL'),
        backgroundColor: const Color.fromARGB(255, 255, 46, 46),
      ),
      body: historyBox.isEmpty
          ? const Center(
              child: Text(
                "Belum ada riwayat pencarian.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: historyBox.length,
              itemBuilder: (context, index) {
                final data = HistoryModel.fromMap(
                  Map<String, dynamic>.from(historyBox.getAt(index)),
                );

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.train, size: 40, color: Color.fromARGB(255, 255, 49, 49)),
                    title: Text(
                      "${data.stasiunAwal} → ${data.stasiunAkhir}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryDetailScreen(history: data),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteHistory(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
