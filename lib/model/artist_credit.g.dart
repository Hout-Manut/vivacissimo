// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_credit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtistCredit _$ArtistCreditFromJson(Map<String, dynamic> json) => ArtistCredit(
      prefix: json['prefix'] as String?,
      parts: (json['parts'] as List<dynamic>)
          .map((e) => ArtistCreditPart.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ArtistCreditToJson(ArtistCredit instance) =>
    <String, dynamic>{
      'prefix': instance.prefix,
      'parts': instance.parts,
    };

ArtistCreditPart _$ArtistCreditPartFromJson(Map<String, dynamic> json) =>
    ArtistCreditPart(
      Artist.fromJson(json['artist'] as Map<String, dynamic>),
      credit: json['credit'] as String?,
      joinPhrase: json['joinPhrase'] as String?,
    );

Map<String, dynamic> _$ArtistCreditPartToJson(ArtistCreditPart instance) =>
    <String, dynamic>{
      'artist': instance.artist,
      'credit': instance.credit,
      'joinPhrase': instance.joinPhrase,
    };
