import 'dart:convert';

import 'package:courses_sse_client/courses_sse_client.dart';
import 'package:http/http.dart' as http;

import 'storage.dart';

class BackendStrategy implements StorageStrategy {
  final _storage = LocalStorageStrategy('courses3.json');
  late SseClient _sse_client;
  Function? pushEvent;

  @override
  bool isConnected = false;

  @override
  String hostname;

  BackendStrategy(this.hostname);

  @override
  Future<Map<String, dynamic>> read() async {
    var map = await fetchData('courses/all');
    if (map != null && map is Map<String, dynamic>) {
      // await _sse_client.onConnected;
      return map;
    }
    isConnected = false;
    return _storage.read();
  }

  @override
  Future<void> write(Map<String, dynamic> map) {
    return _storage.write(map);
  }

  @override
  Future<void> advertise(String path, Map<String, dynamic> map) async {
    try {
      var response = await http.post(
        Uri.http(hostname, path, {'sseClientId': _sse_client.clientId}),
        body: json.encode(map),
      );
      isConnected = response.statusCode == 200;
    } catch (e) {
      disconnect();
    }
  }

  Future<Object?> fetchData(String path) async {
    try {
      var response = await http.get(Uri.http(hostname, path));
      if (response.statusCode == 200) {
        await sseConnect();
        return json.decode(response.body) as Object;
      } else {
        throw 'Fetch error';
      }
    } catch (e) {
      disconnect();
      return null;
    }
  }

  @override
  void disconnect() {
    _sse_client.close();
    isConnected = false;
  }

  @override
  Future sseConnect() async {
    if (isConnected) return;
    _sse_client = SseClient.fromUrl('http://$hostname/sync');
    try {
      await _sse_client.onConnected;
      isConnected = true;
      _sse_client.stream.listen(
        (str) {
          if (str.isEmpty) return;
          var map;
          try {
            map = json.decode(str) as Map<String, dynamic>;
          } catch (e) {
            map = {};
          }
          if (pushEvent != null) pushEvent!(map);
        },
        onDone: () {
          if (pushEvent != null) pushEvent!(<String, dynamic>{});
          disconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      disconnect();
    }
  }
}
