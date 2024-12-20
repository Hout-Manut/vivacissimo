import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivacissimo/models/entity.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:vivacissimo/services/cache.dart';
import 'package:vivacissimo/services/vivacissimo_service.dart';

class MusicbrainzApi {
  static const String _endpoint = 'https://musicbrainz.org/ws/2';
  static const String _relaseCoverArtEndpoint = 'https://coverartarchive.org';
  static const String _format = 'json';
  static const Map<String, String> _headers = {
    'User-Agent': 'UnnamedSchoolProject/0.1 (manut.hout@student.cadt.edu.kh)'
  };

  static Future<Map<String, dynamic>> search(
    String query, {
    int limit = 5,
    int offset = 0,
    required EntityType type,
  }) async {
    final Map<String, String> queryParams = {
      'query': query,
      'fmt': _format,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final Uri uri = Uri.parse("$_endpoint/${type.mbName}/")
        .replace(queryParameters: queryParams);
    try {
      final http.Response response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      throw HttpException;
    }
    throw HttpException;
  }

  static Future<Map<String, dynamic>> cachedSearch(
    String query, {
    int limit = 5,
    int offset = 0,
    required EntityType type,
  }) async {
    final cacheKey = 'search-$query-$limit-$offset-${type.name}';

    return await Cache.cacheAsync(
      cacheKey,
      () => search(
        query,
        limit: limit,
        offset: offset,
        type: type,
      ),
    );
  }

  static Future<String?> getCoverArt(String mbid, {required EntityType type}) async {
    final Directory? directory = await VivacissimoService.getAppDirectory();
    if (directory == null) return null;

  }
}

String getPrettyJSONString(jsonObject) {
  var encoder = const JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}

void main() async {
  Map<String, dynamic> result =
      await MusicbrainzApi.cachedSearch("alter ego", limit: 1);

  print(getPrettyJSONString(result));
}
