import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

abstract class StorageStocks {
  Future<void> writeAll(String json);
  Future<String> readAll();
}

class LocalStorageStocks extends StorageStocks {
  final _storage = LocalStorage('stocks.json');

  Future<void> writeAll(String json) async {
    await _storage.ready;
    await _storage.setItem("modele", json);
  }

  Future<String> readAll() async {
    String json;
    await _storage.ready;
    json = await _storage.getItem('modele');
    if (json == null) {
      json = await rootBundle.loadString("assets/stocks.json");
    }
    // await Future.delayed(Duration(seconds: 2));
    return json;
  }
}
