import 'package:vivacissimo/models/entity.dart';

class Api {
  static const Api _instance = Api();

  const Api();

  Api getInstance() => _instance;

  Future<Entity> search() async {
    throw UnimplementedError();
  }
}
