import 'package:dopo/src/runner/user_agent_client.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class HttpRunner {
  final http.Client _client = UserAgentClient(http.Client());

  Future<HttpResponse> run(RequestBlock request) async {
    final uri = _buildUri(request);
    final headers = _buildHeaders(request);

    final stopwatch = Stopwatch()..start();

    http.Response response;
    try {
      response = await switch (request.method) {
        HttpMethod.get => _client.get(uri, headers: headers),
        HttpMethod.post => _client.post(
          uri,
          headers: headers,
          body: request.body,
        ),
        HttpMethod.put => _client.put(
          uri,
          headers: headers,
          body: request.body,
        ),
        HttpMethod.patch => _client.patch(
          uri,
          headers: headers,
          body: request.body,
        ),
        HttpMethod.delete => _client.delete(
          uri,
          headers: headers,
          body: request.body,
        ),
      };
    } finally {
      stopwatch.stop();
    }

    return (
      statusCode: response.statusCode,
      headers: response.headers,
      body: response.body,
      duration: stopwatch.elapsed,
    );
  }

  void close() {
    _client.close();
  }

  Uri _buildUri(RequestBlock request) {
    final baseUri = Uri.parse(request.url);
    if (request.queryParams.isEmpty) return baseUri;
    final mergedParams = <String, String>{...baseUri.queryParameters};

    for (final q in request.queryParams) {
      mergedParams[q.name] = q.value;
    }

    return baseUri.replace(queryParameters: mergedParams);
  }

  Map<String, String> _buildHeaders(RequestBlock request) {
    final map = <String, String>{};
    for (final h in request.headers) {
      map[h.key] = h.value;
    }
    return map;
  }
}
