import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vivacissimo/services/api/gemini_api.dart';
import 'package:vivacissimo/services/api/musicbrainz_api.dart';
import '../models/models.dart';

void printDebug(Object object) {
  if (kDebugMode) debugPrint(object.toString());
}

class Vivacissimo {
  static const String _releaseFilename = "releases.json";
  static final Set<Release> _savedReleases = {};
  static Set<Release> get releases => _savedReleases;

  static const String _artistFilename = "artists.json";
  static final Set<Artist> _savedArtists = {};
  static Set<Artist> get artists => _savedArtists;

  static const String _playlistFilename = "playlists.json";
  static final Set<Playlist> _savedPlaylists = {};
  static Set<Playlist> get playlists => _savedPlaylists;

  static const String _tagFilename = "tags.json";
  static final Set<Tag> _savedTags = {};
  static Set<Tag> get tags => _savedTags;

  static bool loaded = false;
  static Future<void>? _loadingFuture;

  static const JsonEncoder encoder = JsonEncoder.withIndent("  ");

  static void addPlaylist(Playlist newPlaylist) {
    _savedPlaylists.add(newPlaylist);
    _savedReleases.addAll(newPlaylist.releases);
    for (Release release in newPlaylist.releases) {
      _savedTags.addAll(release.tags);
    }
    saveData();
  }

  static void newArtistsFromCredit(ArtistCredit credit) async {
    for (ArtistCreditPart artist in credit.parts) {
      printDebug("Adding artist: ${artist.artist.name}");
      printDebug("id: ${artist.artist.id}");
      String newId = artist.artist.id;
      if (_savedArtists.where((artist) => artist.id == newId).isEmpty) {
        Artist? newArtist = await MusicbrainzApi.searchArtistById(newId);
        if (newArtist == null) continue;
        _savedArtists.add(newArtist);
      }
    }
    saveData();
  }

  static Future<void> saveImage(PlatformFile file, String fileName) async {
    Directory? appDirectory = await getAppDirectory("/images");
    if (appDirectory == null) return;

    File image = File(file.path!);

    String newPath = '${appDirectory.path}/$fileName';
    try {
      await image.copy(newPath);
      printDebug('Image saved to $newPath');
    } catch (e) {
      printDebug('Error saving image: $e');
    }
  }

  static Future<void> askForPermission() async {
    PermissionStatus status = await Permission.photos.status;
    if (status.isDenied) {
      debugPrint("storage permission ===$status");

      await Permission.photos.request();
      // await Permission.storage.request();
      // await Permission.storage.request();
      // await Permission.storage.request();
    } else {
      debugPrint("permission storage $status");
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
    if (_loadingFuture != null) {
      return _loadingFuture;
    }
    if (loaded) return;

    _loadingFuture = _loadDataInternal();
    await _loadingFuture;

    _loadingFuture = null;
  }

  static Future<void> _loadDataInternal() async {
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
    printDebug("Data was loaded");
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
    printDebug("Data saved");
  }

  static Future<void> deleteFile(String path) async {
    File file = File(path);
    if (await file.exists()) {
      try {
        await file.delete(recursive: true);
        printDebug('Deleted file: $path');
      } catch (e) {
        printDebug('Error deleting file $path: $e');
      }
    } else {
      printDebug('File $path does not exist.');
    }
  }

  static void deleteData() async {
    Directory? data = await getAppDirectory();
    if (data == null) return;
    try {
      if (await data.exists()) {
        for (FileSystemEntity entity in data.listSync()) {
          try {
            await entity.delete(recursive: true);
            printDebug('Deleted: ${entity.path}');
          } catch (e) {
            printDebug('Failed to delete ${entity.path}: $e');
          }
        }
        printDebug('All data in directory deleted successfully.');
      } else {
        printDebug('Directory does not exist.');
      }
    } catch (e) {
      printDebug('Error while deleting data: $e');
    }
  }

  static void deleteImage(String filename) async {
    Directory? data = await getAppDirectory("/images");
    if (data == null) return;

    await deleteFile('${data.path}/$filename');
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

  static Future<File> getImageFile(
    String imageName, {
    EntityType? type,
  }) async {
    final Directory? images = await getAppDirectory("/images");
    if (images == null) {
      switch (type) {
        case EntityType.artist:
          return File("assets/artist_placeholder.jpg");
        case EntityType.release:
        case null:
          return File("assets/release_placeholder.jpg");
      }
    }

    final File imageFile = File('${images.path}/$imageName');
    if (await imageFile.exists()) {
      return imageFile;
    } else {
      switch (type) {
        case EntityType.artist:
          return File("assets/artist_placeholder.jpg");
        case EntityType.release:
          return File("assets/release_placeholder.jpg");
        case null:
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

    addPlaylist(playlist);

    return playlist;
  }

  static Future<T> newEntity<T extends Entity>(T entity) async {
    GeminiApi api = GeminiApi();
    printDebug("New entity pending add: $entity");
    entity = await api.describeEntity(entity);

    switch (entity) {
      case Artist():
        if (!_savedArtists.contains(entity)) {
          _savedArtists.add(entity);
        }
      case Release():
          newArtistsFromCredit(entity.credit);
        if (!_savedReleases.contains(entity)) {
          _savedReleases.add(entity);
        }
    }

    _savedTags.addAll(entity.tags);
    printDebug("New entity added: $entity");
    saveData();
    return entity;
  }
}
