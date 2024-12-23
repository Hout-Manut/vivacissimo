import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vivacissimo/dummy_data/data.dart';
import 'package:vivacissimo/services/api/gemini_api.dart';
import '../models/models.dart';

class Vivacissimo {
  static const String _releaseFilename = "releases.json";
  static final List<Release> _savedReleases = [];
  static List<Release> get releases => _savedReleases;

  static const String _artistFilename = "artists.json";
  static final List<Artist> _savedArtists = [];
  static List<Artist> get artists => _savedArtists;

  static const String _playlistFilename = "playlists.json";
  static final List<Playlist> _savedPlaylists = [aPlaylist];
  static List<Playlist> get playlists => _savedPlaylists;

  static const String _tagFilename = "tags.json";
  static final List<Tag> _savedTags = [];
  static List<Tag> get tags => _savedTags;

  static bool loaded = false;

  static const JsonEncoder encoder = JsonEncoder.withIndent("  ");

  static void setPlaylist(Playlist newPlaylist) {
    int? oldIndex;
    _savedPlaylists.asMap().forEach((index, item) {
      if (item.id == newPlaylist.id) oldIndex = index;
    });
    if (oldIndex == null) {
      _savedPlaylists.add(newPlaylist);
    } else {
      _savedPlaylists[oldIndex!] = newPlaylist;
    }
  }

  static Release? getReleaseById(String id) {
    if (!loaded) loadData();
    for (Release release in _savedReleases) {
      if (release.id == id) return release;
    }
    return null;
  }

  static Artist? getArtistById(String id) {
    if (!loaded) loadData();
    for (Artist artist in _savedArtists) {
      if (artist.id == id) return artist;
    }
    return null;
  }

  static Playlist? getPlaylistById(String id) {
    if (!loaded) loadData();
    for (Playlist playlist in _savedPlaylists) {
      if (playlist.id == id) return playlist;
    }
    return null;
  }

  static Tag? getTagById(String id) {
    if (!loaded) loadData();
    for (Tag tag in _savedTags) {
      if (tag.id == id) return tag;
    }
    return null;
  }

  static Future<void> loadData() async {
    final Directory? data = await getAppDirectory("/data");
    if (data == null) return;
    if (loaded) return;

    // Helper function to load data from a file
    Future<void> loadFile(
      String filename,
      void Function(List<dynamic>) onLoad,
    ) async {
      File file = File('${data.path}/$filename');
      if (await file.exists()) {
        try {
          List<dynamic> jsonData =
              jsonDecode(utf8.decode(await file.readAsBytes()));
          onLoad(jsonData);
        } catch (e) {
          rethrow;
        }
      }
    }

    await loadFile(_releaseFilename, (jsonData) {
      _savedReleases.clear();
      _savedReleases.addAll(jsonData.map((json) => Release.fromJson(json)));
    });

    await loadFile(_artistFilename, (jsonData) {
      _savedArtists.clear();
      _savedArtists.addAll(jsonData.map((json) => Artist.fromJson(json)));
    });

    await loadFile(_playlistFilename, (jsonData) {
      _savedPlaylists.clear();
      _savedPlaylists.addAll(jsonData.map((json) => Playlist.fromJson(json)));
    });

    await loadFile(_tagFilename, (jsonData) {
      _savedTags.clear();
      _savedTags.addAll(jsonData.map((json) => Tag.fromJson(json)));
    });
    loaded = true;
    print("Data was loaded");
  }

  static void saveData() async {
    Directory? data = await getAppDirectory("/data");
    if (data == null) return;
    if (!await data.exists()) {
      await data.create(recursive: true);
    }

    // Save releases
    File releaseFile = File('${data.path}/$_releaseFilename');
    await releaseFile.writeAsString(
        encoder.convert(_savedReleases.map((r) => r.toJson()).toList()),
        encoding: utf8);

    // Save artists
    File artistFile = File('${data.path}/$_artistFilename');
    await artistFile.writeAsString(
        encoder.convert(_savedArtists.map((a) => a.toJson()).toList()),
        encoding: utf8);

    // Save playlists
    File playlistFile = File('${data.path}/$_playlistFilename');
    await playlistFile.writeAsString(
        encoder.convert(_savedPlaylists.map((p) => p.toJson()).toList()),
        encoding: utf8);

    // Save tags
    File tagFile = File('${data.path}/$_tagFilename');
    await tagFile.writeAsString(
        encoder.convert(_savedTags.map((t) => t.toJson()).toList()),
        encoding: utf8);
    print("Data saved");
  }

  static void deleteData() async {
    Directory? data = await getAppDirectory("/data");
    if (data == null) return;

    // Helper function to delete a file
    Future<void> deleteFile(String filename) async {
      File file = File('${data.path}/$filename');
      if (await file.exists()) {
        try {
          await file.delete();
          print('Deleted file: $filename');
        } catch (e) {
          print('Error deleting file $filename: $e');
        }
      } else {
        print('File $filename does not exist.');
      }
    }

    await deleteFile(_releaseFilename);
    await deleteFile(_artistFilename);
    await deleteFile(_playlistFilename);
    await deleteFile(_tagFilename);
  }

  static Future<Directory?> getAppDirectory([String path = ""]) async {
    try {
      Platform.operatingSystem;
    } on UnsupportedError {
      return null;
    }

    try {
      Directory baseDirectory = await getApplicationDocumentsDirectory();
      Directory appDirectory =
          Directory('${baseDirectory.path}/vivacissimo$path');
      if (!appDirectory.existsSync()) {
        await appDirectory.create(recursive: true);
      }
      return appDirectory;
    } catch (e) {
      return null;
    }
  }

  static Future<File> getImageFile(String id,
      {required EntityType type}) async {
    final Directory? images = await getAppDirectory("/images");
    if (images == null) {
      switch (type) {
        case EntityType.artist:
          return File("assets/artist_placeholder.jpg");
        case EntityType.release:
          return File("assets/release_placeholder.jpg");
      }
    }

    final File imageFile = File('${images.path}/$id.jpg');
    if (await imageFile.exists()) {
      return imageFile;
    } else {
      switch (type) {
        case EntityType.artist:
          return File("assets/artist_placeholder.jpg");
        case EntityType.release:
          return File("assets/release_placeholder.jpg");
      }
    }
  }

  static Future<Playlist> getNewSongsForPlaylist(Playlist playlist) async {
    GeminiApi api = GeminiApi();
    String prompt = playlist.toPrompt();
    List<Release> releases = await api.getReleases(prompt);

    playlist.releases.clear();
    playlist.releases.addAll(releases);

    setPlaylist(playlist);

    return playlist;
  }

  static Future<T> newEntity<T extends Entity>(T entity) async {
    GeminiApi api = GeminiApi();
    entity = await api.describeEntity(entity);

    switch (entity) {
      case Artist():
        _savedArtists.add(entity);
      case Release():
        _savedReleases.add(entity);
    }
    return entity;
  }
}

String getPrettyJSONString(jsonObject) {
  const JsonEncoder encoder = JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp());

  await Vivacissimo.getNewSongsForPlaylist(aPlaylist);
}
