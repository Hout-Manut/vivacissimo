import 'package:flutter/material.dart';
import 'package:vivacissimo/widgets/constants.dart';

abstract class AppText extends StatelessWidget {
  final String data;
  const AppText({super.key, required this.data});

  TextStyle style() {
    return const TextStyle(
      fontSize: AppFontSize.body,
      color: AppColor.textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(data, style: style());
  }
}

class TitleText extends AppText {
  const TitleText({super.key, required super.data});

  @override
  TextStyle style() {
    return const TextStyle(
      fontSize: AppFontSize.title,
      color: AppColor.textColor,
    );
  }
}
