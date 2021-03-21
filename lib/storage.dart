import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

abstract class StorageStrategy {
  Future<void> writeAll(Map<String, dynamic> json);
  Future<Map<String, dynamic>> readAll();
}

class LocalStorageStrategy extends StorageStrategy {
  final _storage = LocalStorage('courses.json');

  @override
  Future<void> writeAll(Map<String, dynamic> map) async {
    await _storage.ready;
    await _storage.setItem('modele', json.encode(map));
  }

  @override
  Future<Map<String, dynamic>> readAll() async {
    await _storage.ready;
    var map = await _storage.getItem('modele') as String?;
    map ??= await rootBundle.loadString('assets/courses.json');
    await Future.delayed(Duration(seconds: 2));
    return json.decode(map) as Map<String, dynamic>;
  }
}
