import 'package:flutter/material.dart';
import 'package:vivacissimo/models/entity.dart';
import 'package:vivacissimo/services/api/musicbrainz_api.dart';
import 'package:vivacissimo/widgets/commons.dart';
import 'package:vivacissimo/widgets/constants.dart';
import 'dart:async';

class EntitySearchModal extends StatefulWidget {
  const EntitySearchModal({super.key});

  @override
  State<EntitySearchModal> createState() => _EntitySearchModalState();
}

const double baseHeight = 78;

enum SearchState {
  idle(Icon(
    Icons.search,
    color: AppColor.textColor,
    size: AppFontSize.body,
  )),
  loading(Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          color: AppColor.textColor,
          strokeWidth: 2,
        ),
      )
    ],
  )),
  loaded(null);

  const SearchState(this.widget);
  final Widget? widget;
}

class _EntitySearchModalState extends State<EntitySearchModal> {
  final TextEditingController controller = TextEditingController();
  SearchState state = SearchState.idle;
  final List<Entity> result = [];
  bool temp = true;
  Timer? debounce;

  static const double height = baseHeight;
  static const double idleHeight = 52;
  static const double padding = 8;

  bool get expanded {
    if (state != SearchState.loaded) return result.isNotEmpty;
    return true;
  }

  double get expandedHeight {
    if (result.isEmpty) {
      if (state == SearchState.loaded) {
        return idleHeight + 64;
      }
      return idleHeight;
    }
    double finalHeight = (height * result.length) + (idleHeight * 2);
    return finalHeight > 360 ? 360 : finalHeight;
  }

  void onChanged(String newString) {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(const Duration(milliseconds: 2000), () => search());

    if (controller.text.isEmpty) {
      state = SearchState.idle;
    } else {
      state = SearchState.loading;
    }
    setState(() {});
  }

  Future<void> search() async {
    if (state != SearchState.loading) return;
    List<Release> foundReleases =
        await MusicbrainzApi.searchReleases(controller.text);
    result.clear();
    result.addAll(foundReleases);
    onLoaded();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onLoaded() {
    final ImageCache cache = PaintingBinding.instance.imageCache;
    cache.clear();
    setState(() {
      state = SearchState.loaded;
    });
  }

  void onTap(Entity target) {
    Navigator.of(context).pop(target);
  }

  Widget buildResults() {
    if (result.isNotEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: idleHeight + padding),
          child: ListView.builder(
            key: ValueKey(result.hashCode),
            itemCount: result.length,
            // cacheExtent: 1000,
            itemBuilder: (context, index) => EntityResult(
              result[index],
              onTap: () => onTap(result[index]),
            ),
          ),
        ),
      );
    } else if (state == SearchState.loaded) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.only(top: idleHeight),
            child: Center(
              child: SubText("No results found."),
            )),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: 328,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 200),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: expanded ? expandedHeight : idleHeight,
                  curve: Curves.easeOutExpo,
                  padding: expanded
                      ? const EdgeInsets.fromLTRB(8, 8, 8, 0)
                      : const EdgeInsets.all(0),
                  margin: expanded
                      ? const EdgeInsets.all(0)
                      : const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF000000),
                        blurRadius: 64,
                        spreadRadius: 24,
                      )
                    ],
                    color:
                        expanded ? const Color(0xFF252525) : Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: TextField(
                          controller: controller,
                          onChanged: onChanged,
                          style: const TextStyle(
                            color: AppColor.textColor,
                          ),
                          cursorColor: AppColor.textColor,
                          autofocus: true,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF171717),
                            suffixIcon: SizedBox(
                              width: 16,
                              height: 16,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 100),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: state.widget ?? const SizedBox.shrink(),
                              ),
                            ),
                            hintText: 'Search songs or artists',
                            hintStyle: const TextStyle(
                              color: AppColor.textSecondaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      buildResults(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EntityResult extends StatefulWidget {
  final Entity entity;
  final void Function() onTap;
  const EntityResult(this.entity, {super.key, required this.onTap});

  static const double height = baseHeight;

  @override
  State<EntityResult> createState() => _EntityResultState();
}

class _EntityResultState extends State<EntityResult> {
  String? imageUrl;

  Widget getImage() {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        key: Key(widget.entity.id),
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
    }
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

  bool isLoading = true;

  Future<void> fetchImage() async {
    final String? imagePath =
        await MusicbrainzApi.getImageUrl(widget.entity.id);
    setState(() {
      imageUrl = imagePath;
    });
  }

  @override
  void initState() {
    fetchImage();
    super.initState();
  }

  Widget buildRelease(
    BuildContext context,
    Release release,
  ) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: EntityResult.height,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: EntityResult.height,
              width: EntityResult.height,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(4)),
                clipBehavior: Clip.antiAlias,
                child: getImage(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyText(release.title),
                  SubText(release.credit.toString()),
                  SubText(release.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.entity) {
      case Artist():
        // TODO: Handle this case.
        throw UnimplementedError();
      case Release():
        return buildRelease(context, widget.entity as Release);
    }
  }
}
