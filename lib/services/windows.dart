import 'dart:io';

Future<Directory> getAppDirectory() async {
  if (Platform.isWindows) {
    final directory = Directory(
      '${Platform.environment['USERPROFILE']}\\Documents\\Vivacissimo',
    );
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }
  throw Exception();
}
