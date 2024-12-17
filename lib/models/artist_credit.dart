import 'package:json_annotation/json_annotation.dart';

part 'artist_credit.g.dart';

@JsonSerializable()
class ArtistCredit {
  final String prefix;
  final List<ArtistCreditPart> parts;

  const ArtistCredit({
    this.prefix = '',
    required this.parts,
  });

  factory ArtistCredit.fromJson(Map<String, dynamic> json) =>
      _$ArtistCreditFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCreditToJson(this);
}

@JsonSerializable()
class ArtistCreditPart {
  final String artistId;
  final String? credit;
  final String joinPhrase;

  const ArtistCreditPart(
    this.artistId, {
    this.joinPhrase = "",
    this.credit,
  });

  factory ArtistCreditPart.fromJson(Map<String, dynamic> json) =>
      _$ArtistCreditPartFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCreditPartToJson(this);
}
