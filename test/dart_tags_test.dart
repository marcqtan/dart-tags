@TestOn('vm')
import 'dart:io';

import 'package:dart_tags/dart_tags.dart';
import 'package:dart_tags/src/frames/id3v2/id3v2_frame.dart';
import 'package:dart_tags/src/readers/id3v1.dart';
import 'package:dart_tags/src/readers/id3v2.dart';
import 'package:dart_tags/src/writers/id3v1.dart';
import 'package:dart_tags/src/writers/id3v2.dart';
import 'package:test/test.dart';

void main() {
  File file1;
  File file2;

  setUp(() {
    file1 = File('test/test_assets/id3v1.mp3');
    file2 = File('test/test_assets/id3v24.mp3');
  });

  group('Sandbox tests', () {
    test('sandbox', () {
      // final lupa = ID3V2Frame.frameSizeInBytes(200);
      // print(lupa);
      // final pupa = ID3V2Frame.sizeOf(lupa);
      // print(pupa);
    });
  });

  group('Writer Tests', () {
    test('generate tag block v2.4', () async {
      final tag = Tag()
        ..tags = {
          'title': 'foo',
          'artist': 'bar',
          'album': 'baz',
          'year': '2010',
          'comment': 'lol it is a comment',
          'track': '6',
          'genre': 'Dream',
          'custom': 'Just a tag',
          'picture': AttachedPicture()
            ..imageData = [
              0x00,
              0x01,
              0x02,
              0x03,
              0x00,
              0x01,
              0x02,
              0x03,
              0x00,
              0x01,
              0x02,
              0x03,
              0x00,
              0x01,
              0x02,
              0x03
            ]
            ..imageTypeCode = 0x03
            ..mime = 'image/jpeg'
            ..description = 'foo.jpg'
        }
        ..type = 'ID3'
        ..version = '2.4';

      final writer = ID3V2Writer();

      final blocks = writer.write(await file1.readAsBytes(), tag);

      final r = ID3V2Reader();
      final f = await r.read(blocks);

      expect(f.tags, equals(tag.tags));
    });

    test('generate tag block v1.1', () async {
      final tag = Tag()
        ..tags = {
          'title': 'foo',
          'artist': 'bar',
          'album': 'baz',
          'year': '2010',
          'comment': 'lol it is a comment',
          'track': '6',
          'genre': 'Dream'
        }
        ..type = 'ID3'
        ..version = '1.1';

      final writer = ID3V1Writer();

      final blocks = writer.write(await file1.readAsBytes(), tag);

      final r = ID3V1Reader();
      final f = await r.read(blocks);

      expect(f, equals(tag));
    });

    test('put blocks', () async {
      final tag1 = Tag()
        ..tags = {
          'title': 'foo',
          'artist': 'bar',
          'album': 'baz',
          'year': '2010',
          'comment': 'lol it is a comment',
          'track': '6',
          'genre': 'Dream'
        }
        ..type = 'ID3'
        ..version = '1.1';

      final tag2 = Tag()
        ..tags = {
          'title': 'foo',
          'artist': 'bar',
          'album': 'baz',
          'year': '2010',
          'comment': 'lol it is a comment',
          'track': '6',
          'genre': 'Dream',
          'Custom': 'Just tag'
        }
        ..type = 'ID3'
        ..version = '2.4';

      final _av = () async =>
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

      final foo = await TagProcessor().putTagsToByteArray(_av(), [tag1, tag2]);

      final _fr = () async => foo;

      final rdr1 = ID3V1Reader();
      final t1 = await rdr1.read(_fr());
      expect(t1.tags, equals(tag1.tags));

      final rdr2 = ID3V2Reader();
      final t2 = await rdr2.read(_fr());
      expect(t2.tags, equals(tag2.tags));
    });
  });

  group('Reader Tests', () {
    test('Test with file 1.1', () async {
      final foo = await TagProcessor()
          .getTagsFromByteArray(file1.readAsBytes(), [TagType.id3v1]);

      expect(foo.length, equals(1));

      expect(foo[0].type, equals('ID3'));
      expect(foo[0].version, equals('1.1'));
    });

    test('Test with file 2.4', () async {
      final foo = await TagProcessor()
          .getTagsFromByteArray(file2.readAsBytes(), [TagType.id3v2]);

      expect(foo.length, equals(1));

      expect(foo[0].type, equals('ID3'));
      expect(foo[0].version, equals('2.4.0'));
    });

    test('Test on Failure', () async {
      expect(
          () async => await TagProcessor().getTagsFromByteArray(null),
          throwsA(predicate<Exception>((e) =>
              e is ParsingException &&
              e.cause == ParsingException.byteArrayNull)));
      expect(
          () async => await TagProcessor().getTagsFromByteData(null),
          throwsA(predicate<Exception>((e) =>
              e is ParsingException &&
              e.cause == ParsingException.byteDataNull)));
    });
  });
}
