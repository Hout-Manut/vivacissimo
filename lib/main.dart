import 'package:flutter/material.dart';
import 'screen/playlist/home.dart';
import 'widgets/constants.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: AppColor.backgroundColor),
      home: HomeScreen(),
    );
  }
}
