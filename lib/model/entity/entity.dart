import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Entity {
  final String? id;
  final String? mbid;

  Entity({this.id, this.mbid});
}
