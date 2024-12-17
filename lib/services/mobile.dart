import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<Directory> getAppDirectory() async {
  return await getApplicationDocumentsDirectory();
}
