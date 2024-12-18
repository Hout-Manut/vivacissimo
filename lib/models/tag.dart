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

  const TagType(this.title);
  final String title;
}

@JsonSerializable()
class Tag {
  final String id;
  final String name;
  final String value;
  final TagType type;

  static final RegExp _normalizePattern = RegExp(r'[^a-z0-9]');

  Tag({
    String? id,
    required this.name,
    required this.value,
    required this.type,
  }) : id = id ?? _normalize(value);

  static String _normalize(String value) {
    String lowerCased = value.toLowerCase();
    return lowerCased.replaceAll(_normalizePattern, '');
  }

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}
