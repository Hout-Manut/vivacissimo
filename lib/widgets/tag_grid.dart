import 'package:flutter/material.dart';
import '../../models/tag.dart';
import 'commons.dart';
// import 'tag.dart';
import 'constants.dart';

class TagGrid extends StatefulWidget {
  final String? name;
  final Iterable<(Tag, bool?)> tags;
  final void Function(Tag) onTagTap;

  const TagGrid(
      {super.key, this.name, required this.tags, required this.onTagTap});

  @override
  State<TagGrid> createState() => _TagGridState();
}

class _TagGridState extends State<TagGrid> {
  Iterable<(Tag, bool)> get selectedTags {
    return widget.tags.where((tag) => tag.$2 != null) as Iterable<(Tag, bool)>;
  }


  Widget _buildGrid(BuildContext context) {
    Iterable<Widget> children = widget.tags
        .map<Widget>(
          (tag) => TagPill(
            tag,
            onTap: () => widget.onTagTap(tag.$1),
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(spacing: 4.0, runSpacing: 4.0, children: [
        ...children,
        // const AddTag(),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.name != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BodyText(widget.name!),
          const SizedBox(height: 2),
          _buildGrid(context),
        ],
      );
    } else {
      return _buildGrid(context);
    }
  }
}

class AddTag extends StatelessWidget {
  const AddTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: AppColor.buttonColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x80000000)),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: AppColor.textSecondaryColor,
            size: 14.0,
          ),
        ),
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  final (Tag, bool?) tag;
  final void Function() onTap;

  const TagPill(
    this.tag, {
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (tag.$2 == null) {
      color = AppColor.buttonColor;
    } else if (tag.$2!) {
      color = AppColor.buttonActiveColor;
    } else {
      color = AppColor.buttonInactiveColor;
    }

    return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.centerLeft,
        curve: Curves.easeOutExpo,
        child: GestureDetector(
          key: ValueKey(tag.$1.id),
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(right: 2.0),
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0x80000000)),
            ),
            child: Text(
              tag.$1.name,
              style: const TextStyle(
                color: AppColor.textColor,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
    );
  }
}
