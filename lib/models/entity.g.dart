// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist(
      id: json['id'] as String?,
      name: json['name'] as String,
      sortName: json['sortName'] as String,
      type: $enumDecode(_$ArtistTypeEnumMap, json['type']),
      description: json['description'] as String?,
      entityType:
          $enumDecodeNullable(_$EntityTypeEnumMap, json['entityType']) ??
              EntityType.artist,
    );

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
      'id': instance.id,
      'entityType': _$EntityTypeEnumMap[instance.entityType]!,
      'name': instance.name,
      'sortName': instance.sortName,
      'type': _$ArtistTypeEnumMap[instance.type]!,
      'description': instance.description,
    };

const _$ArtistTypeEnumMap = {
  ArtistType.person: 'person',
  ArtistType.group: 'group',
  ArtistType.orchestra: 'orchestra',
  ArtistType.choir: 'choir',
  ArtistType.character: 'character',
  ArtistType.other: 'other',
};

const _$EntityTypeEnumMap = {
  EntityType.artist: 'artist',
  EntityType.release: 'release',
};

Release _$ReleaseFromJson(Map<String, dynamic> json) => Release(
      title: json['title'] as String,
      credit: ArtistCredit.fromJson(json['credit'] as Map<String, dynamic>),
      tagIds: (json['tagIds'] as List<dynamic>).map((e) => e as String).toSet(),
      image:
          json['image'] as String? ?? 'assets/playlist-placeholder-small.jpg',
      entityType:
          $enumDecodeNullable(_$EntityTypeEnumMap, json['entityType']) ??
              EntityType.release,
    );

Map<String, dynamic> _$ReleaseToJson(Release instance) => <String, dynamic>{
      'entityType': _$EntityTypeEnumMap[instance.entityType]!,
      'title': instance.title,
      'credit': instance.credit,
      'tagIds': instance.tagIds.toList(),
      'image': instance.image,
    };
