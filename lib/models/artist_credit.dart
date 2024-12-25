import 'package:json_annotation/json_annotation.dart';
import 'package:vivacissimo/models/entity.dart';
import 'package:vivacissimo/services/vivacissimo.dart';

part 'artist_credit.g.dart';

@JsonSerializable()
class ArtistCredit {
  final String prefix;
  final List<ArtistCreditPart> parts;

  const ArtistCredit({
    this.prefix = '',
    required this.parts,
  });

  ArtistCredit.fake(String artistName)
      : prefix = "",
        parts = [
          ArtistCreditPart(
            artist: Artist(
              name: artistName,
              tags: {},
            ),
          ),
        ];

  factory ArtistCredit.fromJson(Map<String, dynamic> json) =>
      _$ArtistCreditFromJson(json);

  factory ArtistCredit.fromMusicBrainz(List<dynamic> json) {
    List<ArtistCreditPart> parts = [];

    for (Map<String, dynamic> part in json) {
      parts.add(
        ArtistCreditPart(
          artist: Artist.fromMusicBrainz(part['artist']),
          joinPhrase: part['joinphrase'] ?? "",
          credit: part['name'],
        ),
      );
    }
    return ArtistCredit(parts: parts);
  }

  Map<String, dynamic> toJson() => _$ArtistCreditToJson(this);

  @override
  String toString() {
    String credit = prefix;
    for (ArtistCreditPart part in parts) {
      credit += part.toString();
    }
    return credit;
  }
}

@JsonSerializable()
class ArtistCreditPart {
  @JsonKey(toJson: _artistToId, fromJson: _idToArtist, name: "artistId")
  final Artist artist;
  final String? credit;
  final String joinPhrase;

  const ArtistCreditPart({
    required this.artist,
    this.joinPhrase = "",
    this.credit,
  });

  factory ArtistCreditPart.fromJson(Map<String, dynamic> json) =>
      _$ArtistCreditPartFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCreditPartToJson(this);

  @override
  String toString() {
    String name = credit ?? artist.name;
    return name + joinPhrase;
  }

  static String _artistToId(Artist artist) => artist.id;

  static Artist _idToArtist(String id) {
    return Vivacissimo.getArtistById(id) ??
        Artist(
            id: "unknown-artist",
            name: "Unknown",
            sortName: "Unknown",
            tags: {},
            releasesJson: []);
  }
}
