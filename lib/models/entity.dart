import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vivacissimo/services/vivacissimo.dart';
import 'tag.dart';

import 'artist_credit.dart';

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
  final EntityType entityType;
  @JsonKey(toJson: _tagsToIds, fromJson: _idsToTags, name: "tagIds")
  final Set<Tag> tags;

  static const Uuid uuid = Uuid();

  Entity({String? id, required this.entityType, required this.tags})
      : id = id ?? Entity.uuid.v4();

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

  static Set<Tag> _idsToTags(List<String> ids) {
    return ids
        .map((id) =>
            Vivacissimo.getTagById(id) ??
            Tag(name: id, value: id, type: TagType.other))
        .toSet();
  }

  String toPrompt();
}

@JsonSerializable()
class Artist extends Entity {
  final String name;
  final String sortName;
  final ArtistType type;
  final String? description;

  Artist({
    super.id,
    required this.name,
    required this.sortName,
    required super.tags,
    this.type = ArtistType.person,
    this.description,
    super.entityType = EntityType.artist,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  factory Artist.fromMusicBrainz(Map<String, dynamic> json) {
    return Artist(name: json['name']!, sortName: json['sort-name']!, tags: {});
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
    required this.title,
    required this.credit,
    required super.tags,
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
