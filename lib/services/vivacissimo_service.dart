import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../dummy_data/data.dart';
import '../models/models.dart';

class VivacissimoService {
  static Future<File?> getEntityFile() async {
    try {
      print(Platform.operatingSystem);
    } on UnsupportedError {
      return null;
    }
    Directory directory = await getApplicationDocumentsDirectory();
    if (directory.existsSync()) {
      await directory.create(recursive: true);
    }
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
