import 'dart:convert';
import 'package:http/http.dart' as http;

import 'courses_sse_client.dart';
import 'storage.dart';

class BackendStrategy implements StorageStrategy {
  final _storage = LocalStorageStrategy();
  final String _host;
  final data = <String>[];
  late SseClient client;
  Function? pushEvent;

  bool isConnected = false;

  BackendStrategy(this._host) {
    // client = SseClient.getInstance('http://$_host/sync');
    /* client = SseClient('http://$_host/sync')
      ..stream.listen(
        (str) {
          data.add(str);
          if (str.startsWith('data: ')) {
            var produit_ret = json.decode(
                str.substring(7, str.length - 1).replaceAll('\\"', '"'));
            if (pushEvent != null) pushEvent!(produit_ret);
          }
        },
        onDone: () {
          print('done');
        },
        onError: (Object err) {
          print('error');
        },
        cancelOnError: true,
      );*/
  }

  @override
  Future<Map<String, dynamic>> read() async {
    var map = await fetchData('courses/all');
    if (map != null && map is Map<String, dynamic>) {
      await client.onConnected;
      return map;
    }
    return _storage.read();
  }

  @override
  Future<void> write(Map<String, dynamic> map) {
    return _storage.write(map);
  }

  Future<void> push(Map<String, dynamic> map) async {
    // ignore: unawaited_futures
    http.post(
      Uri.http(_host, 'courses/produit'),
      body: json.encode(map),
    );
  }

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
      print('Exception ici si connection refused');
      isConnected = false;
      return null;
    }
  }
}
