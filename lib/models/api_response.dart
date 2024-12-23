import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vivacissimo/models/entity.dart';
import 'tag.dart';

class ApiResponse {
  static final Schema releaseListSchema = Schema.array(
    description: "A list of releases. Releases are songs.",
    items: releaseSchema,
  );
  static final Schema artistListSchema = Schema.array(
    description: "A list of artists.",
    items: artistSchema,
  );
  static final Schema releaseSchema = Schema.object(
    description: "A release",
    nullable: false,
    properties: {
      "title": Schema.string(
        description:
            "The title of the release. This will also be used to query MusicBrainz api for additional informations.",
        nullable: false,
      ),
      "artist": Schema.string(
        description:
            'The combined credited artist name for the release, including join phrases (e.g. "Artist X feat.", "x join phrase y") AKA whats displayed',
        nullable: false,
      ),
      "tags": tagsSchema,
    },
    requiredProperties: ['title', 'artist', 'tags'],
  );

  static final Schema tagsSchema = Schema.array(
    description:
        """An array of tags related to the entity. Try to find 15 or more. Each tags should be 1 to 2 words in length, except genre and subgenre use normal genre names for those.

          Example for tags a release/song `ALTER EGO` by `Yuta Imai vs Qlarabelle` parenthesis not included

          Genre: Hardstyle, Game Music
          Sub Genre: Electronic
          Language: Japanese (origin), English (vocal samples)
          Vibe: Melancholic
          Instruments: Synthesizer
          Vocals: Vocal Samples
          Tempo: High, Steady
          Other: Arcaea

          Another example for `Bad Apple` by `nomico`

          Genre: Touhou, Game Music
          Sub Genre: Electronic, Doujin Music
          Language: Japanese,
          Vibe: Melancholic, Nostalgic
          Instruments: Synthesizer, Drum Machine
          Vocals: Vocaloid
          Tempo: Medium, Steady
          Other: Touhou Project, ZUN, Iconic, Fan Favorite
        """,
    nullable: false,
    items: Schema.object(
      description: "",
      properties: {
        "name": Schema.string(
          description: "The display name. Should be Capitalized except if they are names",
          nullable: false,
        ),
        "value": Schema.string(
          description:
              "The internal value. Should be the same as name even the case, except if the name is too general that it might confused with another tag",
          nullable: false,
        ),
        "type": Schema.enumString(
          description: "The tag category",
          enumValues: TagType.values.map((tag) => tag.name).toList(),
          nullable: false,
        ),
      },
      requiredProperties: ['name', 'value', 'type'],
    ),
  );

  static final Schema artistSchema = Schema.object(
    description: "An artist.",
    properties: {
      "name": Schema.string(
        description: "The name of the artist.",
        nullable: false,
      ),
      "sortName": Schema.string(
        description: "The sort name of the artist.",
        nullable: false,
      ),
      "type": Schema.enumString(
        description: "The artist category",
        enumValues: ArtistType.values.map((tag) => tag.name).toList(),
        nullable: false,
      ),
      "tags": tagsSchema,
      "description": Schema.string(
        description:
            "A description/note of the artist. not required. Usually to tell if the artist is an alias of someone else.",
        nullable: true,
      ),
    },
    requiredProperties: ["name", "sortName", "type", "tags"],
  );
}
