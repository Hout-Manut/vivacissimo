import 'package:flutter/material.dart';
import '../../models/playlist.dart';
import '../../widgets/commons.dart';
import '../../widgets/constants.dart';

import '../../services/vivacissimo.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Playlist> tempPlaylist = [
    // Playlist(references: [], tags: {}),
    // Playlist(references: [], tags: {}),
    // Playlist(references: [], tags: {}),
    // Playlist(references: [], tags: {}),
  ];

  @override
  void initState() {
    test();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const TitleText(data: 'Home'),
            const SizedBox(height: 8),
            const SubTitleText(data: 'Recent Playlists'),
            PlaylistList(references: tempPlaylist, onAdd: () {}),
            TextButton(onPressed:() => setState(() {}), child: Text("asdasdasda")),
          ],
        ),
      ),
    );
  }
}
class PlaylistList extends StatelessWidget {
  final List<Playlist> references;
  final void Function() onAdd;

  static const double itemHeight = 128;

  const PlaylistList({
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

    if (item is Playlist) {
      return Container(
        width: itemHeight,
        height: itemHeight,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: AppColor.borderColor),
        ),
        child: Image.asset(
          item.imageUrl,
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
