import 'package:flutter/material.dart';
import 'package:vivacissimo/widgets/constants.dart';

import 'screen/playlist/playlist_new.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: AppColor.backgroundColor),
      home: const PlaylistNew(),
    );
  }
}
