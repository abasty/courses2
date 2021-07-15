import 'dart:async';
import 'dart:convert';

import 'package:courses_sse_client/courses_sse_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'storage.dart';

class BackendStrategy implements StorageStrategy {
  static const int _reconnect_attemps_max = 1;
  final _storage = LocalStorageStrategy('courses3.json');
  SseClient? _sse_client;
  Function? pushEvent;
  int _reconnect_attemps = 0;

  @override
  bool isConnected = false;

  @override
  Future<Map<String, dynamic>> read() async {
    var map = await fetchData('courses/all');
    if (map != null && map is Map<String, dynamic>) return map;
    isConnected = false;
    return _storage.read();
  }

  @override
  Future<void> write(Map<String, dynamic> map) {
    return _storage.write(map);
  }

  @override
  Future<void> advertise(String path, Map<String, dynamic> map) async {
    if (_sse_client == null) return;
    try {
      var response = await http.post(
        Uri(
          scheme: uri?.scheme,
          host: uri?.host,
          port: uri?.port,
          userInfo: uri?.userInfo,
          path: '/courses/produit',
          queryParameters: {'sseClientId': _sse_client!.clientId},
        ),
        body: json.encode(map),
      );
      isConnected = response.statusCode == 200;
      debugPrint('sent: ${response.statusCode}');
    } catch (e) {
      disconnect();
    }
  }

  Future<Object?> fetchData(String path) async {
    try {
      var response = await http
          .get(Uri(
              scheme: uri?.scheme,
              host: uri?.host,
              port: uri?.port,
              path: path,
              userInfo: uri?.userInfo))
          .timeout(Duration(seconds: 5),
              onTimeout: () => http.Response('Timeout', 504));
      if (response.statusCode == 200) {
        await connect();
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
  void disconnect([bool unsolicited = false]) {
    if (!isConnected) return;
    debugPrint('disconnect(${unsolicited ? "network" : "user"})');
    isConnected = false;
    if (unsolicited) {
      _reconnect_attemps--;
      if (_reconnect_attemps >= 0) connect();
    } else {
      _reconnect_attemps = 0;
      _sse_client?.close();
    }
  }

  @override
  Future connect() async {
    if (isConnected || uri == null) return;

    try {
      debugPrint('connect(${uri!.host})');
      _sse_client = SseClient.fromUriAndPath(uri!, '/sync');
      await _sse_client!.onConnected;
      isConnected = true;
      _reconnect_attemps = _reconnect_attemps_max;
      pushEvent?.call(<String, dynamic>{});
    } catch (e) {
      disconnect();
    }
    if (!isConnected) return;

    runZonedGuarded(
      () {
        _sse_client!.stream.listen(
          (str) {
            debugPrint('read: $str');
            if (str.isEmpty || str == 'ping') return;
            var map;
            try {
              map = json.decode(str) as Map<String, dynamic>;
            } catch (e) {
              map = {};
            }
            pushEvent?.call(map);
          },
          onDone: () {
            pushEvent?.call(<String, dynamic>{});
            debugPrint('onDone');
            disconnect(true);
          },
          cancelOnError: true,
        );
      },
      (e, s) {
        debugPrint('runZonedGuarded: ' + e.runtimeType.toString());
        disconnect(true);
      },
    );
  }

  @override
  Uri? uri;
}
