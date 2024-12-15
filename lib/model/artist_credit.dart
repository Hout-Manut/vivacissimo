import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './entity/artist.dart';

import 'package:json_annotation/json_annotation.dart';

part 'artist_credit.g.dart';

@JsonSerializable()
class ArtistCredit {
  final String? prefix;
  final List<ArtistCreditPart> parts;

  const ArtistCredit({required this.prefix, required this.parts});

  RichText build(BuildContext context) {
    List<InlineSpan> children = [];
    for (ArtistCreditPart part in parts) {
      children.addAll(part.build(context));
    }
    TextSpan prefixText = TextSpan(
      text: prefix,
      style: const TextStyle(color: Colors.white),
      children: children,
    );
    return RichText(
      text: prefixText,
    );
  }

  factory ArtistCredit.fromJson(Map<String, dynamic> json) =>
      _$ArtistCreditFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCreditToJson(this);
}

@JsonSerializable()
class ArtistCreditPart {
  final Artist artist;
  final String? credit;
  final String? joinPhrase;

  ArtistCreditPart(
    this.artist, {
    this.credit,
    this.joinPhrase,
  });
  List<InlineSpan> build(BuildContext context) {
    return [
      TextSpan(
        text: credit,
        style: TextStyle(color: Theme.of(context).primaryColor),
        recognizer: TapGestureRecognizer()..onTap = () {},
      ),
      if (joinPhrase != null)
        TextSpan(
          text: joinPhrase,
          style: const TextStyle(color: Colors.white),
        )
    ];
  }

  factory ArtistCreditPart.fromJson(Map<String, dynamic> json) =>
      _$ArtistCreditPartFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCreditPartToJson(this);
}
