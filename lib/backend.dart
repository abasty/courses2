import 'dart:convert';
import 'package:http/http.dart' as http;

import 'storage.dart';

class BackendStrategy implements StorageStrategy {
  final _storage = LocalStorageStrategy();
  final String _host;
  @override
  bool isConnected = false;

  BackendStrategy(this._host);

  @override
  Future<Map<String, dynamic>> read() async {
    var map = await fetchData('courses/all');
    if (map != null && map is Map<String, dynamic>) return map;
    return _storage.read();
  }

  @override
  Future<void> write(Map<String, dynamic> map) {
    return _storage.write(map);
  }

  Future<void> push() async {}

  Future<Object?> fetchData(String path) async {
    try {
      var response = await http.get(Uri.http(_host, path));
      if (response.statusCode == 200) {
        isConnected = true;
        return json.decode(response.body) as Object;
      } else {
        isConnected = false;
        return null;
      }
    } on Error {
      isConnected = false;
      return null;
    } on Exception {
      isConnected = false;
      return null;
    }
  }
}
