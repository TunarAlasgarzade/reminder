import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:reminder/pages/home_page.dart';
import 'package:reminder/services/noti_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotiService().initNotification();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}