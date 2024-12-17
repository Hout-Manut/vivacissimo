import '../models/tag.dart';
import '../models/entity.dart';
import '../models/artist_credit.dart';

Artist zun = Artist(
    name: 'ZUN',
    sortName: 'ZUN',
    id: 'b8155f6d-7852-4486-97d9-1b7fdda3fa08',
    type: ArtistType.person);

Artist qlarabelle = Artist(
  name: "Qlarabelle",
  sortName: "Qlarabelle",
  id: '9b0ddf37-f745-4e01-a16d-3de98eb82bb4',
  description: "Yuta Imai alias, Hard Dance",
  type: ArtistType.person,
);

Artist yutaImai = Artist(
  name: "Yuta Imai",
  sortName: "Yuta Imai",
  id: 'b17e8126-7642-44a8-a311-6fb6546cf672',
  // aliases: [qlarabelle],
  type: ArtistType.person,
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
  id: '715a50b2-7525-3dbd-9d67-e0ed13d4c4b6',
  title: "Bad Apple!!",
  image: 'assets/dummy/badApple.jpg',
  credit: ArtistCredit(
    parts: [ArtistCreditPart(zun.id)],
  ),
  tagIds: badAppleTags,
);

Release alterEgo = Release(
  title: "Alter Ego",
  credit: ArtistCredit(parts: [
    ArtistCreditPart(yutaImai.id, joinPhrase: ' vs '),
    ArtistCreditPart(qlarabelle.id),
  ]),
  tagIds: alterEgoTags,
  image: 'assets/dummy/alterEgo.jpg',
);
