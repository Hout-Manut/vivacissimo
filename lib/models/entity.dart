import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vivacissimo/models/models.dart';
import 'package:vivacissimo/services/vivacissimo.dart';

part 'entity.g.dart';

enum EntityType {
  artist('artist'),
  release('release');

  const EntityType(this.mbName);

  final String mbName;
}

enum ReleaseType {
  album,
  single,
  ep,
  other;
}

enum ArtistType {
  person,
  group,
  orchestra,
  choir,
  character,
  other;
}

sealed class Entity {
  final String id;
  final String? spotifyId;
  final String? spotifyUri;
  final EntityType entityType;
  @JsonKey(toJson: _tagsToIds, fromJson: _idsToTags, name: "tagIds")
  final Set<Tag> tags = {};

  static const Uuid uuid = Uuid();

  Entity({
    String? id,
    this.spotifyId,
    this.spotifyUri,
    required this.entityType,
    Set<Tag>? tags,
  })  : id = id ?? uuid.v4() {
    this.tags.addAll(tags ?? {});
  }

  factory Entity.fromJson(Map<String, dynamic> json) {
    switch (json['entityType']) {
      case 'artist':
        return _$ArtistFromJson(json);
      case 'release':
        return _$ReleaseFromJson(json);
      default:
        throw Exception(
          'Json Deserialization Failed: Unknown entity type: ${json['entityType']}',
        );
    }
  }

  Map<String, dynamic> toJson() {
    switch (this) {
      case Artist():
        return _$ArtistToJson(this as Artist);
      case Release():
        return _$ReleaseToJson(this as Release);
    }
  }

  static List<String> _tagsToIds(Set<Tag> tags) {
    return tags.map((tag) => tag.id).toList();
  }

  static Set<Tag> _idsToTags(List<dynamic>? ids) {
    if (ids == null) return {};
    return ids
        .map((id) =>
            Vivacissimo.getTagById(id) ??
            Tag(name: id, value: id, type: TagType.other))
        .toSet();
  }

  String toPrompt();

  @override
  bool operator ==(covariant Entity other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class Artist extends Entity {
  final String name;
  final String? sortName;
  final ArtistType type;
  final String? description;
  final List<dynamic> releasesJson;

  Artist({
    super.id,
    super.spotifyId,
    super.spotifyUri,
    required this.name,
    this.sortName,
    super.tags,
    this.type = ArtistType.person,
    this.description,
    super.entityType = EntityType.artist,
    List<dynamic>? releasesJson,
  }) : releasesJson = releasesJson ?? [];

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  factory Artist.fromMusicBrainz(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name']!,
      sortName: json['name']!,
      tags: {},
      releasesJson: json['releases'] ?? [],
    );
  }
  factory Artist.fromSpotify(Map<String, dynamic> json) {
    return Artist(
      id: null,
      spotifyId: json['id'],
      name: json['name']!,
      spotifyUri: json['uri']!,
      sortName: json['name']!,
      tags: {},
      releasesJson: [],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$ArtistToJson(this);

  @override
  String toPrompt() {
    final sb = StringBuffer()
      ..writeln(
          "I want you to break down this artist for related tags/attributes So I can use them to look recommendations")
      ..writeln("The song name is $name")
      ..writeln(
          "Please return about 10 - 15 tags of the artist's recent or popular works.");
    return sb.toString().trim();
  }
}

@JsonSerializable()
class Release extends Entity {
  final String title;
  final ArtistCredit credit;
  final String image;

  Release({
    super.id,
    super.spotifyId,
    super.spotifyUri,
    super.tags,
    required this.title,
    required this.credit,
    this.image = 'assets/playlist-placeholder-small.jpg',
    super.entityType = EntityType.release,
  });

  factory Release.fromMusicBrainz(Map<String, dynamic> json) {
    return Release(
      id: json['id'],
      title: json['title'],
      credit: ArtistCredit.fromMusicBrainz(json['artist-credit']),
      tags: {},
    );
  }

  factory Release.fromSpotify(Map<String, dynamic> json) {
    return Release(
      spotifyId: json['id'],
      spotifyUri: json['uri'],
      title: json['name'],
      credit: ArtistCredit.fromSpotify(json['artist-credit']),
      tags: {},
    );
  }

  void addTags(Iterable<Tag> tags) {
    this.tags.addAll(tags);
  }

  factory Release.fromJson(Map<String, dynamic> json) =>
      _$ReleaseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReleaseToJson(this);

  @override
  String toPrompt() {
    final sb = StringBuffer()
      ..writeln(
          "I want you to break down this song for related tags/attributes So I can use them to look recommendations")
      ..writeln("The song name is $title by ${credit.toString()}")
      ..writeln("Please return about 10 - 15 tags.");
    return sb.toString().trim();
  }
}
