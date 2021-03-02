import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

abstract class StorageCourses {
  Future<void> writeAll(String json);
  Future<Map<String, dynamic>> readAll();
}

class LocalStorageCourses extends StorageCourses {
  final _storage = LocalStorage('courses.json');

  @override
  Future<void> writeAll(String json) async {
    await _storage.ready;
    await _storage.setItem('modele', json);
  }

  @override
  Future<Map<String, dynamic>> readAll() async {
    await _storage.ready;
    var json = await _storage.getItem('modele') as String;
    json ??= await rootBundle.loadString('assets/courses.json');
    await Future.delayed(Duration(seconds: 2));
    return jsonDecode(json) as Map<String, dynamic>;
  }
}
