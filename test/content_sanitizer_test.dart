import 'package:test/test.dart';
import 'package:dopo/src/parser/content_sanitizer.dart';

void main() {
  group('ContentSanitizer', () {
    group('sanitize', () {
      test('removes comment lines', () {
        final content = '''
          # This is a comment
          GET https://api.example.com
        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result, isNot(contains('#')));
        expect(result, contains('GET https://api.example.com'));
      });

      test('removes empty lines', () {
        final content = '''
          GET https://api.example.com


          -h Content-Type=json
        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result.split('\n').length, 2);
        expect(result, contains('GET https://api.example.com'));
        expect(result, contains('-h Content-Type=json'));
      });

      test('normalizes multiple spaces to single space', () {
        final content = 'GET    https://api.example.com';

        final result = ContentSanitizer.sanitize(content);

        expect(result, 'GET https://api.example.com');
      });

      test('trims leading and trailing whitespace', () {
        final content = '  GET https://api.example.com  ';

        final result = ContentSanitizer.sanitize(content);

        expect(result, 'GET https://api.example.com');
      });

      test('handles mixed content with comments, blanks, and whitespace', () {
        final content = '''
          # Comment 1
          GET    https://api.example.com

          # Comment 2
          -h   Content-Type=application/json

        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result, isNot(contains('#')));
        expect(result.split('\n').length, 2);
        expect(result, contains('GET https://api.example.com'));
        expect(result, contains('-h Content-Type=application/json'));
      });

      test('returns empty string for content with only comments', () {
        final content = '''
          # Comment 1
          # Comment 2
        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result, isEmpty);
      });

      test('returns empty string for empty content', () {
        final content = '';

        final result = ContentSanitizer.sanitize(content);

        expect(result, isEmpty);
      });

      test('returns empty string for content with only whitespace', () {
        final content = '''



        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result, isEmpty);
      });

      test('preserves content in body delimiters', () {
        final content = '''
          POST https://api.example.com
          <|
          { "name": "test" }
          |>
        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result, contains('<|'));
        expect(result, contains('|>'));
        expect(result, contains('{ "name": "test" }'));
      });

      test('removes comments inside body block', () {
        final content = '''
          <|
          # This comment should be removed
          { "name": "test" }
          |>
        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result, isNot(contains('#')));
      });

      test('handles inline comments (line starting with # after content)', () {
        final content = '''
          GET https://api.example.com
          -h Content-Type=json # this is a comment
        ''';

        final result = ContentSanitizer.sanitize(content);

        expect(result, contains('# this is a comment'));
      });
    });

    group('sanitizeToLines', () {
      test('returns list of sanitized lines', () {
        final content = '''
          # Comment
          GET https://api.example.com
          -h Content-Type=json
        ''';

        final result = ContentSanitizer.sanitizeToLines(content);

        expect(result, ['GET https://api.example.com', '-h Content-Type=json']);
      });

      test('returns empty list for empty content', () {
        final content = '';

        final result = ContentSanitizer.sanitizeToLines(content);

        expect(result, isEmpty);
      });

      test('returns empty list for content with only comments', () {
        final content = '''
          # Comment 1
          # Comment 2
        ''';

        final result = ContentSanitizer.sanitizeToLines(content);

        expect(result, isEmpty);
      });

      test('normalizes whitespace in each line', () {
        final content = '''
          GET    https://api.example.com
          -h   Content-Type=json
        ''';

        final result = ContentSanitizer.sanitizeToLines(content);

        expect(result, ['GET https://api.example.com', '-h Content-Type=json']);
      });
    });
  });
}
