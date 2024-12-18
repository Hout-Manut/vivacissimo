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
            "The title of the release, in their original language if there is.",
        nullable: false,
      ),
      "searchTerm": Schema.string(
        description: "A searchable term, usually the title in english.",
        nullable: false,
      ),
      "tags": Schema.array(
        description:
            "An array of tags related to the release. Each tags should be 1 to 2 words in length, except genre and subgenre",
        nullable: false,
        items: tagSchema,
      )
    },
    requiredProperties: ['title', 'searchTerm', 'tags'],
  );

  static final Schema tagSchema = Schema.object(
    properties: {
      "name": Schema.string(
        description: "The display name.",
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
      "tags": Schema.array(
        description: "The tags should be the tags related to their releases.",
        items: tagSchema,
      ),
      "description": Schema.string(
        description:
            "A description/note of the artist. not required. Usually to tell if the artist is an alias of someone else.",
        nullable: true,
      ),
    },
    requiredProperties: ["name", "sortName", "type", "tags"],
  );
}
