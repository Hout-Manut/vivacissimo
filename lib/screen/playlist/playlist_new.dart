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
  final Map<Tag, bool> selectedTags = {};
  Entity? target;

  Set<(Tag, bool?)> _getTags() {
    Set<(Tag, bool?)> tags = {};
    Set<Tag> selected = selectedTags.keys.toSet();
    selectedTags.forEach((key, value) => tags.add((key, value)));
    if (target == null) return tags;
    if (target is Release) {
      Release yes = target as Release;
      for (Tag tag in yes.tags) {
        if (!selected.contains(tag)) tags.add((tag, null));
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

  List<(Tag, bool?)> _filterAndSortTags(Set<(Tag, bool?)> tags, TagType type) {
    return tags.where((tag) => tag.$1.type == type).toList()
      ..sort((a, b) {
        if (a.$2 == b.$2) return 0;
        if (a.$2 == true) return -1;
        if (b.$2 == true) return 1;
        if (a.$2 == false) return -1;
        if (b.$2 == false) return 1;
        return 0;
      });
  }

  void onTagTap(Tag target) {
    if (selectedTags.containsKey(target)) {
      if (selectedTags[target]!) {
        selectedTags[target] = false;
      } else {
        selectedTags.remove(target);
      }
    } else {
      selectedTags[target] = true;
    }

    setState(() {});
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
              tags: _filterAndSortTags(tags, TagType.genre),
              onTagTap: onTagTap,
            ),
            TagGrid(
              name: "Sub-Genre",
              tags: _filterAndSortTags(tags, TagType.subGenre),
              onTagTap: onTagTap,
            ),
            TagGrid(
              name: "Language",
              tags: _filterAndSortTags(tags, TagType.language),
              onTagTap: onTagTap,
            ),
            TagGrid(
              name: "Vibe",
              tags: _filterAndSortTags(tags, TagType.vibe),
              onTagTap: onTagTap,
            ),
            TagGrid(
              name: "Instruments",
              tags: _filterAndSortTags(tags, TagType.instruments),
              onTagTap: onTagTap,
            ),
            TagGrid(
              name: "Vocals",
              tags: _filterAndSortTags(tags, TagType.vocals),
              onTagTap: onTagTap,
            ),
            TagGrid(
              name: "Tempo",
              tags: _filterAndSortTags(tags, TagType.tempo),
              onTagTap: onTagTap,
            ),
            TagGrid(
              name: "Other",
              tags: _filterAndSortTags(tags, TagType.other),
              onTagTap: onTagTap,
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
