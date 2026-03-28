import '../models/models.dart';

class ConsoleFormatter {
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _cyan = '\x1B[36m';
  static const _gray = '\x1B[90m';

  static void error(String message) {
    print('$_red$_bold✗ $message$_reset');
  }

  static void parseErrors(String fileName, List<ParseError> errors) {
    print('\n$_bold$_red── Failed to parse: $fileName ──$_reset\n');
    for (final error in errors) {
      print('  $_red✗$_reset Near: "${error.line}"');
      print('    $_gray↳ Hint: ${error.hint}$_reset\n');
    }
  }

  static void requestLine(RequestBlock req, {bool verbose = false}) {
    final methodColor = _getMethodColor(req.method);
    print('\n$_gray→$_reset $methodColor$_bold${req.method.name.toUpperCase()}$_reset $_cyan${req.url}$_reset');

    if (verbose) {
      if (req.headers.isNotEmpty) {
        print('\n  $_gray${_bold}Request Headers:$_reset');
        for (final h in req.headers) {
          print('    $_gray• ${h.key}: ${h.value}$_reset');
        }
      }
      if (req.queryParams.isNotEmpty) {
        print('\n  $_gray${_bold}Query Parameters:$_reset');
        for (final q in req.queryParams) {
          print('    $_gray• ${q.name}: ${q.value}$_reset');
        }
      }
      print('');
    }
  }

  static void response(HttpResponse res, {bool verbose = false}) {
    final statusColor = res.statusCode >= 200 && res.statusCode < 300 ? _green : _red;

    print('$statusColor$_bold${res.statusCode}$_reset  $_gray${res.duration.inMilliseconds}ms$_reset\n');

    if (verbose && res.headers.isNotEmpty) {
      print('  $_gray${_bold}Response Headers:$_reset');
      for (final entry in res.headers.entries) {
        print('    $_gray• ${entry.key}: ${entry.value}$_reset');
      }
      print('');
    }

    if (res.body.isNotEmpty) {
      print(res.body);
      print('');
    }
  }

  static String _getMethodColor(HttpMethod method) {
    return switch (method) {
      HttpMethod.get => _cyan,
      HttpMethod.post => _green,
      HttpMethod.put => _yellow,
      HttpMethod.patch => _blue,
      HttpMethod.delete => _red,
    };
  }
}
