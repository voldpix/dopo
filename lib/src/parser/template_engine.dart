class TemplateException implements Exception {
  final String message;
  TemplateException(this.message);

  @override
  String toString() => message;
}

class TemplateEngine {
  static String process(String rawContent, Map<String, String> env) {
    final regex = RegExp(r'\{\{s*([A-Za-z0-9_]+)\s*\}\}');

    return rawContent.replaceAllMapped(regex, (match) {
      final variableName = match.group(1);

      if (!env.containsKey(variableName)) {
        throw TemplateException('Missing environment variable: "$variableName"');
      }

      return env[variableName]!;
    });
  }
}