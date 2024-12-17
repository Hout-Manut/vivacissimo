import 'package:vivacissimo/models/entity.dart';

class Playlist {
  final List<Entity> references = [];
  final Map<String, List<String>> preferences = {
    'more': [],
    'less': [],
  };
  final Map<String, dynamic> config;
  final DateTime dateCreated;
  final String imageUrl;

  Playlist({
    this.imageUrl = "assets/playlist-placeholder-small.jpg",
    List<Entity>? references,
    required this.config,
  }) : dateCreated = DateTime.now() {
    this.references.addAll(references ?? []);
  }
}
