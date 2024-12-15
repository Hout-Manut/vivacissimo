import 'package:flutter/material.dart';
import 'package:vivacissimo/model/tag.dart';
import 'package:vivacissimo/widgets/tag.dart';
import 'package:vivacissimo/widgets/constants.dart';

class TagGrid extends StatefulWidget {
  final String? name;
  final List<Tag> tags;

  const TagGrid({
    super.key,
    this.name,
    required this.tags,
  });

  @override
  State<TagGrid> createState() => _TagGridState();
}

class _TagGridState extends State<TagGrid> {
  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    return AnimatedTagPill(tag: widget.tags[index], animation: animation);
  }

  Widget _buildGrid(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: widget.tags.map<Widget>((tag) {
        return TagPill(tag: tag);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.name != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            widget.name!,
            style: const TextStyle(
              fontSize: AppFontSize.body,
              color: AppColor.textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildGrid(context),
        ],
      );
    } else {
      return _buildGrid(context);
    }
  }
}

class DraggableTagGrid extends TagGrid {
  const DraggableTagGrid({
    super.key,
    super.name,
    required super.tags,
  });

  @override
  State<DraggableTagGrid> createState() => _DraggableTagGridState();
}

class _DraggableTagGridState extends State<DraggableTagGrid> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
