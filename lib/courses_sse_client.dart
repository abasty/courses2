import 'src/courses_sse_client_stub.dart'
    if (dart.library.io) 'src/courses_sse_client_io.dart'
    if (dart.library.html) 'src/courses_sse_client_html.dart';

abstract class SseClient {
  Future<void> get onConnected;
  //static late SseClient _instance;

  static SseClient getInstance(String serverUrl) {
    return getSseClient(serverUrl);
  }
}
