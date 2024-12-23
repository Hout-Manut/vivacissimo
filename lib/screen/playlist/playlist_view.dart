import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vivacissimo/models/models.dart';
import 'package:vivacissimo/services/vivacissimo.dart';
import 'package:vivacissimo/widgets/constants.dart';

class PlaylistView extends StatefulWidget {
  final Playlist playlist;
  const PlaylistView(
    this.playlist, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void onRefresh() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    await Vivacissimo.getNewSongsForPlaylist(widget.playlist);
    setState(() {
      _isLoading = false;
    });
  }

  static const List<double> _thresholds = [10, 50, 100];
  static const List<int> _alphas = [0, 20, 120, 255];

  bool _showTitle = false;
  Color _appBarColor = AppColor.backgroundColor.withAlpha(0);

  void _onScroll() {
    final double offset = _scrollController.offset;

    int alpha;
    if (offset < _thresholds[0]) {
      alpha = _alphas[0];
      _showTitle = false;
    } else if (offset < _thresholds[1]) {
      alpha = _alphas[1];
      _showTitle = false;
    } else if (offset < _thresholds[2]) {
      alpha = _alphas[2];
      _showTitle = false;
    } else {
      alpha = _alphas[3];
      _showTitle = true;
    }

    final Color newColor = AppColor.backgroundColor.withAlpha(alpha);

    // Only rebuild if the color has actually changed
    if (_appBarColor != newColor) {
      setState(() {
        _appBarColor = newColor;
      });
    }
  }

  Widget buildItems() {
    if (widget.playlist.releases.isEmpty) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: Text(
            "No songs currently in the playlist, try tapping the regenerate songs button.",
            style: TextStyle(
              color: AppColor.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    return PlaylistItems(
      releases: widget.playlist.releases,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex--;
          }
          final Release item = widget.playlist.releases.removeAt(oldIndex);
          widget.playlist.releases.insert(newIndex, item);
        });
      },
      onDismissed: (index) {
        setState(() {
          widget.playlist.releases.removeAt(index);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: -50,
            child: Container(
              width: screenWidth * 1.6,
              height: screenWidth * 1.6,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.playlist.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                  color: _appBarColor,
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                preferredSize: const Size(double.infinity, 64),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    color: _appBarColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
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
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                          opacity: _showTitle ? 1 : 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(height: 34),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    widget.playlist.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.share,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    clipBehavior: Clip.none,
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.5, 1],
                        colors: [
                          AppColor.backgroundColor,
                          AppColor.backgroundColor.withAlpha(0),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 240),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                widget.playlist.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.playlist.title,
                                  style: const TextStyle(
                                    color: AppColor.textColor,
                                    fontSize: AppFontSize.title,
                                    fontWeight: FontWeight.w500,
                                    height: 1.31,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.playlist.credit,
                                  style: const TextStyle(
                                    color: AppColor.textSecondaryColor,
                                    fontSize: AppFontSize.caption,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 36,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Material(
                                            color: AppColor.buttonColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: InkWell(
                                              onTap: () {
                                                print("tapped");
                                              },
                                              borderRadius: BorderRadius.circular(
                                                  8), // Matches the Container's borderRadius
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                color: Colors.transparent,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: AppColor.textColor,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Material(
                                            color: AppColor.buttonColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: InkWell(
                                              onTap: onRefresh,
                                              borderRadius: BorderRadius.circular(
                                                  8), // Matches the Container's borderRadius
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                color: Colors.transparent,
                                                child: Center(
                                                  child: _isLoading
                                                      ? const SizedBox(
                                                          width: 14,
                                                          height: 14,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: AppColor
                                                                .textColor,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : const Icon(
                                                          Icons.replay,
                                                          color: AppColor
                                                              .textColor,
                                                          size: 12,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Material(
                                            color: AppColor.buttonColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: InkWell(
                                              onTap: () {
                                                print("tapped");
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                color: Colors.transparent,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.open_in_new,
                                                    color: AppColor.textColor,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Material(
                                            color: const Color(0xff1ed760),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: InkWell(
                                              onTap: () {
                                                print("tapped");
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                color: Colors.transparent,
                                                child: const Center(
                                                  child: Text(
                                                    "Open in Spotify",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                buildItems(),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistItems extends StatelessWidget {
  final List<Release> releases;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onDismissed;

  const PlaylistItems({
    super.key,
    required this.releases,
    required this.onReorder,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: releases.length * 64,
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: releases.length,
        onReorder: onReorder,
        proxyDecorator: (child, index, animation) {
          return child;
        },
        itemBuilder: (context, index) {
          final item = releases[index];

          return Dismissible(
            key: ValueKey("${item.id}$index"),
            onDismissed: (direction) {
              onDismissed(index);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: Text(
                      (index + 1).toString(),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColor.textColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColor.textColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.credit.toString(),
                          style: const TextStyle(
                            color: AppColor.textColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.drag_handle_rounded,
                    color: AppColor.textSecondaryColor,
                    size: 14,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
