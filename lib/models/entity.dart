import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';
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

  static const Uuid uuid = Uuid();

  Entity({String? id, required this.entityType}) : id = id ?? Entity.uuid.v4();

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
    required this.type,
    this.description,
    super.entityType = EntityType.artist,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}

@JsonSerializable()
class Release extends Entity {
  final String title;
  final ArtistCredit credit;
  final Set<Tag> tagIds;
  final String image;

  Release({
    super.id,
    required this.title,
    required this.credit,
    required this.tagIds,
    this.image = 'assets/playlist-placeholder-small.jpg',
    super.entityType = EntityType.release,
  });

  // void addTags(Iterable<Tag> tags) {
  //   for (Tag tag in tags) {
  //     tagIds.add(tag.id);
  //   }
  // }

  factory Release.fromJson(Map<String, dynamic> json) =>
      _$ReleaseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReleaseToJson(this);
}

// void example() {
//    final artist = Artist(
//     name: "Jane Smith",
//     sortName: "Smith, Jane",
//     type: ArtistType.person,
//     description: "A talented singer.",
//   );

//   final release = Release(
//     title: "Top Tracks",
//     credit: ArtistCredit(parts: [ArtistCreditPart(artist)]),
//     image: "assets/top-tracks.jpg",
//   );

//   final artistJson = artist.toJson();
//   final releaseJsonString = jsonEncode(release.toJson());
//   final releaseJson = jsonDecode(releaseJsonString);

//   // print(releaseJson);

//   final deserializedArtist = Artist.fromJson(artistJson);
//   final deserializedRelease = Release.fromJson(releaseJson);

//   // Validate Artist
//   assert(deserializedArtist.name == "Jane Smith");
//   assert(deserializedArtist.sortName == "Smith, Jane");
//   assert(deserializedArtist.type == ArtistType.person);
//   assert(deserializedArtist.description == "A talented singer.");

//   // Validate Release
//   assert(deserializedRelease.title == "Top Tracks");
//   assert(deserializedRelease.credit.parts[0].artist.name == artist.name);
//   assert(deserializedRelease.image == "assets/top-tracks.jpg");
// }
