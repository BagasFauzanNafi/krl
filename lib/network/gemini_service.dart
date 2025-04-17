import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  static const String apiKey = 'AIzaSyDw0vBA2jmQ189UQ9riQglKYhVcbShu0HA';

  static Future<Map<String, dynamic>> getKRLSchedule(
      String stasiunAwal, String stasiunAkhir) async {
    final prompt = _buildPrompt(stasiunAwal, stasiunAkhir);
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.9,
        maxOutputTokens: 2048,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat(history: [
      Content.multi([
        TextPart(
            'Kamu adalah AI yang ahli dalam transportasi KRL di Jakarta. '
            'Ketika pengguna menyebutkan stasiun awal dan stasiun akhir, '
            'berikan jadwal KRL dan harga tiket dalam format JSON dengan format berikut:\n\n'
            '```json\n'
            '{\n'
            '  "stasiun_awal": "<stasiun_awal>",\n'
            '  "stasiun_akhir": "<stasiun_akhir>",\n'
            '  "harga": "<harga>",\n'
            '  "jadwal": [\n'
            '    "⏰ <jadwal 1>",\n'
            '    "⏰ <jadwal 2>"\n'
            '  ]\n'
            '}\n'
            '```\n'
            '⚠️ **Jangan berikan teks tambahan di luar JSON!**'),
      ]),
    ]);

    try {
      final response = await chat.sendMessage(Content.text(prompt));
      final responseText =
          (response.candidates.first.content.parts.first as TextPart).text;

      print("Raw API Response: $responseText");

      if (responseText.isEmpty) {
        return {"error": "Respon kosong dari AI."};
      }

      final jsonMatch =
          RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(responseText);

      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(1)!);
      }

      return jsonDecode(responseText);
    } catch (e) {
      return {"error": "Gagal mendapatkan jadwal KRL: $e"};
    }
  }

  static String _buildPrompt(String stasiunAwal, String stasiunAkhir) {
    return "Saya ingin mencari jadwal KRL dari **$stasiunAwal** ke **$stasiunAkhir**.\n"
        "Berikan daftar jadwal KRL dan harga tiket dalam format JSON valid dengan format berikut:\n"
        "```json\n"
        "{\n"
        '  "stasiun_awal": "<stasiun_awal>",\n'
        '  "stasiun_akhir": "<stasiun_akhir>",\n'
        '  "harga": "<harga>",\n'
        '  "jadwal": [\n'
        '    "⏰ <jadwal 1>",\n'
        '    "⏰ <jadwal 2>"\n'
        '  ]\n'
        "}\n"
        "```\n"
        "⚠️ **Jangan berikan teks tambahan di luar JSON!**";
  }
}
