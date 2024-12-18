import 'package:flutter/material.dart';
import '../../dummy_data/data.dart';
import '../../models/entity.dart';
import '../../widgets/commons.dart';
import '../../widgets/constants.dart';
import '../../widgets/tag_grid.dart';
import '../../models/tag.dart';

class PlaylistNew extends StatefulWidget {
  const PlaylistNew({super.key});

  @override
  State<PlaylistNew> createState() => _PlaylistNewState();
}

class _PlaylistNewState extends State<PlaylistNew> {
  final List<Entity> references = [];
  Entity? target;

  Set<(Tag, bool?)> _getTags() {
    Set<(Tag, bool?)> tags = {};
    if (target == null) return tags;
    if (target is Release) {
      Release yes = target as Release;
      for (Tag tag in yes.tagIds) {
        tags.add((tag, null));
      }
    }
    return tags;
  }

  int index = 0;

  void onAdd() {
    switch (index) {
      case 0:
        references.add(badApple);
        break;
      case 1:
        references.add(alterEgo);
        break;
      case 2:
        break;
    }
    setState(() {});
    index = index + 1;
  }

  @override
  Widget build(BuildContext context) {
    Set<(Tag, bool?)> tags = _getTags();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const TitleText('References'),
            const SizedBox(height: 8),
            ReferenceList(
                references: references,
                onEntityTap: (entity) => setState(() {
                      if (entity == target) {
                        target = null;
                      } else {
                        target = entity;
                      }
                    }),
                onAdd: onAdd),
            const SizedBox(height: 8),
            const TitleText('Advanced Configure'),
            const SizedBox(height: 8),
            TagGrid(
              name: "Genre",
              tags: tags.where((tag) => tag.$1.type == TagType.genre),
              onTagTap: (p0, p1) => (),
            ),
            TagGrid(
              name: "Sub-Genre",
              tags: tags.where((tag) => tag.$1.type == TagType.subGenre),
              onTagTap: (p0, p1) => (),
            ),
            TagGrid(
              name: "Language",
              tags: tags.where((tag) => tag.$1.type == TagType.language),
              onTagTap: (p0, p1) => (),
            ),
            TagGrid(
              name: "Vibe",
              tags: tags.where((tag) => tag.$1.type == TagType.vibe),
              onTagTap: (p0, p1) => (),
            ),
            TagGrid(
              name: "Instruments",
              tags: tags.where((tag) => tag.$1.type == TagType.instruments),
              onTagTap: (p0, p1) => (),
            ),
            TagGrid(
              name: "Vocals",
              tags: tags.where((tag) => tag.$1.type == TagType.vocals),
              onTagTap: (p0, p1) => (),
            ),
            TagGrid(
              name: "Tempo",
              tags: tags.where((tag) => tag.$1.type == TagType.tempo),
              onTagTap: (p0, p1) => (),
            ),
            TagGrid(
              name: "Other",
              tags: tags.where((tag) => tag.$1.type == TagType.other),
              onTagTap: (p0, p1) => (),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class ReferenceList extends StatelessWidget {
  final List<Entity> references;
  final void Function(Entity) onEntityTap;
  final void Function() onAdd;

  static const double itemHeight = 98;

  const ReferenceList({
    super.key,
    required this.references,
    required this.onEntityTap,
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
      return GestureDetector(
        onTap: () => onEntityTap(item),
        child: Container(
          width: itemHeight,
          height: itemHeight,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset(item.image).image,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: AppColor.borderColor),
          ),
          child: Image.asset(
            item.image,
            fit: BoxFit.cover,
          ),
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
