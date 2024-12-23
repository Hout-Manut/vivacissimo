import 'package:flutter/material.dart';
import 'package:vivacissimo/screen/playlist/playlist_new.dart';
import '../models/playlist.dart';
import '../widgets/commons.dart';
import '../widgets/constants.dart';

import '../services/vivacissimo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  void newPlaylist() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const PlaylistNew();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 64.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const LargeTitleText('Home'),
                const SizedBox(height: 16),
                const TitleText('Recent Playlists'),
                const SizedBox(height: 8),
                RecentPlaylists(),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      Vivacissimo.saveData();
                    },
                    child: Text("DEBUG: Save data")),
                ElevatedButton(
                    onPressed: () {
                      Vivacissimo.deleteData();
                    },
                    child: Text("DEBUG: Clear data")),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: newPlaylist,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16.0),
                    child: SizedBox(
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentPlaylists extends StatelessWidget {
  late final List<Playlist> playlists;

  static const double itemHeight = 128;

  RecentPlaylists({super.key}) {
    playlists = Vivacissimo.playlists;
    playlists.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          Playlist item = playlists[index];
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
        },
      ),
    );
  }
}
