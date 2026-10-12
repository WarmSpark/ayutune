import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_des/dart_des.dart';
import '../models/hit_album.dart';
import '../models/lyric_line.dart';
import '../models/track.dart';

class ResolvedStream {
  final String url;
  final int totalBytes;
  final String contentType;

  const ResolvedStream({
    required this.url,
    required this.totalBytes,
    required this.contentType,
  });
}

class InnerTubeService {
  final List<Track> _top10WeeklyTracks = [
    const Track(
      id: 'VaNhRJHr',
      title: 'DIE WITH A SMILE',
      artist: 'LADY GAGA, BRUNO MARS',
      duration: Duration(minutes: 4, seconds: 11),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/060/Die-With-A-Smile-English-2024-20240816103634-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyCGZR06gaKffrem8wE1U/IMmorGBddTA3ePxCVrcJLdRXpP/tIcakyxw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'uNWdki50',
      title: 'APT.',
      artist: 'ROSE, BRUNO MARS',
      duration: Duration(minutes: 2, seconds: 49),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/138/APT-English-2024-20241204043232-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyrPDnaSftxiGT3aLAwJMLSoBfK9aX00Tuy+wg9M7tuJIGv2BO0+49oRw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'JR8ew5Yw',
      title: 'BIRDS OF A FEATHER',
      artist: 'BILLIE EILISH',
      duration: Duration(minutes: 3, seconds: 30),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/707/HIT-ME-HARD-AND-SOFT-English-2024-20240517063536-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyCj3kCFHZmBd3rXivMuxf3sdQvTTi+C/DtCwhwGmNiaIvWDkv7Mlhgxw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'Paem2Kf1',
      title: 'STARBOY',
      artist: 'THE WEEKND, DAFT PUNK',
      duration: Duration(minutes: 3, seconds: 50),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/372/Starboy-English-2016-20261007033842-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyuDdkCYGTsUDGOJFvCwxSUbmixxFc3paAM0N6pUZXPr/3abR9yPQFuRw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'X031nLVY',
      title: '505',
      artist: 'ARCTIC MONKEYS',
      duration: Duration(minutes: 4, seconds: 13),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/858/Favourite-Worst-Nightmare-English-2007-20230426182106-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyz0EQLoyvUHZwSWcm/wBwCRD+rnZpEsNLggPEvcMi5ZLmlDYREmUVUBw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'iE8z2T-c',
      title: 'I WANNA BE YOURS',
      artist: 'ARCTIC MONKEYS',
      duration: Duration(minutes: 3, seconds: 3),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/795/AM-English-2013-20240402165515-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyPcN+8EbIZsfTDWD9VWGwA4lGR4i8vmIQnRE93NzlvsR3Hz7a0ZWayBw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'fW-Mxsnu',
      title: 'BLINDING LIGHTS',
      artist: 'THE WEEKND',
      duration: Duration(minutes: 3, seconds: 20),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/077/After-Hours-English-2020-20260804045014-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyF/c5nqlFTXM0C74GbTF9AaylMpcN37HtcTaLl9ufWl/TC2QaaKAJJBw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: '8Ti1DvzG',
      title: 'SWEATER WEATHER',
      artist: 'THE NEIGHBOURHOOD',
      duration: Duration(minutes: 4, seconds: 0),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/834/I-Love-You--English-2013-20220323205211-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDy9hu3bS6NbvlfnPtd8idp5xvKSNTjf1XKoF3hhivPaFnfR1ZZxwRVsBw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'It96yG1r',
      title: 'AS IT WAS',
      artist: 'HARRY STYLES',
      duration: Duration(minutes: 2, seconds: 47),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/061/Harry-s-House-English-2022-20220518224913-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyafbGhocZIGEX7d4RweACgnR35n/+we01uAHyYcdfLt6G0e0zD5yAnBw7tS9a8Gtq',
      lyrics: [],
    ),
    const Track(
      id: 'BeXBcbVK',
      title: 'BELIEVER',
      artist: 'IMAGINE DRAGONS',
      duration: Duration(minutes: 3, seconds: 24),
      genreTag: 'TOP 10',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/248/Evolve-English-2018-20260605220036-500x500.webp',
      audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDy3oAkJDMbq8VkXOZU65DcFdrDhsTWIRT7u/8vMld9DHecVMFCBmD5/Rw7tS9a8Gtq',
      lyrics: [],
    ),
  ];

  final List<HitAlbum> _hitAlbums = [
    const HitAlbum(
      id: 'alb_starboy',
      title: 'STARBOY',
      artist: 'THE WEEKND',
      year: '2016',
      thumbnailUrl: 'https://c.saavncdn.com/372/Starboy-English-2016-20261007033842-500x500.webp',
      tracks: [
        Track(
          id: 'Paem2Kf1',
          title: 'STARBOY',
          artist: 'THE WEEKND, DAFT PUNK',
          duration: Duration(minutes: 3, seconds: 50),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/372/Starboy-English-2016-20261007033842-500x500.webp',
          audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyuDdkCYGTsUDGOJFvCwxSUbmixxFc3paAM0N6pUZXPr/3abR9yPQFuRw7tS9a8Gtq',
          lyrics: [],
        ),
        Track(
          id: 'starboy_rem',
          title: 'REMINDER',
          artist: 'THE WEEKND',
          duration: Duration(minutes: 3, seconds: 38),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/372/Starboy-English-2016-20261007033842-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'starboy_dfy',
          title: 'DIE FOR YOU',
          artist: 'THE WEEKND',
          duration: Duration(minutes: 4, seconds: 20),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/372/Starboy-English-2016-20261007033842-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'starboy_pm',
          title: 'PARTY MONSTER',
          artist: 'THE WEEKND',
          duration: Duration(minutes: 4, seconds: 3),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/372/Starboy-English-2016-20261007033842-500x500.webp',
          lyrics: [],
        ),
      ],
    ),
    const HitAlbum(
      id: 'alb_am',
      title: 'AM',
      artist: 'ARCTIC MONKEYS',
      year: '2013',
      thumbnailUrl: 'https://c.saavncdn.com/795/AM-English-2013-20240402165515-500x500.webp',
      tracks: [
        Track(
          id: 'iE8z2T-c',
          title: 'I WANNA BE YOURS',
          artist: 'ARCTIC MONKEYS',
          duration: Duration(minutes: 3, seconds: 3),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/795/AM-English-2013-20240402165515-500x500.webp',
          audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyPcN+8EbIZsfTDWD9VWGwA4lGR4i8vmIQnRE93NzlvsR3Hz7a0ZWayBw7tS9a8Gtq',
          lyrics: [],
        ),
        Track(
          id: 'am_diwk',
          title: 'DO I WANNA KNOW?',
          artist: 'ARCTIC MONKEYS',
          duration: Duration(minutes: 4, seconds: 32),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/795/AM-English-2013-20240402165515-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'am_rumine',
          title: 'R U MINE?',
          artist: 'ARCTIC MONKEYS',
          duration: Duration(minutes: 3, seconds: 21),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/795/AM-English-2013-20240402165515-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'am_arabella',
          title: 'ARABELLA',
          artist: 'ARCTIC MONKEYS',
          duration: Duration(minutes: 3, seconds: 27),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/795/AM-English-2013-20240402165515-500x500.webp',
          lyrics: [],
        ),
      ],
    ),
    const HitAlbum(
      id: 'alb_evolve',
      title: 'EVOLVE',
      artist: 'IMAGINE DRAGONS',
      year: '2017',
      thumbnailUrl: 'https://c.saavncdn.com/248/Evolve-English-2018-20260605220036-500x500.webp',
      tracks: [
        Track(
          id: 'BeXBcbVK',
          title: 'BELIEVER',
          artist: 'IMAGINE DRAGONS',
          duration: Duration(minutes: 3, seconds: 24),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/248/Evolve-English-2018-20260605220036-500x500.webp',
          audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDy3oAkJDMbq8VkXOZU65DcFdrDhsTWIRT7u/8vMld9DHecVMFCBmD5/Rw7tS9a8Gtq',
          lyrics: [],
        ),
        Track(
          id: 'ev_thunder',
          title: 'THUNDER',
          artist: 'IMAGINE DRAGONS',
          duration: Duration(minutes: 3, seconds: 7),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/248/Evolve-English-2018-20260605220036-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'ev_wit',
          title: 'WHATEVER IT TAKES',
          artist: 'IMAGINE DRAGONS',
          duration: Duration(minutes: 3, seconds: 21),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/248/Evolve-English-2018-20260605220036-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'ev_wtw',
          title: 'WALKING THE WIRE',
          artist: 'IMAGINE DRAGONS',
          duration: Duration(minutes: 3, seconds: 52),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/248/Evolve-English-2018-20260605220036-500x500.webp',
          lyrics: [],
        ),
      ],
    ),
    const HitAlbum(
      id: 'alb_afterhours',
      title: 'AFTER HOURS',
      artist: 'THE WEEKND',
      year: '2020',
      thumbnailUrl: 'https://c.saavncdn.com/077/After-Hours-English-2020-20260804045014-500x500.webp',
      tracks: [
        Track(
          id: 'fW-Mxsnu',
          title: 'BLINDING LIGHTS',
          artist: 'THE WEEKND',
          duration: Duration(minutes: 3, seconds: 20),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/077/After-Hours-English-2020-20260804045014-500x500.webp',
          audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyF/c5nqlFTXM0C74GbTF9AaylMpcN37HtcTaLl9ufWl/TC2QaaKAJJBw7tS9a8Gtq',
          lyrics: [],
        ),
        Track(
          id: 'ah_syt',
          title: 'SAVE YOUR TEARS',
          artist: 'THE WEEKND',
          duration: Duration(minutes: 3, seconds: 35),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/077/After-Hours-English-2020-20260804045014-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'ah_iye',
          title: 'IN YOUR EYES',
          artist: 'THE WEEKND',
          duration: Duration(minutes: 3, seconds: 57),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/077/After-Hours-English-2020-20260804045014-500x500.webp',
          lyrics: [],
        ),
      ],
    ),
    const HitAlbum(
      id: 'alb_hmhas',
      title: 'HIT ME HARD AND SOFT',
      artist: 'BILLIE EILISH',
      year: '2024',
      thumbnailUrl: 'https://c.saavncdn.com/707/HIT-ME-HARD-AND-SOFT-English-2024-20240517063536-500x500.webp',
      tracks: [
        Track(
          id: 'JR8ew5Yw',
          title: 'BIRDS OF A FEATHER',
          artist: 'BILLIE EILISH',
          duration: Duration(minutes: 3, seconds: 30),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/707/HIT-ME-HARD-AND-SOFT-English-2024-20240517063536-500x500.webp',
          audioUrl: 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyCj3kCFHZmBd3rXivMuxf3sdQvTTi+C/DtCwhwGmNiaIvWDkv7Mlhgxw7tS9a8Gtq',
          lyrics: [],
        ),
        Track(
          id: 'b_lunch',
          title: 'LUNCH',
          artist: 'BILLIE EILISH',
          duration: Duration(minutes: 2, seconds: 59),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/707/HIT-ME-HARD-AND-SOFT-English-2024-20240517063536-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'b_chihiro',
          title: 'CHIHIRO',
          artist: 'BILLIE EILISH',
          duration: Duration(minutes: 5, seconds: 3),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/707/HIT-ME-HARD-AND-SOFT-English-2024-20240517063536-500x500.webp',
          lyrics: [],
        ),
      ],
    ),
    const HitAlbum(
      id: 'alb_aashiqui2',
      title: 'AASHIQUI 2',
      artist: 'ARIJIT SINGH, MITHOON',
      year: '2013',
      thumbnailUrl: 'https://c.saavncdn.com/835/Aashiqui-2-Hindi-2013-20201215180126-500x500.webp',
      tracks: [
        Track(
          id: 'a2_tumhiho',
          title: 'TUM HI HO',
          artist: 'ARIJIT SINGH',
          duration: Duration(minutes: 4, seconds: 22),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/835/Aashiqui-2-Hindi-2013-20201215180126-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'a2_sunnraha',
          title: 'SUNN RAHA HAI',
          artist: 'ANKIT TIWARI',
          duration: Duration(minutes: 6, seconds: 30),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/835/Aashiqui-2-Hindi-2013-20201215180126-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'a2_chahun',
          title: 'CHAHUN MAIN YA NAA',
          artist: 'ARIJIT SINGH, PALAK MUCHHAL',
          duration: Duration(minutes: 5, seconds: 4),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/835/Aashiqui-2-Hindi-2013-20201215180126-500x500.webp',
          lyrics: [],
        ),
      ],
    ),
    const HitAlbum(
      id: 'alb_parachutes',
      title: 'PARACHUTES',
      artist: 'COLDPLAY',
      year: '2000',
      thumbnailUrl: 'https://c.saavncdn.com/829/Parachutes-English-2000-20240402164415-500x500.webp',
      tracks: [
        Track(
          id: 'cp_yellow',
          title: 'YELLOW',
          artist: 'COLDPLAY',
          duration: Duration(minutes: 4, seconds: 29),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/829/Parachutes-English-2000-20240402164415-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'cp_shiver',
          title: 'SHIVER',
          artist: 'COLDPLAY',
          duration: Duration(minutes: 4, seconds: 59),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/829/Parachutes-English-2000-20240402164415-500x500.webp',
          lyrics: [],
        ),
        Track(
          id: 'cp_trouble',
          title: 'TROUBLE',
          artist: 'COLDPLAY',
          duration: Duration(minutes: 4, seconds: 30),
          genreTag: 'ALBUM',
          isOffline: false,
          thumbnailUrl: 'https://c.saavncdn.com/829/Parachutes-English-2000-20240402164415-500x500.webp',
          lyrics: [],
        ),
      ],
    ),
  ];

  final List<Track> _globalHits = [
    const Track(
      id: 'gh_heatwaves',
      title: 'HEAT WAVES',
      artist: 'GLASS ANIMALS',
      duration: Duration(minutes: 3, seconds: 58),
      genreTag: 'GLOBAL',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/279/Dreamland-English-2020-20200806041014-500x500.jpg',
      lyrics: [],
    ),
    const Track(
      id: 'gh_stay',
      title: 'STAY',
      artist: 'THE KID LAROI, JUSTIN BIEBER',
      duration: Duration(minutes: 2, seconds: 21),
      genreTag: 'GLOBAL',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/492/Stay-English-2021-20210708043232-500x500.jpg',
      lyrics: [],
    ),
    const Track(
      id: 'gh_sunflower',
      title: 'SUNFLOWER',
      artist: 'POST MALONE, SWAE LEE',
      duration: Duration(minutes: 2, seconds: 38),
      genreTag: 'GLOBAL',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/812/Spider-Man-Into-the-Spider-Verse-Soundtrack-English-2018-20181213031014-500x500.jpg',
      lyrics: [],
    ),
    const Track(
      id: 'gh_shapeofyou',
      title: 'SHAPE OF YOU',
      artist: 'ED SHEERAN',
      duration: Duration(minutes: 3, seconds: 53),
      genreTag: 'GLOBAL',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/869/Shape-of-You-English-2017-500x500.jpg',
      lyrics: [],
    ),
    const Track(
      id: 'gh_onedance',
      title: 'ONE DANCE',
      artist: 'DRAKE, WIZKID, KYLA',
      duration: Duration(minutes: 2, seconds: 54),
      genreTag: 'GLOBAL',
      isOffline: false,
      thumbnailUrl: 'https://c.saavncdn.com/978/Views-English-2016-500x500.jpg',
      lyrics: [],
    ),
  ];

  final List<Track> _synthwaveHits = [
    const Track(
      id: 'synth_midnight',
      title: 'MIDNIGHT CITY',
      artist: 'M83',
      duration: Duration(minutes: 4, seconds: 3),
      genreTag: 'SYNTH',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500',
      lyrics: [],
    ),
    const Track(
      id: 'synth_nightcall',
      title: 'NIGHTCALL',
      artist: 'KAVINSKY',
      duration: Duration(minutes: 4, seconds: 19),
      genreTag: 'SYNTH',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
      lyrics: [],
    ),
    const Track(
      id: 'synth_resonance',
      title: 'RESONANCE',
      artist: 'HOME',
      duration: Duration(minutes: 3, seconds: 32),
      genreTag: 'SYNTH',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
      lyrics: [],
    ),
    const Track(
      id: 'synth_perfectgirl',
      title: 'THE PERFECT GIRL',
      artist: 'MAREUX',
      duration: Duration(minutes: 3, seconds: 14),
      genreTag: 'SYNTH',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500',
      lyrics: [],
    ),
  ];

  final List<Track> _lofiHits = [
    const Track(
      id: 'lofi_snowman',
      title: 'SNOWMAN',
      artist: 'WYS',
      duration: Duration(minutes: 3, seconds: 15),
      genreTag: 'LO-FI',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500',
      lyrics: [],
    ),
    const Track(
      id: 'lofi_affection',
      title: 'AFFECTION',
      artist: 'JINSANG',
      duration: Duration(minutes: 2, seconds: 40),
      genreTag: 'LO-FI',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500',
      lyrics: [],
    ),
    const Track(
      id: 'lofi_coffee',
      title: 'COFFEE',
      artist: 'BEABADOOBEE',
      duration: Duration(minutes: 2, seconds: 6),
      genreTag: 'LO-FI',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500',
      lyrics: [],
    ),
  ];

  List<Track> getDefaultTracks() => List.unmodifiable(_top10WeeklyTracks);
  List<Track> getTop10WeeklyTracks() => List.unmodifiable(_top10WeeklyTracks);
  List<HitAlbum> getHitAlbums() => List.unmodifiable(_hitAlbums);
  List<Track> getGlobalTopHits() => List.unmodifiable(_globalHits);
  List<Track> getRetroSynthwaveHits() => List.unmodifiable(_synthwaveHits);
  List<Track> getLofiChillHits() => List.unmodifiable(_lofiHits);

  String _cleanHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  String? _decryptSaavnUrl(String? encryptedUrl) {
    if (encryptedUrl == null || encryptedUrl.isEmpty) return null;
    try {
      final key = utf8.encode('38346591');
      final encryptedBytes = base64.decode(encryptedUrl);
      final des = DES(key: key, mode: DESMode.ECB, paddingType: DESPaddingType.PKCS7);
      final decryptedBytes = des.decrypt(encryptedBytes);
      final raw = utf8.decode(decryptedBytes).trim();
      if (raw.endsWith('_96.mp4')) {
        return raw.replaceAll('_96.mp4', '_320.mp4');
      }
      return raw;
    } catch (_) {
      return null;
    }
  }

  Future<List<Track>> searchTracks(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return getDefaultTracks();
    }

    try {
      final futures = await Future.wait([
        _searchViaAutocomplete(cleanQuery),
        _searchViaGetResults(cleanQuery),
      ]);

      final autoResults = futures[0];
      final getResults = futures[1];

      final Map<String, Track> uniqueTracks = {};
      for (final t in autoResults) {
        uniqueTracks[t.id] = t;
      }
      for (final t in getResults) {
        if (!uniqueTracks.containsKey(t.id)) {
          uniqueTracks[t.id] = t;
        }
      }

      if (uniqueTracks.isNotEmpty) {
        return uniqueTracks.values.toList();
      }

      return _filterFallback(cleanQuery);
    } catch (_) {
      return _filterFallback(cleanQuery);
    }
  }

  Future<List<Track>> _searchViaGetResults(String cleanQuery) async {
    try {
      final uri = Uri.parse(
          'https://www.jiosaavn.com/api.php?__call=search.getResults&q=${Uri.encodeComponent(cleanQuery)}&_format=json&_marker=0&ctx=android&p=1&n=25');
      final response = await http
          .get(uri, headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body);
      final results = (data['results'] as List?) ?? [];
      final List<Track> tracks = [];

      for (final item in results) {
        final id = item['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        final title = _cleanHtml(item['song']?.toString() ?? item['title']?.toString() ?? 'UNTITLED').toUpperCase();
        final artist = _cleanHtml(item['primary_artists']?.toString() ?? item['singers']?.toString() ?? 'UNKNOWN').toUpperCase();

        final enc = item['encrypted_media_url']?.toString();
        final preview = item['media_preview_url']?.toString();
        final streamUrl = _decryptSaavnUrl(enc) ?? preview;
        if (streamUrl == null || streamUrl.isEmpty) continue;

        int durSecs = 180;
        final rawDuration = item['duration'];
        if (rawDuration != null) {
          durSecs = int.tryParse(rawDuration.toString()) ?? 180;
        }

        var image = item['image']?.toString() ?? '';
        if (image.contains('150x150')) {
          image = image.replaceAll('150x150', '500x500');
        }

        tracks.add(
          Track(
            id: id,
            title: title,
            artist: artist,
            duration: Duration(seconds: durSecs),
            genreTag: (item['language']?.toString() ?? 'RETRO').toUpperCase(),
            audioUrl: streamUrl,
            thumbnailUrl: image.isNotEmpty ? image : null,
            isOffline: false,
            lyrics: [
              LyricLine(timestamp: Duration.zero, text: 'PLAYING: $title'),
              LyricLine(timestamp: const Duration(seconds: 4), text: 'ARTIST: $artist'),
              const LyricLine(timestamp: Duration(seconds: 8), text: 'SYNCHRONIZING RETRO LYRICS...'),
            ],
          ),
        );
      }
      return tracks;
    } catch (_) {
      return [];
    }
  }

  Future<List<Track>> _searchViaAutocomplete(String cleanQuery) async {
    try {
      final autoUri = Uri.parse(
          'https://www.jiosaavn.com/api.php?__call=autocomplete.get&query=${Uri.encodeComponent(cleanQuery)}&_format=json&_marker=0&ctx=android');
      final autoResp = await http
          .get(autoUri, headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
          .timeout(const Duration(seconds: 8));

      if (autoResp.statusCode != 200) return [];
      final autoData = jsonDecode(autoResp.body);
      final songs = (autoData['songs']?['data'] as List?) ?? [];
      if (songs.isEmpty) return [];

      final pids = songs.map((s) => s['id']).take(15).join(',');
      final detailsUri = Uri.parse(
          'https://www.jiosaavn.com/api.php?__call=song.getDetails&pids=$pids&_format=json&_marker=0&ctx=android');
      final detResp = await http
          .get(detailsUri, headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
          .timeout(const Duration(seconds: 8));

      if (detResp.statusCode != 200) return [];
      final detData = jsonDecode(detResp.body);
      final List<Track> autoTracks = [];
      for (final songItem in songs) {
        final sid = songItem['id']?.toString() ?? '';
        final songObj = detData[sid];
        if (songObj == null) continue;

        final title = _cleanHtml(songObj['song']?.toString() ?? songItem['title']?.toString() ?? 'UNTITLED').toUpperCase();
        final artist = _cleanHtml(songObj['primary_artists']?.toString() ?? songItem['description']?.toString() ?? 'UNKNOWN').toUpperCase();

        final enc = songObj['encrypted_media_url']?.toString();
        final preview = songObj['media_preview_url']?.toString();
        final streamUrl = _decryptSaavnUrl(enc) ?? preview;
        if (streamUrl == null || streamUrl.isEmpty) continue;

        var image = songObj['image']?.toString() ?? songItem['image']?.toString() ?? '';
        if (image.contains('150x150')) {
          image = image.replaceAll('150x150', '500x500');
        }

        int durSecs = int.tryParse(songObj['duration']?.toString() ?? '180') ?? 180;

        autoTracks.add(
          Track(
            id: sid,
            title: title,
            artist: artist,
            duration: Duration(seconds: durSecs),
            genreTag: (songObj['language']?.toString() ?? 'RETRO').toUpperCase(),
            audioUrl: streamUrl,
            thumbnailUrl: image.isNotEmpty ? image : null,
            isOffline: false,
            lyrics: [
              LyricLine(timestamp: Duration.zero, text: 'PLAYING: $title'),
              LyricLine(timestamp: const Duration(seconds: 4), text: 'ARTIST: $artist'),
              const LyricLine(timestamp: Duration(seconds: 8), text: 'SYNCHRONIZING RETRO LYRICS...'),
            ],
          ),
        );
      }
      return autoTracks;
    } catch (_) {
      return [];
    }
  }

  Future<List<Track>> getSimilarTracks(Track track) async {
    try {
      if (track.id.isNotEmpty && !track.id.startsWith('default_') && !track.id.startsWith('sp_')) {
        final uri = Uri.parse(
            'https://www.jiosaavn.com/api.php?__call=reco.getreco&api_version=4&_format=json&_marker=0&ctx=android&pid=${track.id}');
        final resp = await http
            .get(uri, headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
            .timeout(const Duration(seconds: 5));

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final items = (data[track.id] as List?) ?? [];
          final List<Track> recos = [];

          for (final it in items) {
            final sid = it['id']?.toString() ?? '';
            if (sid.isEmpty || sid == track.id) continue;

            final title = _cleanHtml(it['title']?.toString() ?? 'UNTITLED').toUpperCase();
            final artist = _cleanHtml(it['subtitle']?.toString() ?? track.artist).toUpperCase();

            final enc = it['more_info']?['encrypted_media_url']?.toString();
            final streamUrl = _decryptSaavnUrl(enc);
            if (streamUrl == null || streamUrl.isEmpty) continue;

            var image = it['image']?.toString() ?? '';
            if (image.contains('150x150')) {
              image = image.replaceAll('150x150', '500x500');
            }

            int durSecs = int.tryParse(it['more_info']?['duration']?.toString() ?? '180') ?? 180;

            recos.add(
              Track(
                id: sid,
                title: title,
                artist: artist,
                duration: Duration(seconds: durSecs),
                genreTag: 'AUTO',
                audioUrl: streamUrl,
                thumbnailUrl: image.isNotEmpty ? image : null,
                isOffline: false,
                lyrics: [
                  LyricLine(timestamp: Duration.zero, text: 'PLAYING: $title'),
                  LyricLine(timestamp: const Duration(seconds: 4), text: 'ARTIST: $artist'),
                  const LyricLine(timestamp: Duration(seconds: 8), text: 'SYNCHRONIZING RETRO LYRICS...'),
                ],
              ),
            );
          }

          if (recos.isNotEmpty) {
            return recos;
          }
        }
      }

      final artistTracks = await searchTracks(track.artist);
      final filtered = artistTracks.where((t) => t.id != track.id).toList();
      if (filtered.isNotEmpty) {
        return filtered;
      }
    } catch (_) {}

    return _top10WeeklyTracks.where((t) => t.id != track.id).toList();
  }

  List<Track> _filterFallback(String query) {
    return _top10WeeklyTracks.where((track) {
      return track.title.toLowerCase().contains(query.toLowerCase()) ||
          track.artist.toLowerCase().contains(query.toLowerCase()) ||
          track.genreTag.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<ResolvedStream?> resolveAudioStream(Track track) async {
    if (track.audioUrl != null && track.audioUrl!.startsWith('http')) {
      return ResolvedStream(
        url: track.audioUrl!,
        totalBytes: 0,
        contentType: 'audio/mp4',
      );
    }

    if (track.audioUrl != null && track.audioUrl!.isNotEmpty) {
      final decrypted = _decryptSaavnUrl(track.audioUrl!);
      if (decrypted != null && decrypted.startsWith('http')) {
        return ResolvedStream(
          url: decrypted,
          totalBytes: 0,
          contentType: 'audio/mp4',
        );
      }
    }

    try {
      final searchResults = await searchTracks('${track.title} ${track.artist}');
      if (searchResults.isNotEmpty) {
        final first = searchResults.first;
        if (first.audioUrl != null && first.audioUrl!.startsWith('http')) {
          return ResolvedStream(
            url: first.audioUrl!,
            totalBytes: 0,
            contentType: 'audio/mp4',
          );
        }
      }
    } catch (_) {}

    return null;
  }

  Future<String?> resolveAudioStreamUrl(Track track) async {
    final stream = await resolveAudioStream(track);
    return stream?.url;
  }

  Future<List<LyricLine>> fetchLyrics(String title, String artist) async {
    try {
      final cleanTitle = title
          .replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '')
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();
      final cleanArtist = artist
          .replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '')
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();

      final getUri = Uri.parse(
          'https://lrclib.net/api/get?track_name=${Uri.encodeComponent(cleanTitle)}&artist_name=${Uri.encodeComponent(cleanArtist)}');
      final res1 = await http
          .get(getUri, headers: {'User-Agent': 'Ayutune/1.0'})
          .timeout(const Duration(seconds: 4));

      if (res1.statusCode == 200) {
        final data = jsonDecode(res1.body);
        final synced = data['syncedLyrics'] as String?;
        if (synced != null && synced.trim().isNotEmpty) {
          return _parseLrc(synced);
        }
        final plain = data['plainLyrics'] as String?;
        if (plain != null && plain.trim().isNotEmpty) {
          return _parsePlain(plain);
        }
      }

      final searchUri = Uri.parse(
          'https://lrclib.net/api/search?q=${Uri.encodeComponent('$cleanTitle $cleanArtist')}');
      final res2 = await http
          .get(searchUri, headers: {'User-Agent': 'Ayutune/1.0'})
          .timeout(const Duration(seconds: 4));

      if (res2.statusCode == 200) {
        final list = jsonDecode(res2.body) as List;
        if (list.isNotEmpty) {
          final first = list.first;
          final synced = first['syncedLyrics'] as String?;
          if (synced != null && synced.trim().isNotEmpty) {
            return _parseLrc(synced);
          }
          final plain = first['plainLyrics'] as String?;
          if (plain != null && plain.trim().isNotEmpty) {
            return _parsePlain(plain);
          }
        }
      }
    } catch (_) {}

    return [];
  }

  List<LyricLine> _parseLrc(String lrc) {
    final List<LyricLine> lines = [];
    final regex = RegExp(r'^\[(\d{2}):(\d{2}(?:\.\d+)?)\](.*)$');
    for (final raw in lrc.split('\n')) {
      final trimmed = raw.trim();
      final match = regex.firstMatch(trimmed);
      if (match != null) {
        final mins = int.tryParse(match.group(1) ?? '0') ?? 0;
        final secs = double.tryParse(match.group(2) ?? '0') ?? 0.0;
        final ms = (mins * 60 * 1000 + secs * 1000).round();
        final text = match.group(3)?.trim() ?? '';
        if (text.isNotEmpty) {
          lines.add(LyricLine(
            timestamp: Duration(milliseconds: ms),
            text: text.toUpperCase(),
          ));
        }
      }
    }
    return lines;
  }

  List<LyricLine> _parsePlain(String plain) {
    final List<LyricLine> lines = [];
    final rawLines = plain
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (int i = 0; i < rawLines.length; i++) {
      lines.add(LyricLine(
        timestamp: Duration(seconds: i * 5),
        text: rawLines[i].toUpperCase(),
      ));
    }
    return lines;
  }

  void dispose() {}
}
