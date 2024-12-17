import 'package:flutter/material.dart';
import 'constants.dart';

abstract class AppText extends StatelessWidget {
  final String data;
  const AppText(
    this.data, {
    super.key,
  });

  TextStyle style();

  @override
  Widget build(BuildContext context) {
    return Text(data, style: style());
  }
}

class TitleText extends AppText {
  const TitleText(
    super.data, {
    super.key,
  });

  @override
  TextStyle style() {
    return const TextStyle(
      fontSize: AppFontSize.title,
      color: AppColor.textColor,
    );
  }
}

class BodyText extends AppText {
  const BodyText(
    super.data, {
    super.key,
  });

  @override
  TextStyle style() {
    return const TextStyle(
      fontSize: AppFontSize.body,
      color: AppColor.textColor,
    );
  }
}
