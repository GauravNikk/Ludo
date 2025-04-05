import 'package:aag_user/controllers/game_controller.dart';
import 'package:aag_user/screens/waiting_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize the game controller globally
  Get.put(GameController());

  runApp(const LudoApp());
}

class LudoApp extends StatelessWidget {
  const LudoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ludo Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WaitingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
