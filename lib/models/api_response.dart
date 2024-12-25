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
            "The title of the release.",
        nullable: false,
      ),
      "artist": Schema.string(
        description:
            'The combined credited artist name for the release.',
        nullable: false,
      ),
      "tags": tagsSchema,
    },
    requiredProperties: ['title', 'artist', 'tags'],
  );

  static final Schema tagsSchema = Schema.array(
    description:
        """An array of tags related to the entity. Try to find 20 or more.
          Each tags should be 1 to 2 words in length, except genre and subgenre use normal genre names for those.

          Tags includes but not limited to:

          Genre: Pop, Rock, Hip Hop, Jazz, Blues, Classical,
          Electronic, Reggae, Country, R&B, Metal, Folk, Soul,
          Punk, Indie, Funk, Latin, Gospel, Lofi,
          Disco, Techno, Ska, K-pop, J-pop, Afrobeat, Grunge.

          Sub Genre: Synth-pop, Hard Rock, hardstyle, Trap, Smooth Jazz,
          Delta Blues, Baroque, House, Dub, Bluegrass, Neo-Soul,
          Black Metal, Acoustic Folk, Motown, Hardcore Punk, Shoegaze,
          Acid Jazz, Salsa, Contemporary Gospel, Italo Disco,
          Minimal Techno, Two-Tone Ska,Alternative R&B,
          Reggaeton, Progressive Rock, Psychedelic Rock.

          Language: Include origin language and vocal language if exists and it's different
          Vibe: 1 word to describe the song's vibe, can be multiple tags
          Instruments: Instruments or electronic
          Vocals: Vocal Samples
          Tempo: (Low or Medium or High) with (Steady, Dynamic)
          Other: More tags related to the song/artist
        """,
    nullable: false,
    items: Schema.object(
      description: "",
      properties: {
        "name": Schema.string(
          description:
              "The display name and should ALWAYS be the same as the value. Should be Capitalized except if they are names. Forexample: name=J-Pop, value=J-Pop, type=genre",
          nullable: false,
        ),
        "value": Schema.string(
          description:
              "The internal value. Should be the same as name even the case, except if the name is too general that it might confused with another tag",
          nullable: false,
        ),
        "type": Schema.enumString(
          description: "The tag category, This should never be used as the name",
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
