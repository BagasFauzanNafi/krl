import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:schedule_generator/screen/home/home_screen.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Inisialisasi Hive tanpa path_provider
  await Hive.openBox('historyBox');
  runApp(
    DevicePreview(
      enabled: false, 
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder, 
      useInheritedMediaQuery: true, 
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
