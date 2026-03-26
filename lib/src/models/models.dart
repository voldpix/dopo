enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  static HttpMethod? tryParse(String method) {
    final upper = method.toUpperCase();
    for (final value in HttpMethod.values) {
      if (value.name.toUpperCase() == upper) return value;
    }

    return null;
  }
}

class Header {
  final String key;
  final String value;

  const Header(this.key, this.value);

  @override
  String toString() => '$key: $value';
}

class QueryParam {
  final String name;
  final String value;

  const QueryParam(this.name, this.value);

  @override
  String toString() => '$name=$value';
}

class RequestBlock {
  final HttpMethod method;
  final String url;
  final List<Header> headers;
  final List<QueryParam> queryParams;
  final String? body;

  const RequestBlock({
    required this.method,
    required this.url,
    this.headers = const [],
    this.queryParams = const [],
    this.body,
  });

  bool get hasBody => body != null && body!.trim().isNotEmpty;
}

typedef ParseError = ({String line, String hint});

typedef ParseResult = ({RequestBlock? request, List<ParseError> errors});

extension ParseResultX on ParseResult {
  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => errors.isEmpty && request != null;
}
