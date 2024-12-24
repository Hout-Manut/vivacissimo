import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vivacissimo/models/playlist.dart';
import 'package:vivacissimo/screen/playlist/entity_search_modal.dart';
import 'package:vivacissimo/services/api/musicbrainz_api.dart';
import 'package:vivacissimo/services/vivacissimo.dart';
import 'package:vivacissimo/models/entity.dart';
import 'package:vivacissimo/widgets/commons.dart';
import 'package:vivacissimo/widgets/constants.dart';
import 'package:vivacissimo/widgets/tag_grid.dart';
import 'package:vivacissimo/models/tag.dart';

const Uuid uuid = Uuid();

class PlaylistNew extends StatefulWidget {
  final Playlist? editItem;
  const PlaylistNew({super.key, this.editItem});

  @override
  State<PlaylistNew> createState() => _PlaylistNewState();
}

class _PlaylistNewState extends State<PlaylistNew> {
  final List<Entity> references = [];
  final Map<Tag, bool> selectedTags = {};
  Entity? target;
  String? imageName;
  bool imageIsAsset = false;
  File? loadedImage;

  late final bool isCreating;
  late final String id;
  DateTime? createdDate;
  bool submitted = false;

  int length = 20;
  bool allowExplicit = true;
  bool? discovery;
  bool? popularity;
  String get popularityStr {
    switch (popularity) {
      case null:
        return "a mix of mainstream & obscure songs";
      case true:
        return "mostly popular and well known songs";
      case false:
        return "more unknown and less prevalent songs";
    }
  }

  TextEditingController nameController = TextEditingController();
  String get name {
    String value = nameController.text;
    if (value.isEmpty) {
      return "Unnamed Playlist";
    }
    return value;
  }

  void onSubmit() {
    List<Tag> prefer = [];
    List<Tag> notPrefer = [];
    selectedTags.forEach((key, value) {
    if (value) {
      prefer.add(key);
    } else {
      notPrefer.add(key);
    }
  });

    Playlist newPlaylist = Playlist(
      id: id,
      title: name,
      allowExplicit: allowExplicit,
      imageUrl: imageName,
      length: length,
      popularity: popularity,
      discovery: discovery,
      preferences: {
        "more": prefer,
        "less": notPrefer,
      },
      references: references,
      dateCreated: createdDate
    );
    Vivacissimo.addPlaylist(newPlaylist);
    submitted = true;
    Navigator.pop(context);
  }

  @override
  void initState() {
    if (widget.editItem != null) {
      isCreating = false;
      Playlist oldItem = widget.editItem!;

      id = oldItem.id;

      length = oldItem.length;
      allowExplicit = oldItem.allowExplicit;
      popularity = oldItem.popularity;
      discovery = oldItem.discovery;

      imageName = oldItem.imageUrl;

      nameController.text = oldItem.title;
      imageIsAsset = oldItem.imageIsAsset;

      createdDate = oldItem.dateCreated;
      references.addAll(oldItem.references);

      for (Tag oldTag in oldItem.preferences['more']!) {
        selectedTags[oldTag] = true;
      }

      for (Tag oldTag in oldItem.preferences['less']!) {
        selectedTags[oldTag] = false;
      }
      loadImage();
    } else {
      isCreating = true;
      id = uuid.v4();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (!submitted && imageName != null && !imageIsAsset) {
      Vivacissimo.deleteImage(imageName!);
    }
    nameController.dispose();
    super.dispose();
  }

  Set<(Tag, bool?)> _getTags() {
    final Set<(Tag, bool?)> tags = {
      for (final entry in selectedTags.entries) (entry.key, entry.value)
    };

    if (target != null) {
      for (final Tag tag in target!.tags) {
        if (!selectedTags.containsKey(tag)) {
          tags.add((tag, null));
        }
      }
    }

    return tags;
  }

  bool loadingTags = false;

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

  void addReference() async {
    Entity? newEntity = await showGeneralDialog<Entity>(
      context: context,
      pageBuilder: (context, animation, animation2) =>
          const EntitySearchModal(),
      barrierDismissible: true,
      barrierLabel: "",
    );

    if (newEntity != null) {
      findTags(newEntity);
      setState(() {
        loadingTags = true;
        references.add(newEntity);
      });
    }
  }

  void findTags(Entity entity) async {
    Entity? alreadyExist = Vivacissimo.getReleaseById(entity.id);
    alreadyExist ??= Vivacissimo.getArtistById(entity.id);
    if (alreadyExist == null) {
      await Vivacissimo.newEntity(entity);
    }
    setState(() {
      loadingTags = false;
    });
  }

  Future<void> addImage() async {
    await Vivacissimo.askForPermission();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      imageIsAsset = false;
      PlatformFile image = result.files.first;

      imageName = '$id.${image.extension}';
      await Vivacissimo.saveImage(image, imageName!);
      loadImage();
      setState(() {});
    } else {
      //
    }
  }

  Future<void> loadImage() async {
    if (imageIsAsset) return;
    loadedImage = await Vivacissimo.getImageFile(
      imageName!,
    );
    setState(() {});
  }

  Widget buildPlaylistImage() {
    if (imageName == null) {
      return Material(
        color: AppColor.buttonColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: addImage,
          child: const SizedBox(
            width: 98,
            child: Center(
              child: Icon(Icons.add),
            ),
          ),
        ),
      );
    }
    return AssetOrFileImage(imageName: imageName!, isAsset: imageIsAsset);
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

  Widget buildTags() {
    Set<(Tag, bool?)> tags = _getTags();

    List<Widget> tagGrids = [
      if (_filterAndSortTags(tags, TagType.genre).isNotEmpty)
        TagGrid(
          name: "Genre",
          tags: _filterAndSortTags(tags, TagType.genre),
          onTagTap: onTagTap,
        ),
      if (_filterAndSortTags(tags, TagType.subGenre).isNotEmpty)
        TagGrid(
          name: "Sub-Genre",
          tags: _filterAndSortTags(tags, TagType.subGenre),
          onTagTap: onTagTap,
        ),
      if (_filterAndSortTags(tags, TagType.language).isNotEmpty)
        TagGrid(
          name: "Language",
          tags: _filterAndSortTags(tags, TagType.language),
          onTagTap: onTagTap,
        ),
      if (_filterAndSortTags(tags, TagType.vibe).isNotEmpty)
        TagGrid(
          name: "Vibe",
          tags: _filterAndSortTags(tags, TagType.vibe),
          onTagTap: onTagTap,
        ),
      if (_filterAndSortTags(tags, TagType.instruments).isNotEmpty)
        TagGrid(
          name: "Instruments",
          tags: _filterAndSortTags(tags, TagType.instruments),
          onTagTap: onTagTap,
        ),
      if (_filterAndSortTags(tags, TagType.vocals).isNotEmpty)
        TagGrid(
          name: "Vocals",
          tags: _filterAndSortTags(tags, TagType.vocals),
          onTagTap: onTagTap,
        ),
      if (_filterAndSortTags(tags, TagType.tempo).isNotEmpty)
        TagGrid(
          name: "Tempo",
          tags: _filterAndSortTags(tags, TagType.tempo),
          onTagTap: onTagTap,
        ),
      if (_filterAndSortTags(tags, TagType.other).isNotEmpty)
        TagGrid(
          name: "Other",
          tags: _filterAndSortTags(tags, TagType.other),
          onTagTap: onTagTap,
        ),
    ];

    // Check if the tagGrids list is empty
    if (tagGrids.isEmpty) {
      return const SizedBox(
        height: 128,
        child: Text(
          "No tags found or selected, try using a reference item to see tags.",
          style: TextStyle(
            color: AppColor.textSecondaryColor,
          ),
        ),
      );
    }

    // Return a column with the non-empty tag grids
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: tagGrids,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 64),
        child: Container(
          clipBehavior: Clip.none,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                clipBehavior: Clip.none,
                children: [
                  const SizedBox(height: 32),
                  LargeTitleText(
                      isCreating ? "Create Playlist" : "Edit Playlist"),
                  const SizedBox(height: 16),
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
                      onEntityHold: (entity) => setState(() {
                            references.remove(entity);
                            if (target == entity) target = null;
                          }),
                      onAdd: addReference),
                  const SizedBox(height: 8),
                  const TitleText('Advanced Configure'),
                  const SizedBox(height: 8),
                  buildTags(),
                  const SizedBox(height: 64),
                  const TitleText('Playlist Options', key: Key("options")),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BodyText("Name"),
                      const SizedBox(height: 4),
                      AppTextField(
                          controller: nameController,
                          hintText: "The playlist name"),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(text: "Max length: "),
                                TextSpan(
                                    text: length.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppButton(
                                onTap: () => setState(() {
                                  if (length > 5) length--;
                                }),
                                child: const Icon(
                                  Icons.remove,
                                  color: AppColor.textColor,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppButton(
                                onTap: () => setState(() {
                                  if (length < 50) length++;
                                }),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColor.textColor,
                                  size: 16,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 32),
                      const BodyText("Popularity"),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 48,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColor.textSecondaryColor),
                            children: [
                              const TextSpan(
                                  text: "The playlist will include "),
                              TextSpan(
                                text: popularityStr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              onTap: () {
                                setState(() {
                                  popularity = false;
                                });
                              },
                              selected: popularity == false,
                              child: const Text(
                                "Less",
                                style: TextStyle(color: AppColor.textColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: AppButton(
                              onTap: () {
                                setState(() {
                                  popularity = null;
                                });
                              },
                              selected: popularity == null,
                              child: const Text(
                                "=",
                                style: TextStyle(color: AppColor.textColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              onTap: () {
                                setState(() {
                                  popularity = true;
                                });
                              },
                              selected: popularity == true,
                              child: const Text(
                                "More",
                                style: TextStyle(color: AppColor.textColor),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const BodyText("Image"),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 98,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        buildPlaylistImage(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 128),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Material(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColor.primaryColor,
                  child: InkWell(
                    onTap: onSubmit,
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 150,
                      height: 38,
                      child: Center(
                        child: Text(
                          isCreating ? "Create" : "Edit",
                          style: const TextStyle(
                            color: AppColor.backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReferenceList extends StatelessWidget {
  final List<Entity> references;
  final void Function(Entity) onEntityTap;
  final void Function(Entity) onEntityHold;
  final void Function() onAdd;

  static const double itemHeight = 98;

  const ReferenceList({
    super.key,
    required this.references,
    required this.onEntityTap,
    required this.onAdd,
    required this.onEntityHold,
  });

  Future<String?> getImageUrl(Entity entity) async {
    return await MusicbrainzApi.getImageUrl(entity.id);
  }

  List<Widget> buildList() {
    List<Widget> items = [];
    for (Entity entity in references) {
      switch (entity) {
        case Artist():
          // TODO: Handle this case.
          throw UnimplementedError();
        case Release():
          items.add(
            Container(
              width: itemHeight,
              height: itemHeight,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Stack(
                children: [
                  FutureBuilder(
                    initialData: const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                    future: getImageUrl(entity),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        );
                      }

                      if (snapshot.data == null || snapshot.hasError) {
                        return Image.asset(
                          'assets/playlist-placeholder-small.jpg',
                          fit: BoxFit.cover,
                        );
                      }
                      return Image.network(
                        snapshot.data as String,
                        headers: MusicbrainzApi.headers,
                        fit: BoxFit.cover,
                        errorBuilder: (context, obj, stackTrace) {
                          return Image.asset(
                            'assets/playlist-placeholder-small.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, widget, progress) {
                          if (progress == null) return widget;
                          int? total = progress.expectedTotalBytes;
                          double? percentage;
                          if (total != null) {
                            percentage = progress.cumulativeBytesLoaded / total;
                          } else {
                            percentage = null;
                          }
                          return Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                value: percentage,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onEntityTap(entity),
                      onLongPress: () => onEntityHold(entity),
                    ),
                  )
                ],
              ),
            ),
          );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: Row(
        children: [
          ...buildList(),
          SizedBox(
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
          ),
        ],
      ),
    );
  }
}
