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

class LargeTitleText extends AppText {
  const LargeTitleText(
    super.data, {
    super.key,
  });

  @override
  TextStyle style() {
    return const TextStyle(
      fontSize: AppFontSize.titleLarge,
      color: AppColor.textColor,
    );
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
      overflow: TextOverflow.ellipsis,
    );
  }
}

class SubText extends AppText {
  const SubText(
    super.data, {
    super.key,
  });

  @override
  TextStyle style() {
    return const TextStyle(
      fontSize: AppFontSize.caption,
      color: AppColor.textSecondaryColor,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class AppButton extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final bool selected;

  const AppButton({
    super.key,
    required this.onTap,
    required this.child,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColor.buttonSelectedColor : AppColor.buttonColor,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 48,
          height: 32,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
