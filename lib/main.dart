import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vivacissimo/screen/playlist/playlist_new.dart';
import 'package:vivacissimo/services/vivacissimo_service.dart';
import 'package:vivacissimo/widgets/constants.dart';

Future<void> main() async {
  // await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<void> yes() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      print(file.path);
    } else {
      // User canceled the picker
    }

  }

  @override
  Widget build(BuildContext context) {

    // test();
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: AppColor.backgroundColor),
      home: PlaylistNew(),
    );
  }
}
