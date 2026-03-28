import 'package:http/http.dart' as http;

import '../constants.dart';

class UserAgentClient extends http.BaseClient {
  final http.Client _inner;
  final String _userAgent;

  UserAgentClient(this._inner) : _userAgent = '($appName)CLI/$appVersion';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] ??= _userAgent;
    request.headers['user-agent'] ??= _userAgent;

    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}
