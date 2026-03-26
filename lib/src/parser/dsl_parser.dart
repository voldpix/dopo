import 'package:dopo/src/models/models.dart';
import 'package:dopo/src/parser/block_extractor.dart';

class DslParser {
  final BlockExtractor _extractor = BlockExtractor();

  ParseResult parse(String rawContent) {
    final List<ParseError> errors = [];

    RawBlock blocks;
    try {
      blocks = _extractor.extract(rawContent);
    } on ParseException catch (e) {
      errors.add((line: '<| ... |>', hint: e.message));
      return (request: null, errors: errors);
    }

    final directives = blocks.directives;
    if (directives.isEmpty) {
      errors.add((line: 'empty file', hint: 'file must contain a request'));
      return (request: null, errors: errors);
    }

    final firstLine = directives.first;
    final requestParts = _parseRequestLine(firstLine, errors);

    final headers = <Header>[];
    final queryParams = <QueryParam>[];

    for (final line in directives.skip(1)) {
      if (line.startsWith('-h ') || line.startsWith('header ')) {
        _parseHeader(line, headers, errors);
      } else if (line.startsWith('-q ') || line.startsWith('query ')) {
        _parseQuery(line, queryParams, errors);
      } else {
        errors.add((line: line, hint: 'unrecognized directive'));
      }
    }

    final request = errors.isEmpty && requestParts != null
        ? RequestBlock(
            method: requestParts.method,
            url: requestParts.url,
            headers: headers,
            queryParams: queryParams,
            body: blocks.body,
          )
        : null;
    return (request: request, errors: errors);
  }

  ({HttpMethod method, String url})? _parseRequestLine(
    String line,
    List<ParseError> errors,
  ) {
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      errors.add((
        line: line,
        hint: 'expected: http method and URL e.g. GET https://api.example.com',
      ));
      return null;
    }

    final method = HttpMethod.tryParse(parts[0]);
    if (method == null) {
      errors.add((line: line, hint: 'expected: http method e.g. GET'));
      return null;
    }

    final urlString = parts[1];
    final uri = Uri.tryParse(urlString);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      errors.add((
        line: line,
        hint: 'invalid URL. Ensure it includes http:// or https://',
      ));
      return null;
    }

    return (method: method, url: urlString);
  }

  void _parseHeader(
    String line,
    List<Header> headers,
    List<ParseError> errors,
  ) {
    final stripped = line.replaceFirst(RegExp(r'^(-h|header)\s+'), '').trim();
    final eqIdx = stripped.indexOf('=');

    if (eqIdx == -1 || eqIdx == 0) {
      errors.add((
        line: line,
        hint:
            'expected: -h <key>=<value> e.g. -h Content-Type=application/json',
      ));
      return;
    }

    headers.add(
      Header(
        stripped.substring(0, eqIdx).trim(),
        stripped.substring(eqIdx + 1).trim(),
      ),
    );
  }

  void _parseQuery(
    String line,
    List<QueryParam> queryParams,
    List<ParseError> errors,
  ) {
    final stripped = line.replaceFirst(RegExp(r'^(-q|query)\s+'), '').trim();
    final eqIdx = stripped.indexOf('=');

    if (eqIdx == -1) {
      queryParams.add(QueryParam(stripped, ''));
    } else if (eqIdx == 0) {
      errors.add((
        line: line,
        hint: 'key is missing. expected: -q <key>=<value> e.g. -q page=1',
      ));
    } else {
      queryParams.add(
        QueryParam(
          stripped.substring(0, eqIdx).trim(),
          stripped.substring(eqIdx + 1).trim(),
        ),
      );
    }
  }
}
