import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vivacissimo/screen/home.dart';
import 'package:vivacissimo/services/vivacissimo.dart';
import 'package:vivacissimo/widgets/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Vivacissimo.loadData();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.backgroundColor,
        primaryColor: AppColor.primaryColor,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: AppColor.primaryColor,
          backgroundColor: AppColor.backgroundColor,
          errorColor: AppColor.errorColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
