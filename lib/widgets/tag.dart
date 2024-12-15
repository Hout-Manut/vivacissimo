import 'package:flutter/material.dart';
import 'package:vivacissimo/model/tag.dart';
import 'constants.dart';

class TagPill extends StatelessWidget {
  final Tag tag;
  final void Function()? onTap;
  final bool? selected;
  final bool deleting;

  const TagPill({
    super.key,
    required this.tag,
    this.onTap,
    this.selected,
    this.deleting = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (selected == null) {
      color = AppColor.buttonColor;
    } else if (selected!) {
      color = AppColor.buttonActiveColor;
    } else {
      color = AppColor.buttonInactiveColor;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x80000000)),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
              child: Text(
                tag.name,
                style: const TextStyle(
                  color: AppColor.textColor,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedTagPill extends StatelessWidget {
  final Animation<double> animation;
  final Tag tag;
  final void Function()? onTap;
  final bool? selected;
  final bool deleting;

  const AnimatedTagPill({
    super.key,
    required this.tag,
    this.onTap,
    this.selected,
    required this.animation,
    this.deleting = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (selected == null) {
      color = AppColor.buttonColor;
    } else if (selected!) {
      color = AppColor.buttonActiveColor;
    } else {
      color = AppColor.buttonInactiveColor;
    }

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x80000000)),
            ),
            child: Text(
              tag.name,
              style: const TextStyle(
                color: AppColor.textColor,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
