import 'package:test/test.dart';
import 'package:dopo/src/parser/block_extractor.dart';

void main() {
  group('BlockExtractor', () {
    late BlockExtractor extractor;

    setUp(() {
      extractor = BlockExtractor();
    });

    test('extracts directives and body', () {
      final content = '''
        POST https://api.example.com
        -h Content-Type=json
        <|
        { "name": "alice" }
        |>
      ''';

      final result = extractor.extract(content);
      expect(result.directives, [
        'POST https://api.example.com',
        '-h Content-Type=json',
      ]);
      expect(result.body, '{ "name": "alice" }');
    });

    test('strips comments and blank lines', () {
      final content = '''
        # Create a user
        POST https://api.example.com

        -h Content-Type=json
      ''';

      final result = extractor.extract(content);
      expect(result.directives, [
        'POST https://api.example.com',
        '-h Content-Type=json',
      ]);
      expect(result.body, isNull);
    });

    test('throws when open without close', () {
      final content = '''
        POST https://api.example.com
        <|
        { "name": "alice" }
      ''';

      expect(() => extractor.extract(content), throwsA(isA<ParseException>()));
    });
  });
}
