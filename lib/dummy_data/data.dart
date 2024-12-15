import 'package:vivacissimo/model/entity/artist.dart';
import 'package:vivacissimo/model/tag.dart';
import '../model/entity/release.dart';
import '../model/artist_credit.dart';

Artist zun = Artist(
  name: 'ZUN',
  sortName: 'ZUN',
  mbid: 'b8155f6d-7852-4486-97d9-1b7fdda3fa08',
  type: ArtistType.person
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

Release badApple = Release(
  mbid: '715a50b2-7525-3dbd-9d67-e0ed13d4c4b6',
  title: "Bad Apple!!",
  image: 'assets/dummy/badApple.jpg',
  artist: ArtistCredit(
    prefix: '',
    parts: [ArtistCreditPart(zun)],
  ),
  tags: badAppleTags,
);
