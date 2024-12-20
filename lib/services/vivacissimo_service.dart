import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../dummy_data/data.dart';
import '../models/models.dart';

class VivacissimoService {


  static Future<Directory?> getAppDirectory() async {
    try {
      Platform.operatingSystem;
    } on UnsupportedError {
      return null;
    }

    try {
      Directory baseDirectory = await getApplicationDocumentsDirectory();
      Directory appDirectory = Directory('${baseDirectory.path}/vivacissimo');

      if (!appDirectory.existsSync()) {
        await appDirectory.create(recursive: true);
      }
      return appDirectory;
    } catch (e) {
      return null;
    }
  }


  static Future<File?> getEntityFile() async {
    Directory? directory = await getAppDirectory();
    if (directory == null) return null;
    return File('${directory.path}/structure.json');
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
    await file.writeAsString(getPrettyJSONString(data));
  }
}

String getPrettyJSONString(jsonObject) {
  const JsonEncoder encoder = JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}

void test() {
  VivacissimoService.saveEntitiesToFile([
    badApple,
    alterEgo,
    zun,
    yutaImai,
    qlarabelle,
  ]);
}
