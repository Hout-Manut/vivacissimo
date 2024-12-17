import 'dart:convert';

import 'windows.dart' if (dart.library.ui) 'mobile.dart';

import 'dart:io';
import '../dummy_data/data.dart';
import '../models/models.dart';

class Vivacissimo {
  static Future<File?> getEntityFile() async {
    try {
      Platform.operatingSystem;
    } on UnsupportedError {
      return null;
    }
      Directory directory;
      if (Platform.isWindows) {
        directory = await getAppDirectory();
        return File("${directory.path}\\data.json");
      }
      directory = await getAppDirectory();
      return File("${directory.path}/data.json");
  }

  static Future<void> saveEntitiesToFile(Iterable<Entity> entities) async {
    final File? file = await getEntityFile();
    if (file == null) return;

    Map<String, List<Map<String, dynamic>>> data = {
      'artist': [],
      'release': [],
    };

    for (Entity entity in entities) {
      switch (entity) {
        case Artist():
          data['artist']!.add(entity.toJson());
        case Release():
          data['release']!.add(entity.toJson());
      }
    }
    // await file.writeAsString(getPrettyJSONString(data));
  }
}

String getPrettyJSONString(jsonObject) {
  const JsonEncoder encoder = JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}

void test() {
  Vivacissimo.saveEntitiesToFile([
    badApple,
    alterEgo,
    zun,
    yutaImai,
    qlarabelle,
  ]);
}
