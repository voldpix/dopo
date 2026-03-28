import 'package:dopo/src/models/models.dart';
import 'package:dopo/src/parser/content_sanitizer.dart';
import 'package:dopo/src/parser/dsl_parser.dart';
import 'package:dopo/src/parser/template_engine.dart';

class ContentProcessorException implements Exception {
  final String message;
  final String? type;

  const ContentProcessorException(this.message, {this.type});

  @override
  String toString() => type != null ? '[$type] $message' : message;
}

class ContentProcessorResult {
  final RequestBlock? request;
  final List<ParseError> errors;
  final String? errorMessage;
  final String? errorType;

  const ContentProcessorResult._({
    this.request,
    this.errors = const [],
    this.errorMessage,
    this.errorType,
  });

  factory ContentProcessorResult.success(RequestBlock request) {
    return ContentProcessorResult._(request: request);
  }

  factory ContentProcessorResult.templateError(String message) {
    return ContentProcessorResult._(errorMessage: message, errorType: 'Template');
  }

  factory ContentProcessorResult.parseErrors(List<ParseError> errors) {
    return ContentProcessorResult._(errors: errors);
  }

  bool get hasErrors => errorMessage != null || errors.isNotEmpty;
  bool get isSuccess => request != null && !hasErrors;
  bool get isError => !isSuccess;
}

class ContentProcessor {
  final DslParser _parser = DslParser();

  ContentProcessorResult process(String rawContent, Map<String, String> env) {
    final sanitizedContent = ContentSanitizer.sanitize(rawContent);

    String hydratedContent;
    try {
      hydratedContent = TemplateEngine.process(sanitizedContent, env);
    } on TemplateException catch (e) {
      return ContentProcessorResult.templateError(e.message);
    }

    final parseResult = _parser.parse(hydratedContent);

    if (parseResult.hasErrors) {
      return ContentProcessorResult.parseErrors(parseResult.errors);
    }

    return ContentProcessorResult.success(parseResult.request!);
  }
}
