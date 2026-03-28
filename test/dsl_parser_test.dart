import 'package:test/test.dart';
import 'package:dopo/dopo.dart';

void main() {
  group('DslParser', () {
    late DslParser parser;

    setUp(() {
      parser = DslParser();
    });

    group('parse', () {
      test('parses complete valid request', () {
        final content = '''
          POST https://api.example.com/users
          -h Authorization=Bearer token
          -q page=1
          <|
          {"name": "voldpix"}
          |>
        ''';

        final result = parser.parse(content);

        expect(result.hasErrors, isFalse);
        expect(result.request, isNotNull);

        final req = result.request!;

        expect(req.method, HttpMethod.post);
        expect(req.url, 'https://api.example.com/users');

        expect(req.headers.length, 1);
        expect(req.headers.first.key, 'Authorization');
        expect(req.headers.first.value, 'Bearer token');

        expect(req.queryParams.length, 1);
        expect(req.queryParams.first.name, 'page');
        expect(req.queryParams.first.value, '1');

        expect(req.hasBody, isTrue);
        expect(req.body, '{"name": "voldpix"}');
      });

      test('parses GET request without body', () {
        final content = '''
          GET https://api.example.com/users
          -h Accept=application/json
          -q limit=10
        ''';

        final result = parser.parse(content);

        expect(result.hasErrors, isFalse);
        expect(result.request, isNotNull);

        final req = result.request!;
        expect(req.method, HttpMethod.get);
        expect(req.hasBody, isFalse);
        expect(req.body, isNull);
      });

      test('parses headers with header prefix', () {
        final content = '''
          GET https://api.example.com
          header Content-Type=application/json
        ''';

        final result = parser.parse(content);

        expect(result.hasErrors, isFalse);
        expect(result.request!.headers.length, 1);
        expect(result.request!.headers.first.key, 'Content-Type');
      });

      test('parses query params with query prefix', () {
        final content = '''
          GET https://api.example.com
          query page=1
        ''';

        final result = parser.parse(content);

        expect(result.hasErrors, isFalse);
        expect(result.request!.queryParams.length, 1);
        expect(result.request!.queryParams.first.name, 'page');
      });

      test('parses query param without value', () {
        final content = '''
          GET https://api.example.com
          -q flag
        ''';

        final result = parser.parse(content);

        expect(result.hasErrors, isFalse);
        expect(result.request!.queryParams.length, 1);
        expect(result.request!.queryParams.first.name, 'flag');
        expect(result.request!.queryParams.first.value, '');
      });

      test('accumulates errors for invalid lines', () {
        final content = '''
          FETCH api.example.com
          -h InvalidHeaderNoEquals
          -q
        ''';

        final result = parser.parse(content);

        expect(result.request, isNull);
        expect(result.hasErrors, isTrue);
        expect(result.errors.length, 3);
      });

      test('returns error for empty file', () {
        final content = '';

        final result = parser.parse(content);

        expect(result.request, isNull);
        expect(result.hasErrors, isTrue);
        expect(result.errors.first.hint, 'file must contain a request');
      });

      test('returns error for file with only comments', () {
        final content = '''
          # This is a comment
          # Another comment
        ''';

        final result = parser.parse(content);

        expect(result.request, isNull);
        expect(result.hasErrors, isTrue);
        expect(result.errors.first.hint, 'file must contain a request');
      });

      test('returns error for invalid HTTP method', () {
        final content = 'INVALID https://api.example.com';

        final result = parser.parse(content);

        expect(result.request, isNull);
        expect(result.hasErrors, isTrue);
        expect(result.errors.first.hint, contains('http method'));
      });

      test('returns error for invalid URL', () {
        final content = 'GET not-a-url';

        final result = parser.parse(content);

        expect(result.request, isNull);
        expect(result.hasErrors, isTrue);
        expect(result.errors.first.hint, contains('URL'));
      });

      test('returns error for URL without scheme', () {
        final content = 'GET api.example.com';

        final result = parser.parse(content);

        expect(result.request, isNull);
        expect(result.hasErrors, isTrue);
        expect(result.errors.first.hint, contains('http:// or https://'));
      });

      test('returns error for unrecognized directive', () {
        final content = '''
          GET https://api.example.com
          -x Invalid-Directive
        ''';

        final result = parser.parse(content);

        expect(result.hasErrors, isTrue);
        expect(result.errors.first.hint, 'unrecognized directive');
      });

      test('parses request with multiple headers and query params', () {
        final content = '''
          POST https://api.example.com/users
          -h Content-Type=application/json
          -h Authorization=Bearer token
          -h Accept=application/json
          -q page=1
          -q limit=10
          -q sort=name
          <|
          {"name": "test"}
          |>
        ''';

        final result = parser.parse(content);

        expect(result.hasErrors, isFalse);
        expect(result.request!.headers.length, 3);
        expect(result.request!.queryParams.length, 3);
      });
    });
  });
}
