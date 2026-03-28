import 'package:test/test.dart';
import 'package:dopo/src/parser/block_extractor.dart';

void main() {
  group('BlockExtractor', () {
    late BlockExtractor extractor;

    setUp(() {
      extractor = BlockExtractor();
    });

    group('extract', () {
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

      test('returns null body when no body block', () {
        final content = '''
          GET https://api.example.com
          -h Authorization=Bearer token
        ''';

        final result = extractor.extract(content);
        expect(result.directives, ['GET https://api.example.com', '-h Authorization=Bearer token']);
        expect(result.body, isNull);
      });

      test('handles body with multiple lines', () {
        final content = '''
          POST https://api.example.com
          <|
          {
            "name": "alice",
            "role": "admin"
          }
          |>
        ''';

        final result = extractor.extract(content);
        expect(result.body, '{\n"name": "alice",\n"role": "admin"\n}');
      });

      test('handles directives after body block', () {
        final content = '''
          POST https://api.example.com
          <|
          {"name": "alice"}
          |>
          -h After-Header=value
        ''';

        final result = extractor.extract(content);
        expect(result.directives, ['POST https://api.example.com', '-h After-Header=value']);
        expect(result.body, '{"name": "alice"}');
      });

      test('normalizes whitespace in directives', () {
        final content = '''
          GET    https://api.example.com
          -h   Content-Type=application/json
        ''';

        final result = extractor.extract(content);
        expect(result.directives, ['GET https://api.example.com', '-h Content-Type=application/json']);
      });

      test('throws when open without close', () {
        final content = '''
          POST https://api.example.com
          <|
          { "name": "alice" }
        ''';

        expect(() => extractor.extract(content), throwsA(isA<ParseException>()));
      });

      test('throws when close without open', () {
        final content = '''
          POST https://api.example.com
          |>
        ''';

        expect(() => extractor.extract(content), throwsA(isA<ParseException>()));
      });

      test('throws when multiple open delimiters', () {
        final content = '''
          POST https://api.example.com
          <|
          <|
          body
          |>
        ''';

        expect(() => extractor.extract(content), throwsA(isA<ParseException>()));
      });

      test('throws when multiple close delimiters', () {
        final content = '''
          POST https://api.example.com
          <|
          body
          |>
          |>
        ''';

        expect(() => extractor.extract(content), throwsA(isA<ParseException>()));
      });

      test('throws when close appears before open', () {
        final content = '''
          POST https://api.example.com
          |>
          <|
          body
        ''';

        expect(() => extractor.extract(content), throwsA(isA<ParseException>()));
      });

      test('throws when body block is empty', () {
        final content = '''
          POST https://api.example.com
          <|
          |>
        ''';

        expect(() => extractor.extract(content), throwsA(isA<ParseException>()));
      });
    });
  });
}
