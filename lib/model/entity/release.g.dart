// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Release _$ReleaseFromJson(Map<String, dynamic> json) => Release(
      id: json['id'] as String?,
      mbid: json['mbid'] as String?,
      title: json['title'] as String,
      artist: ArtistCredit.fromJson(json['artist'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toSet(),
      image: json['image'] as String,
    );

Map<String, dynamic> _$ReleaseToJson(Release instance) => <String, dynamic>{
      'id': instance.id,
      'mbid': instance.mbid,
      'title': instance.title,
      'artist': instance.artist,
      'tags': instance.tags.toList(),
      'image': instance.image,
    };
