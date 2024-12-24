import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vivacissimo/services/vivacissimo.dart';
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

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onSubmitted;
  final String hintText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onSubmitted,
      controller: controller,
      style: const TextStyle(color: AppColor.textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColor.textSecondaryColor),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.textSecondaryColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.primaryColor),
        ),
      ),
    );
  }
}

class AssetOrFileImage extends StatelessWidget {
  final String imageName; // The image file name
  final bool isAsset; // Whether the image is an asset or a file
  final double? width; // Width of the image
  final double? height; // Height of the image
  final BoxFit fit; // BoxFit for the image
  final double borderRadius;

  const AssetOrFileImage({
    super.key,
    required this.imageName,
    required this.isAsset,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  Future<Widget> _loadImage() async {
    if (isAsset) {
      return Image.asset(
        imageName,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      final Directory? appDirectory =
          await Vivacissimo.getAppDirectory('/images');
      if (appDirectory == null) return const Icon(Icons.image_not_supported);
      final filePath = '${appDirectory.path}/$imageName';
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.grey.shade200,
    );
    return AspectRatio(
      aspectRatio: 1.0,
      child: FutureBuilder<Widget>(
        future: _loadImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: width,
              height: height,
              decoration: decoration,
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Container(
              width: width,
              height: height,
              decoration: decoration,
              child: const Center(child: Icon(Icons.error)),
            );
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return Container(
              width: width,
              height: height,
              decoration: decoration,
            );
          }
        },
      ),
    );
  }
}
