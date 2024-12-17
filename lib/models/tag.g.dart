// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      id: json['id'] as String?,
      name: json['name'] as String,
      value: json['value'] as String,
      type: $enumDecode(_$TagTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'type': _$TagTypeEnumMap[instance.type]!,
    };

const _$TagTypeEnumMap = {
  TagType.genre: 'genre',
  TagType.subGenre: 'subGenre',
  TagType.language: 'language',
  TagType.vibe: 'vibe',
  TagType.instruments: 'instruments',
  TagType.vocals: 'vocals',
  TagType.tempo: 'tempo',
  TagType.other: 'other',
};
