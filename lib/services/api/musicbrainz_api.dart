import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivacissimo/models/entity.dart';
import 'dart:io';

class MusicbrainzApi {
  static const String _endpoint = 'https://musicbrainz.org/ws/2';
  static const String _coverArtEndpoint = 'https://coverartarchive.org';
  static const String _format = 'json';
  static const Map<String, String> headers = {
    'User-Agent': 'UnnamedSchoolProject/0.1 (manut.hout@student.cadt.edu.kh)'
  };

  static Future<Release?> searchOneRelease(String title, String artist) async {
    String arg =
        "${title.replaceAll(" ", "+")}+artist:${artist.replaceAll(" ", "+")}";
    List<Release> results = await searchReleases(arg, limit: 10);

    for (Release release in results) {
      return release;
      // print("${release.title} - ${release.credit}");
      // if (release.title.toLowerCase() == title.toLowerCase() &&
      //     release.credit.toString().toLowerCase() == artist.toLowerCase()) {
      //   return release;
      // }
    }
    return null;
  }

  static Future<List<Release>> searchReleases(
    String query, {
    int limit = 5,
    int offset = 0,
  }) async {
    final List<String> queryParts = query.trim().split(' ');

    List<String> combinations = [];

    if (queryParts.length > 1) {
      for (int i = 1; i < queryParts.length; i++) {
        String releaseName = queryParts.sublist(0, i).join(' ');
        String artistName = queryParts.sublist(i).join(' ');
        combinations.add(
          "release:$releaseName  artist:$artistName",
        );
        combinations.add(
          "release:$artistName artist:$releaseName",
        );
      }
    } else if (queryParts.isEmpty) {
      return [];
    } else {
      combinations.add("release:${queryParts[0]}");
    }

    final List<Future<http.Response>> requests =
        combinations.map((combination) {
      final Uri uri = Uri.parse(
          '$_endpoint/release/?query=$combination&fmt=$_format&limit=$limit&offset=$offset');
      return http.get(uri, headers: headers);
    }).toList();

    final List<http.Response> responses = await Future.wait(requests);

    List<Release> releases = [];
    Set<String> addedIds = {};
    for (final http.Response response in responses) {
      if (response.statusCode != 200) continue;
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      if (data["releases"] == null) continue;
      for (Map<String, dynamic> release in data['releases']) {
        if (addedIds.contains(release['id'])) continue;
        releases.add(Release.fromMusicBrainz(release));
        addedIds.add(release['id']);
      }
    }
    return releases;
  }

  static Future<String?> getImageUrl(
    String mbid, {
    String dimension = '1200',
  }) async {
    final Uri uri = Uri.parse('$_coverArtEndpoint/release/$mbid');

    final tempHeader = {
      'User-Agent': headers['User-Agent']!,
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(uri, headers: tempHeader);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['images'] != null && data['images'].isNotEmpty) {
          for (var image in data['images']) {
            if (image['thumbnails'] != null) {
              return image['thumbnails'][dimension] ??
                  image['thumbnails']['large'] ??
                  image['thumbnails']['500'] ??
                  image['thumbnails']['small'];
            }
          }
        } else {
          throw const HttpException("No Image Found");
        }
      } else if (response.statusCode == 404) {
        throw const HttpException("No Image Found");
      } else {
        throw HttpException;
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  static Future<String?> getImageUrlAlt(String mbid) async {
    return '$_coverArtEndpoint/release/$mbid/front';
  }
}
