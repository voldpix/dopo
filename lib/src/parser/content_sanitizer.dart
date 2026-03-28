class ContentSanitizer {
  static const _commentPrefix = '#';

  static String sanitize(String rawContent) {
    return _sanitizeLines(rawContent).join('\n');
  }

  static List<String> sanitizeToLines(String rawContent) {
    return _sanitizeLines(rawContent);
  }

  static List<String> _sanitizeLines(String rawContent) {
    return rawContent
        .split('\n')
        .where((line) => !_isCommentOrEmpty(line))
        .map((line) => _normalizeLine(line))
        .toList();
  }

  static bool _isCommentOrEmpty(String line) {
    final trimmed = line.trim();
    return trimmed.isEmpty || trimmed.startsWith(_commentPrefix);
  }

  static String _normalizeLine(String line) {
    return line.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
