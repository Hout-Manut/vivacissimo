import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

enum TagType {
  genre("Genre"),
  subGenre("Sub Genre"),
  language("Language"),
  vibe("Vibe"),
  instruments("Instruments"),
  vocals("Vocals"),
  tempo("Tempo"),
  other("Other");

  const TagType(this.name);
  final String name;
}

RegExp _normalizePattern = RegExp(r'[^a-z0-9]');

String _normalize(String value) {
  String lowerCased = value.toLowerCase();
  return lowerCased.replaceAll(_normalizePattern, '_');
}

@JsonSerializable()
class Tag {
  final String id;
  final String name;
  final String value;
  final TagType type;

  Tag({
    String? id,
    required this.name,
    required this.value,
    required this.type,
  }) : id = id ?? _normalize(value);

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}
