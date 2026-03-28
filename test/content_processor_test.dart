import 'package:test/test.dart';
import 'package:dopo/src/parser/content_processor.dart';

void main() {
  group('ContentProcessor', () {
    late ContentProcessor processor;

    setUp(() {
      processor = ContentProcessor();
    });

    group('process', () {
      test('successfully processes valid request without templates', () {
        final content = '''
          GET https://api.example.com/users
          -h Accept=application/json
          -q page=1
        ''';

        final result = processor.process(content, {});

        expect(result.isSuccess, isTrue);
        expect(result.request, isNotNull);
        expect(result.hasErrors, isFalse);
      });

      test('successfully processes request with templates', () {
        final content = '''
          POST https://api.example.com/users
          -h Authorization=Bearer {{TOKEN}}
          -q userId={{USER_ID}}
          <|
          {"name": "{{USERNAME}}"}
          |>
        ''';
        final env = {
          'TOKEN': 'abc123',
          'USER_ID': '42',
          'USERNAME': 'voldpix',
        };

        final result = processor.process(content, env);

        expect(result.isSuccess, isTrue);
        expect(result.request!.headers.first.value, 'Bearer abc123');
        expect(result.request!.queryParams.first.value, '42');
        expect(result.request!.body, contains('voldpix'));
      });

      test('ignores commented lines with templates', () {
        final content = '''
          # -h Authorization=Bearer {{MISSING_TOKEN}}
          GET https://api.example.com
          -q userId={{USER_ID}}
        ''';
        final env = {'USER_ID': '42'};

        final result = processor.process(content, env);

        expect(result.isSuccess, isTrue);
        expect(result.request!.headers.length, 0);
        expect(result.request!.queryParams.first.value, '42');
      });

      test('returns template error for missing variable', () {
        final content = '''
          GET https://api.example.com
          -h Authorization=Bearer {{MISSING_TOKEN}}
        ''';

        final result = processor.process(content, {});

        expect(result.isError, isTrue);
        expect(result.errorType, 'Template');
        expect(result.errorMessage, contains('MISSING_TOKEN'));
      });

      test('returns parse error for invalid request', () {
        final content = '''
          INVALID https://api.example.com
        ''';

        final result = processor.process(content, {});

        expect(result.isError, isTrue);
        expect(result.errorType, isNull);
        expect(result.errors, isNotEmpty);
      });

      test('returns parse error for empty content', () {
        final content = '';

        final result = processor.process(content, {});

        expect(result.isError, isTrue);
        expect(result.errors.first.hint, 'file must contain a request');
      });

      test('returns parse error for content with only comments', () {
        final content = '''
          # This is a comment
          # Another comment
        ''';

        final result = processor.process(content, {});

        expect(result.isError, isTrue);
        expect(result.errors.first.hint, 'file must contain a request');
      });

      test('handles request with body', () {
        final content = '''
          POST https://api.example.com/users
          -h Content-Type=application/json
          <|
          {"name": "alice", "role": "admin"}
          |>
        ''';

        final result = processor.process(content, {});

        expect(result.isSuccess, isTrue);
        expect(result.request!.hasBody, isTrue);
        expect(result.request!.body, contains('alice'));
      });

      test('handles all HTTP methods', () {
        final methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];

        for (final method in methods) {
          final content = '$method https://api.example.com';
          final result = processor.process(content, {});

          expect(result.isSuccess, isTrue, reason: 'Failed for $method');
        }
      });

      test('handles multiple headers and query params', () {
        final content = '''
          GET https://api.example.com
          -h Accept=application/json
          -h Authorization=Bearer token
          -h Content-Type=application/json
          -q page=1
          -q limit=10
          -q sort=name
        ''';

        final result = processor.process(content, {});

        expect(result.isSuccess, isTrue);
        expect(result.request!.headers.length, 3);
        expect(result.request!.queryParams.length, 3);
      });

      test('ContentProcessorResult hasErrors is true for template error', () {
        final content = 'GET https://api.example.com?q={{MISSING}}';

        final result = processor.process(content, {});

        expect(result.hasErrors, isTrue);
        expect(result.isError, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('ContentProcessorResult hasErrors is true for parse errors', () {
        final content = 'INVALID url';

        final result = processor.process(content, {});

        expect(result.hasErrors, isTrue);
        expect(result.isError, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('ContentProcessorResult isSuccess is true for valid request', () {
        final content = 'GET https://api.example.com';

        final result = processor.process(content, {});

        expect(result.isSuccess, isTrue);
        expect(result.hasErrors, isFalse);
        expect(result.isError, isFalse);
      });
    });
  });
}
