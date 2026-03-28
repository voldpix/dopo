import 'package:test/test.dart';
import 'package:dopo/src/parser/template_engine.dart';

void main() {
  group('TemplateEngine', () {
    group('process', () {
      test('replaces single variable', () {
        final content = 'Hello {{NAME}}';
        final env = {'NAME': 'World'};

        final result = TemplateEngine.process(content, env);

        expect(result, 'Hello World');
      });

      test('replaces multiple variables', () {
        final content = '{{METHOD}} {{URL}}';
        final env = {'METHOD': 'GET', 'URL': 'https://api.example.com'};

        final result = TemplateEngine.process(content, env);

        expect(result, 'GET https://api.example.com');
      });

      test('replaces same variable multiple times', () {
        final content = '{{USER}} logged in as {{USER}}';
        final env = {'USER': 'admin'};

        final result = TemplateEngine.process(content, env);

        expect(result, 'admin logged in as admin');
      });

      test('handles variables in JSON body', () {
        final content = '''
          {
            "username": "{{USERNAME}}",
            "role": "{{ROLE}}"
          }
        ''';
        final env = {'USERNAME': 'voldpix', 'ROLE': 'admin'};

        final result = TemplateEngine.process(content, env);

        expect(result, contains('"username": "voldpix"'));
        expect(result, contains('"role": "admin"'));
      });

      test('handles variables with spaces in template syntax', () {
        final content = '{{ NAME }}';
        final env = {'NAME': 'World'};

        final result = TemplateEngine.process(content, env);

        expect(result, 'World');
      });

      test('handles variables with multiple spaces in template syntax', () {
        final content = '{{  NAME  }}';
        final env = {'NAME': 'World'};

        final result = TemplateEngine.process(content, env);

        expect(result, 'World');
      });

      test('leaves content unchanged when no variables', () {
        final content = 'No variables here';
        final env = <String, String>{};

        final result = TemplateEngine.process(content, env);

        expect(result, 'No variables here');
      });

      test('ignores non-matching patterns', () {
        final content = '{{ not_a_var }}}}';
        final env = <String, String>{};

        expect(
          () => TemplateEngine.process(content, env),
          throwsA(isA<TemplateException>()),
        );
      });

      test('throws TemplateException for missing variable', () {
        final content = 'Hello {{MISSING}}';
        final env = {'OTHER': 'value'};

        expect(
          () => TemplateEngine.process(content, env),
          throwsA(isA<TemplateException>()),
        );
      });

      test('TemplateException message includes variable name', () {
        final content = '{{UNDEFINED_VAR}}';
        final env = <String, String>{};

        try {
          TemplateEngine.process(content, env);
          fail('Should have thrown TemplateException');
        } on TemplateException catch (e) {
          expect(e.message, contains('UNDEFINED_VAR'));
        }
      });

      test('throws on first missing variable when multiple are missing', () {
        final content = '{{FIRST}} {{SECOND}}';
        final env = <String, String>{};

        expect(
          () => TemplateEngine.process(content, env),
          throwsA(isA<TemplateException>()),
        );
      });

      test('handles variables in header values', () {
        final content = '-h Authorization=Bearer {{TOKEN}}';
        final env = {'TOKEN': 'abc123'};

        final result = TemplateEngine.process(content, env);

        expect(result, '-h Authorization=Bearer abc123');
      });

      test('handles variables in query parameters', () {
        final content = '-q userId={{USER_ID}}';
        final env = {'USER_ID': '42'};

        final result = TemplateEngine.process(content, env);

        expect(result, '-q userId=42');
      });

      test('handles variables in URL', () {
        final content = 'GET https://api.example.com/users/{{USER_ID}}';
        final env = {'USER_ID': '123'};

        final result = TemplateEngine.process(content, env);

        expect(result, 'GET https://api.example.com/users/123');
      });
    });
  });
}
