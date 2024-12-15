import 'package:flutter/material.dart';
import 'package:vivacissimo/dummy_data/data.dart';
import 'package:vivacissimo/model/entity/entity.dart';
import 'package:vivacissimo/model/entity/release.dart';
import 'package:vivacissimo/widgets/commons.dart';
import 'package:vivacissimo/widgets/constants.dart';
import 'package:vivacissimo/widgets/tag_grid.dart';
import 'package:vivacissimo/model/tag.dart';

class PlaylistNew extends StatefulWidget {
  const PlaylistNew({super.key});

  @override
  State<PlaylistNew> createState() => _PlaylistNewState();
}

class _PlaylistNewState extends State<PlaylistNew> {
  final List<Entity> references = [];

  List<Tag> _getTags() {
    List<Tag> tags = [];
    for (Entity item in references) {
      if (item is Release) {
        tags.addAll(item.tags);
      }
    }
    return tags.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TitleText(data: 'References'),
            const SizedBox(height: 8),
            ReferenceList(
              references: references,
              onAdd: () {
                setState(() => references.add(badApple));
              },
            ),
            const SizedBox(height: 8),
            const TitleText(data: 'Advanced Configure'),
            const SizedBox(height: 8),
            TagGrid(tags: _getTags(), name: "Tags")
          ],
        ),
      ),
    );
  }
}

class ReferenceList extends StatelessWidget {
  final List<Entity> references;
  final void Function() onAdd;

  static const double itemHeight = 98;

  const ReferenceList({
    super.key,
    required this.references,
    required this.onAdd,
  });

  Widget _buildList(BuildContext context, int index) {
    if (index == references.length) {
      return SizedBox(
        height: itemHeight,
        child: Center(
          child: IconButton(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add,
              size: AppFontSize.title,
              color: AppColor.textColor,
            ),
          ),
        ),
      );
    }
    dynamic item = references[index];

    if (item is Release) {
      return Container(
        width: itemHeight,
        height: itemHeight,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset(item.image).image,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: AppColor.borderColor),
        ),
        child: Image.asset(
          item.image,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: references.length + 1,
        itemBuilder: _buildList,
      ),
    );
  }
}
