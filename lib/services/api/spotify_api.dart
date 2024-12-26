import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivacissimo/services/vivacissimo.dart';

import '../../models/models.dart';

class SpotifyApi {
  static String _token = "";
  static String _tokenType = "Bearer";
  static int _expiresIn = 0;
  static DateTime? _tokenDate;
  static bool _isUserAuthenticated = false;

  static const _endpoint = "https://api.spotify.com/v1";
  static const _tokenEndpoint = "https://accounts.spotify.com/api/token";
  static const Map<String, String> _tokenHeaders = {
    "Content-Type": "application/x-www-form-urlencoded",
  };

  static const List<String> _scopes = [
    "playlist-modify-public",
    "playlist-modify-private",
    "user-library-read",
    "user-library-modify"
  ];

  static String getAuthorizationUrl(String redirectUri) {
    final clientId = dotenv.env["SPOTIFY_CLIENT_ID"] ?? "";
    final scope = _scopes.join(" "); // Combine scopes into a space-separated string

    return "https://accounts.spotify.com/authorize"
           "?response_type=code"
           "&client_id=$clientId"
           "&redirect_uri=$redirectUri"
           "&scope=$scope";
  }

  static Future<void> authenticateUser(String redirectUri) async {
    final authUrl = getAuthorizationUrl(redirectUri);
    printDebug("Unimplemented auth: $authUrl");
  }

  static Future<void> fetchAccessToken(String code, String redirectUri) async {
    final String clientId = dotenv.env["SPOTIFY_CLIENT_ID"] ?? "";
    final String clientSecret = dotenv.env["SPOTIFY_CLIENT_SECRET"] ?? "";

    final body = {
      "grant_type": "authorization_code",
      "code": code,
      "redirect_uri": redirectUri,
      "client_id": clientId,
      "client_secret": clientSecret,
    };

    final response = await http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data["access_token"] ?? "";
      _tokenType = data["token_type"] ?? "Bearer";
      _expiresIn = data["expires_in"] ?? 0;
      _tokenDate = DateTime.now();
      _isUserAuthenticated = true;
      print("Access token fetched successfully");
    } else {
      printDebug("Failed to fetch access token: ${response.body}");
    }
  }

  static void checkToken() {
    if (_token.isEmpty ||
        _tokenDate == null ||
        DateTime.now().difference(_tokenDate!).inSeconds + 60 >= _expiresIn) {
      if (_isUserAuthenticated) {
        throw Exception("User authentication required. Fetch an access token first.");
      } else {
        _refreshToken();
      }
    }
  }

  static Future<void> _refreshToken() async {
    final String clientId = dotenv.env["SPOTIFY_CLIENT_ID"] ?? "";
    final String clientSecret = dotenv.env["SPOTIFY_CLIENT_SECRET"] ?? "";
    if (clientSecret.isEmpty || clientId.isEmpty) {
      printDebug("Error: Spotify client id and secret are unset");
    }
    try {
      final body = {
        "grant_type": "client_credentials",
        "client_id": clientId,
        "client_secret": clientSecret,
      };
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: _tokenHeaders,
        body: body,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data["access_token"] ?? "";
        _tokenType = data["token_type"] ?? "Bearer";
        _expiresIn = data["expires_in"] ?? 0;
        _tokenDate = DateTime.now();
      } else {
        printDebug(
            "Failed to refresh token: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      printDebug("Error during token refresh: $e");
    }
  }

  static Future<List<Entity>> search(String query) async {
    final List<String> queryParts = query.trim().split(' ');
    List<String> combinations = [];

    if (queryParts.length > 1) {
      for (int i = 1; i < queryParts.length; i++) {
        String releaseName = queryParts.sublist(0, i).join(' ');
        String artistName = queryParts.sublist(i).join(' ');
        combinations.add(
          "track:$releaseName  artist:$artistName",
        );
        combinations.add(
          "track:$artistName artist:$releaseName",
        );
      }
    } else if (queryParts.isEmpty) {
      return [];
    } else {
      combinations.add("track:${queryParts[0]}");
      combinations.add("artist:${queryParts[0]}");
    }

    final List<Future<http.Response>> requests = [];

    for (String combination in combinations) {
      try {
        final Uri uri = Uri.parse(
            '$_endpoint/search/?q=$combination&type=track&market=KH&limit=5&offset=0');
        requests.add(http.get(uri));
      } catch (e) {
        printDebug("Error: $e");
      }
    }
    final List<http.Response> responses = await Future.wait(requests);

    List<Release> releases = [];
    Set<String> addedIds = {};

    for (final http.Response response in responses) {
      if (response.statusCode != 200) continue;
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      if (data["tracks"] == null) continue;
      for (Map<String, dynamic> release in data['releases']) {
        if (addedIds.contains(release['id'])) continue;
        printDebug(release);
        releases.add(Release.fromSpotify(release));
        addedIds.add(release['id']);
      }
    }
    releases.sort((a, b) {
      int scoreA = _calculateMatchScore(a, queryParts);
      int scoreB = _calculateMatchScore(b, queryParts);
      return scoreB.compareTo(scoreA);
    });

    return releases;
  }

  static int _calculateMatchScore(Release release, List<String> queryParts) {
    final List<String> titleParts = release.title.toLowerCase().split(' ');
    final List<String> creditParts =
        release.credit.toString().toLowerCase().split(' ');

    int score = 0;

    for (String queryPart in queryParts) {
      if (titleParts.contains(queryPart.toLowerCase())) {
        score++;
      }
      if (creditParts.contains(queryPart.toLowerCase())) {
        score++;
      }
    }

    return score;
  }

  static Future<SpotifyPlaylist> createPlaylist(
      {Playlist? playlist, String? playlistId}) async {
    if (playlist == null && playlistId == null) {
      printDebug("Error: No arguments provided to create a Spotify playlist");
      throw Exception("Invalid arguments for createPlaylist");
    }

    checkToken();

    Playlist? targetPlaylist;
    if (playlist != null) {
      targetPlaylist = playlist;
    } else {
      targetPlaylist = Vivacissimo.getPlaylistById(playlistId!);
    }
    if (targetPlaylist == null) throw Exception();

    try {
      // Create the playlist
      final response = await http.post(
        Uri.parse("$_endpoint/users/${Vivacissimo.userId}/playlists"),
        headers: {
          "Authorization": "$_tokenType $_token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "name": playlist!.title,
          "description": "Created via API",
          "public": false,
        }),
      );

      if (response.statusCode == 201) {
        final playlistData = json.decode(response.body);
        final spotifyPlaylist = SpotifyPlaylist.fromSpotify(
          playlistData,
          sourceId: playlist.id,
        );

        // Add songs to the playlist
        if (playlist.releases.isNotEmpty) {
          final trackUris =
              await Future.wait(playlist.releases.map((song) async {
            if (song.spotifyUri != null) {
              return song.spotifyUri!;
            } else {
              // Search for the song
              final searchResults =
                  await search("${song.title} ${song.credit.toString()}");
              if (searchResults.isNotEmpty) {
                return searchResults.first.spotifyUri;
              }
            }
            return null;
          }));

          final filteredUris = trackUris.whereType<String>().toList();

          if (filteredUris.isNotEmpty) {
            final addTracksResponse = await http.post(
              Uri.parse("$_endpoint/playlists/${spotifyPlaylist.id}/tracks"),
              headers: {
                "Authorization": "$_tokenType $_token",
                "Content-Type": "application/json",
              },
              body: json.encode({
                "uris": filteredUris,
              }),
            );

            if (addTracksResponse.statusCode != 201) {
              printDebug("Failed to add tracks: ${addTracksResponse.body}");
            }
          }
        }

        return spotifyPlaylist;
      } else {
        printDebug("Failed to create playlist: ${response.body}");
        throw Exception("Failed to create playlist");
      }
    } catch (e) {
      printDebug("Error in createPlaylist: $e");
      rethrow;
    }
  }
}
