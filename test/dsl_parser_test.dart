import 'package:test/test.dart';
import 'package:dopo/dopo.dart';

void main() {
  group('DslParser', () {
    late DslParser parser;

    setUp(() {
      parser = DslParser();
    });

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
  });
}