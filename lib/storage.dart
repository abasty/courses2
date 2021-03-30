import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

abstract class StorageStrategy {
  Future<void> writeAll(Map<String, dynamic> map);
  Future<Map<String, dynamic>> readAll();
}

class MemoryMapStrategy implements StorageStrategy {
  Map<String, dynamic> _map;

  MemoryMapStrategy(this._map);

  @override
  Future<void> writeAll(Map<String, dynamic> map) async => _map = map;

  @override
  Future<Map<String, dynamic>> readAll() async => _map;
}

class LocalStorageStrategy implements StorageStrategy {
  final _storage = LocalStorage('courses.json');

  @override
  Future<void> writeAll(Map<String, dynamic> map) async {
    await _storage.ready;
    await _storage.setItem('modele', json.encode(map));
  }

  @override
  Future<Map<String, dynamic>> readAll() async {
    await _storage.ready;
    var str = await _storage.getItem('modele') as String?;
    str ??= await rootBundle.loadString('assets/courses.json');
    return json.decode(str) as Map<String, dynamic>;
  }
}

class DelayedStrategy implements StorageStrategy {
  final StorageStrategy _storage;
  final int _seconds;

  DelayedStrategy(this._storage, this._seconds);

  @override
  Future<void> writeAll(Map<String, dynamic> map) async {
    return _storage.writeAll(map);
  }

  @override
  Future<Map<String, dynamic>> readAll() async {
    var map = _storage.readAll();
    await Future.delayed(Duration(seconds: _seconds));
    return map;
  }
}
