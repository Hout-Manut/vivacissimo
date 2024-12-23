import 'package:vivacissimo/models/models.dart';

import '../models/tag.dart';
import '../models/entity.dart';
import '../models/artist_credit.dart';

Artist zun = Artist(
  name: 'ZUN',
  sortName: 'ZUN',
  id: 'b8155f6d-7852-4486-97d9-1b7fdda3fa08',
  type: ArtistType.person,
  tags: {},
);

Artist qlarabelle = Artist(
  name: "Qlarabelle",
  sortName: "Qlarabelle",
  id: '9b0ddf37-f745-4e01-a16d-3de98eb82bb4',
  description: "Yuta Imai alias, Hard Dance",
  type: ArtistType.person,
  tags: {},
);

Artist yutaImai = Artist(
  name: "Yuta Imai",
  sortName: "Yuta Imai",
  id: 'b17e8126-7642-44a8-a311-6fb6546cf672',
  // aliases: [qlarabelle],
  type: ArtistType.person,
  tags: {},
);

Set<Tag> badAppleTags = {
  // Genre
  Tag(name: 'Touhou', value: 'Touhou', type: TagType.genre),
  Tag(name: 'Game Music', value: 'Game Music', type: TagType.genre),

  // SubGenre
  Tag(name: 'Doujin Music', value: 'Doujin Music', type: TagType.subGenre),
  Tag(name: 'Electronic', value: 'Electronic', type: TagType.subGenre),

  // Language
  Tag(name: 'Japanese', value: 'Japanese', type: TagType.language),

  // Vibe
  Tag(name: 'Melancholic', value: 'Melancholic', type: TagType.vibe),
  Tag(name: 'Ethereal', value: 'Ethereal', type: TagType.vibe),
  Tag(name: 'Nostalgic', value: 'Nostalgic', type: TagType.vibe),

  // Instruments
  Tag(name: 'Synthesizer', value: 'Synthesizer', type: TagType.instruments),
  Tag(name: 'Drum Machine', value: 'Drum Machine', type: TagType.instruments),
  Tag(
    name: 'Electric Guitar',
    value: 'Electric Guitar',
    type: TagType.instruments,
  ),

  // Vocals
  Tag(name: 'Vocaloid', value: 'Vocaloid', type: TagType.vocals),
  Tag(name: 'Female Vocals', value: 'Female Vocals', type: TagType.vocals),

  // Tempo
  Tag(name: 'Medium', value: 'Medium BPM', type: TagType.tempo),
  Tag(name: 'Steady', value: 'Steady BPM', type: TagType.tempo),

  // Other
  Tag(name: 'Touhou Project', value: 'Touhou Project', type: TagType.other),
  Tag(name: 'ZUN', value: 'ZUN', type: TagType.other),
  Tag(name: 'Fan Favorite', value: 'Fan Favorite', type: TagType.other),
  Tag(name: 'Iconic', value: 'Iconic', type: TagType.other),
};

Set<Tag> alterEgoTags = {
  // Genre
  Tag(name: 'Hardstyle', value: 'Hardstyle', type: TagType.genre),
  Tag(name: 'Game Music', value: 'Game Music', type: TagType.genre),

  Tag(name: 'Electronic', value: 'Electronic', type: TagType.subGenre),

  // Language
  Tag(name: 'Japanese', value: 'Japanese', type: TagType.language),

  // Vibe
  Tag(name: 'Melancholic', value: 'Melancholic', type: TagType.vibe),

  Tag(name: 'Synthesizer', value: 'Synthesizer', type: TagType.instruments),

  Tag(name: 'Vocal Samples', value: 'Vocal Samples', type: TagType.vocals),

  Tag(name: 'High', value: 'High BPM', type: TagType.tempo),
  Tag(name: 'Steady', value: 'Steady BPM', type: TagType.tempo),

  Tag(name: 'Music Game', value: 'Music Game', type: TagType.other),
  Tag(name: 'Arcaea', value: 'Arcaea', type: TagType.other),
};

Release badApple = Release(
  id: '53e1af22-a21e-4b11-aca1-d04cc3fc71ec',
  title: "Bad Apple!!",
  image: 'assets/dummy/badApple.jpg',
  credit: ArtistCredit(
    parts: [ArtistCreditPart(artist: zun)],
  ),
  tags: badAppleTags,
);

Release alterEgo = Release(
  id: '50e4d838-d428-470e-9622-945f04339f02',
  title: "Alter Ego",
  credit: ArtistCredit(parts: [
    ArtistCreditPart(artist: yutaImai, joinPhrase: ' vs '),
    ArtistCreditPart(artist: qlarabelle),
  ]),
  tags: alterEgoTags,
  image: 'assets/dummy/alterEgo.jpg',
);

Playlist aPlaylist = Playlist(
  title: "Arcaea Sound Collection: Memories of Light",
  imageUrl: "assets/image 4.png",
  releases: [],
  preferences: {
    "more": [Tag(name: "J-Pop", value: "J-Pop", type: TagType.genre)]
  },
  config: {},
  references: [
    Release(
      title: "UNDEAD",
      credit: ArtistCredit(
        parts: [
          ArtistCreditPart(
              artist: Artist(name: "YOASOBI", sortName: "YOASOBI", tags: {}))
        ],
      ),
      tags: {},
    ),
    Release(
      title: "Idol",
      credit: ArtistCredit(
        parts: [
          ArtistCreditPart(
              artist: Artist(name: "YOASOBI", sortName: "YOASOBI", tags: {}))
        ],
      ),
      tags: {},
    ),
  ],
);
