import 'package:flutter/material.dart';
import 'package:schedule_generator/model/history_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryModel history;

  const HistoryDetailScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${history.stasiunAwal} → ${history.stasiunAkhir}"),
        backgroundColor: const Color.fromARGB(255, 255, 25, 25),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jadwal Keberangkatan:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (history.jadwal.isNotEmpty)
                Column(
                  children: history.jadwal
                      .map((item) => Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.train, color: Color.fromARGB(255, 255, 30, 30)),
                              title: Text(item, style: const TextStyle(fontSize: 18)),
                            ),
                          ))
                      .toList(),
                )
              else
                const Text("Tidak ada jadwal tersedia."),
            ],
          ),
        ),
      ),
    );
  }
}
