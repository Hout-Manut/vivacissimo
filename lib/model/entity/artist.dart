import './entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

enum ArtistType {
  person,
  group,
  orchestra,
  choir,
  character,
  other;
}

@JsonSerializable()
class Artist extends Entity {
  final String name;
  final String sortName;
  final List<String> alias = [];
  final ArtistType type;

  Artist({
    super.id,
    super.mbid,
    required this.name,
    required this.sortName,
    required this.type,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
