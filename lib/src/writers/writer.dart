import 'dart:async';

import 'package:dart_tags/src/model/tag.dart';

/// Writer could just transform only tags in byte array
abstract class Writer {
  final String _type;
  final String _version;

  Writer(this._type, this._version);

  Future<List<int>> write(List<int> source, Tag tag) async {
    return combine(await removeExistingTag(source), await prepareTag(tag));
  }

  String get version => _version;
  String get type => _type;

  List<int> combine(List<int> source, List<int> tags);

  Future<List<int>> prepareTag(Tag tag);
  Future<List<int>> removeExistingTag(List<int> bytes);
}
