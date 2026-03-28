class ParseException implements Exception {
  final String message;

  const ParseException(this.message);

  @override
  String toString() => message;
}

typedef RawBlock = ({List<String> directives, String? body});

class BlockExtractor {
  static const _commentPrefix = '#';
  static const _bodyOpen = '<|';
  static const _bodyClose = '|>';

  RawBlock extract(String rawContent) {
    final lines = rawContent
        .split("\n")
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith(_commentPrefix))
        .map((l) => l.replaceAll(RegExp(r'\s+'), ' '))
        .toList();

    final openIdx = lines.indexOf(_bodyOpen);
    final closeIdx = lines.indexOf(_bodyClose);

    _validateDelimiters(lines, openIdx, closeIdx);

    if (openIdx == -1) {
      return (directives: lines, body: null);
    }

    final directives = [
      ...lines.sublist(0, openIdx),
      if (closeIdx + 1 < lines.length) ...lines.sublist(closeIdx + 1),
    ];

    final bodyLines = lines.sublist(openIdx + 1, closeIdx);
    final body = bodyLines.join('\n');
    return (directives: directives, body: body.isEmpty ? null : body);
  }

  void _validateDelimiters(List<String> lines, int openIdx, int closeIdx) {
    final openCount = lines.where((l) => l == _bodyOpen).length;
    final closeCount = lines.where((l) => l == _bodyClose).length;

    if (openCount > 1) {
      throw ParseException(
        '<| appears $openCount times — only one body block is allowed',
      );
    }
    if (closeCount > 1) {
      throw ParseException(
        '|> appears $closeCount times — only one body block is allowed',
      );
    }
    if (openIdx != -1 && closeIdx == -1) {
      throw ParseException('<| opened but never closed with |>');
    }
    if (closeIdx != -1 && openIdx == -1) {
      throw ParseException('|> found with no opening <|');
    }
    if (openIdx != -1 && closeIdx < openIdx) {
      throw ParseException('|> appears before <|');
    }
    if (openIdx != -1 && closeIdx == openIdx + 1) {
      throw ParseException('body block is empty - remove <| |> or add content');
    }
  }
}
