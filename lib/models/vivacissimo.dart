import 'package:vivacissimo/models/models.dart';

class Vivacissimo {
  final List<Playlist> _registeredPlaylists = [];

  List<Playlist> get recentPlaylists {
    final List<Playlist> playlists = _registeredPlaylists;

    // TODO: Implement sorting and categorizing.
    throw UnimplementedError();
  }
}
