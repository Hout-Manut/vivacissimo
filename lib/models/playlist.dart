import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vivacissimo/models/artist_credit.dart';
import 'package:vivacissimo/models/entity.dart';
import 'package:vivacissimo/models/tag.dart';
import 'package:vivacissimo/services/vivacissimo.dart';

part 'playlist.g.dart';

const Uuid uuid = Uuid();

@JsonSerializable()
class Playlist {
  final String id;
  final String title;
  final String credit;

  @JsonKey(
    toJson: _entitiesToIds,
    fromJson: _idsToEntities,
    name: "entitiesIds",
  )
  final List<Entity> references = [];
  @JsonKey(
    toJson: _preferencesToIds,
    fromJson: _idsToPreferences,
    name: "preferencesIds",
  )
  final Map<String, List<Tag>> preferences = {
    'more': [],
    'less': [],
  };
  @JsonKey(
    toJson: _releaseToIds,
    fromJson: _idsToRelease,
    name: "releasesIds",
  )
  final List<Release> releases = [];
  final DateTime dateCreated;
  late final String imageUrl;
  final bool allowExplicit;
  final bool? popularity;
  final bool? discovery;
  final int length;
  final bool imageIsAsset;

  void addTags({required List<Tag> tags, required String key}) {
    preferences[key]!.addAll(tags);
  }

  void removeTags({required List<Tag> tags, required String key}) {
    for (Tag tag in tags) {
      preferences[key]!.remove(tag);
    }
  }

  Playlist({
    required this.id,
    this.title = "A Playlist",
    this.credit = "Various Artists",
    String? imageUrl,
    DateTime? dateCreated,
    List<Entity>? references,
    List<Release>? releases,
    Map<String, List<Tag>>? preferences,
    this.allowExplicit = true,
    this.popularity,
    this.discovery,
    this.length = 30,
    this.imageIsAsset = false,
  }) : dateCreated = dateCreated ?? DateTime.now() {
    this.imageUrl = imageUrl ?? "assets/playlist-placeholder-small.jpg";
    this.references.addAll(references ?? []);
    this.releases.addAll(releases ?? []);

    if (preferences != null) {
      List<Tag> moreTags = preferences["more"] ?? [];
      List<Tag> lessTags = preferences["less"] ?? [];
      this.preferences["more"]!.addAll(moreTags);
      this.preferences["less"]!.addAll(lessTags);
    }
  }

  @override
  bool operator ==(covariant Playlist other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  static List<String> _entitiesToIds(List<Entity> entities) {
    return entities.map((entity) => entity.id).toList();
  }

  static Map<String, List<String>> _preferencesToIds(
    Map<String, List<Tag>> preferences,
  ) {
    return {
      'more': [
        ...preferences['more']!.map((tag) => tag.id),
      ],
      'less': [
        ...preferences['less']!.map((tag) => tag.id),
      ],
    };
  }

  static List<String> _releaseToIds(List<Release> releases) {
    return releases.map((release) => release.id).toList();
  }

  static Map<String, List<Tag>> _idsToPreferences(
    Map<String, dynamic> tags,
  ) {
    return {
      'more': [
        ...tags['more']!.map((id) =>
            Vivacissimo.getTagById(id) ??
            Tag(
              name: id,
              value: id,
              type: TagType.other,
            )),
      ],
      'less': [
        ...tags['less']!.map((id) =>
            Vivacissimo.getTagById(id) ??
            Tag(
              name: id,
              value: id,
              type: TagType.other,
            )),
      ],
    };
  }

  static List<Entity> _idsToEntities(List<dynamic> ids) {
    return ids
        .map(
          (id) =>
              Vivacissimo.getReleaseById(id) ??
              Vivacissimo.getArtistById(id) ??
              Release(
                id: "unknown-release",
                title: "Unknown Entity",
                credit: const ArtistCredit(parts: []),
                tags: {},
              ),
        )
        .toList();
  }

  static List<Release> _idsToRelease(List<dynamic> ids) {
    return ids
        .map(
          (id) =>
              Vivacissimo.getReleaseById(id) ??
              Release(
                id: "unknown-artist",
                title: "Unknown Entity",
                credit: const ArtistCredit(parts: []),
                tags: {},
              ),
        )
        .toList();
  }

  String get isExplicitStr {
    if (allowExplicit) {
      return "allows explicit songs";
    } else {
      return "does not allow explicit songs";
    }
  }

  String get popularityStr {
    if (popularity == null) {
      return "a mix of popular, well known songs and other non-popular songs.";
    } else if (popularity!) {
      return "a playlist more focused on popular and well known songs.";
    } else {
      return "to see less known, obscure songs.";
    }
  }

  String get preferredSongs {
    if (references.isEmpty) return "";

    final List<String> releases = [];
    final List<String> artists = [];

    for (Entity entity in references) {
      switch (entity) {
        case Artist():
          artists.add(entity.name);
        case Release():
          releases.add("${entity.title} by ${entity.credit}");
      }
    }

    final buffer = StringBuffer("I'd like to hear songs similar to ");

    if (releases.isNotEmpty) {
      buffer.write(releases.join(", "));
    }
    if (artists.isNotEmpty) {
      if (releases.isEmpty) {
        buffer.write(artists.join(", "));
      } else {
        buffer.write(" and also from these artists: ${artists.join(", ")}");
      }
    }

    buffer.write(".");

    return buffer.toString();
  }

  String get preferredTags {
    if ((preferences['more'] ?? []).isEmpty) return "";
    String str = "focused on songs that are related to these tags: ";
    str = str + preferences['more']!.map((tag) => tag.value).join(", ");
    return str;
  }

  String get notPreferredTags {
    if ((preferences['less'] ?? []).isEmpty) return "";
    String str = "and dont recommend songs that are related to these tags: ";
    str = str + preferences['less']!.map((tag) => tag.value).join(", ");
    return str;
  }

  String toPrompt() {
    final sb = StringBuffer()
      ..writeln("I want you to make a playlist that $popularityStr.")
      ..writeln("This playlist $isExplicitStr.")
      ..writeln("Please include a total of $length songs.")
      ..writeln(preferredSongs.isNotEmpty
          ? "Also, $preferredSongs"
          : "No specific artist or release references.")
      ..writeln(preferredTags.isNotEmpty
          ? preferredTags
          : "No specific tags to prioritize.")
      ..writeln(
          notPreferredTags.isNotEmpty ? notPreferredTags : "No tags to avoid.")
      ..writeln(
          "Please provide music recommendations that match the above criteria.");
    return sb.toString().trim();
  }
}
