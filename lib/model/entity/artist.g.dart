// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist(
      id: json['id'] as String?,
      mbid: json['mbid'] as String?,
      name: json['name'] as String,
      sortName: json['sortName'] as String,
      type: $enumDecode(_$ArtistTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
      'id': instance.id,
      'mbid': instance.mbid,
      'name': instance.name,
      'sortName': instance.sortName,
      'type': _$ArtistTypeEnumMap[instance.type]!,
    };

const _$ArtistTypeEnumMap = {
  ArtistType.person: 'person',
  ArtistType.group: 'group',
  ArtistType.orchestra: 'orchestra',
  ArtistType.choir: 'choir',
  ArtistType.character: 'character',
  ArtistType.other: 'other',
};
