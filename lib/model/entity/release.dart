import 'package:vivacissimo/model/tag.dart';
import 'package:json_annotation/json_annotation.dart';

import './entity.dart';
import '../artist_credit.dart';

part 'release.g.dart';

enum ReleaseType {
  album,
  single,
  ep,
  other;
}

@JsonSerializable()
class Release extends Entity {
  final String title;
  final ArtistCredit artist;
  final Set<Tag> tags;
  final String image;

  Release({
    super.id,
    super.mbid,
    required this.title,
    required this.artist,
    required this.tags,
    required this.image,
  });

  factory Release.fromJson(Map<String, dynamic> json) =>
      _$ReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$ReleaseToJson(this);
}
