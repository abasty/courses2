/// La classe abstraite [StorageStrategy] de cette bibliothèque définit une
/// interface de stockage de `Map<String, dynamic>` vers un support quelconque.
///
/// [MemoryMapStrategy], [LocalStorageStrategy] et [DelayedStrategy] fournissent
/// des implémentations de cette classe.
library storage;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

/// La classe abstraite pour lire et écrire une Map<String, dynamic> sur un
/// support de stockage.
abstract class StorageStrategy {
  /// Écrit la map sur le support de stockage.
  Future<void> write(Map<String, dynamic> map);

  /// Lit et renvoie une map depuis le support de stockage.
  Future<Map<String, dynamic>> read();
}

/// Une stratégie de stockage de map en mémoire dans une autre map.
class MemoryMapStrategy implements StorageStrategy {
  Map<String, dynamic> _map;

  /// Crée la map de stockage depuis la [_map].
  MemoryMapStrategy(this._map);

  @override
  Future<void> write(Map<String, dynamic> map) async => _map = map;

  @override
  Future<Map<String, dynamic>> read() async => _map;
}

/// Une stratégie de stockage de map dans un fichier local.
class LocalStorageStrategy implements StorageStrategy {
  final _storage = LocalStorage('courses2.json');

  /// Écrit [map] sur le fichier `courses2.json`.
  @override
  Future<void> write(Map<String, dynamic> map) async {
    await _storage.ready;
    await _storage.setItem('modele', json.encode(map));
  }

  /// Lit une map depuis le fichier `courses2.json`. Si le fichier n'existe pas,
  /// lit depuis les _assets_.
  @override
  Future<Map<String, dynamic>> read() async {
    await _storage.ready;
    var str = await _storage.getItem('modele') as String?;
    str ??= await rootBundle.loadString('assets/courses.json');
    return json.decode(str) as Map<String, dynamic>;
  }
}

/// Un _wrapper_ de stratégie de stockage qui simule un délai en lecture.
class DelayedStrategy implements StorageStrategy {
  final StorageStrategy _storage;
  final int _seconds;

  /// Crée une [DelayedStrategy] depuis un [StorageStrategy] et ajoute un délai
  /// de [_seconds] secondes à [readAll()].
  DelayedStrategy(this._storage, this._seconds);

  /// Appelle [writeAll()] du [StorageStrategy].
  @override
  Future<void> write(Map<String, dynamic> map) async {
    return _storage.write(map);
  }

  /// Appelle [readAll()] du [StorageStrategy] et attend de façon asynchrone
  /// [_seconds] secondes avant de renvoyer la map.
  @override
  Future<Map<String, dynamic>> read() async {
    var map = _storage.read();
    await Future.delayed(Duration(seconds: _seconds));
    return map;
  }
}
