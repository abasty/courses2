/// La classe abstraite [StorageStrategy] de cette bibliothèque définit une
/// interface de stockage de `Map<String, dynamic>` vers un support quelconque.
///
/// [MemoryMapStrategy], [LocalStorageStrategy] et [DelayedStrategy] fournissent
/// des implémentations de cette classe.
library storage;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pedantic/pedantic.dart';

/// La classe abstraite pour lire et écrire une Map<String, dynamic> sur un
/// support de stockage.
abstract class StorageStrategy {
  /// À vrai si le_storage_ est connectable **et** connecté
  bool isConnected = false;

  /// Si le _storage_ est connectable [hostname] est le nom du serveur
  String hostname = '';

  /// Écrit la map sur le support de stockage.
  Future<void> write(Map<String, dynamic> map);

  /// Écrit un seul élément
  Future<void> advertise(String path, Map<String, dynamic> map);

  /// Lit et renvoie une map depuis le support de stockage.
  Future<Map<String, dynamic>> read();

  /// Déconnecte le storage
  void disconnect();

  /// Connecte le storage
  Future connect();
}

/// Reads dataset [name] from assets. This function MUST NOT fail.
Future<Map<String, dynamic>> readFromAsset(String name) async {
  return json.decode(await rootBundle.loadString('assets/$name.json'))
      as Map<String, dynamic>;
}

/// Une stratégie de stockage de map en mémoire dans une autre map.
class MemoryMapStrategy implements StorageStrategy {
  Map<String, dynamic> _map;

  /// Crée la map de stockage depuis la [_map].
  MemoryMapStrategy(this._map) : hostname = '';

  @override
  Future<void> write(Map<String, dynamic> map) async => _map = map;

  @override
  Future<Map<String, dynamic>> read() async => _map;

  @override
  bool isConnected = false;

  @override
  Future<void> advertise(String path, Map<String, dynamic> map) async {}

  @override
  void disconnect() {}

  @override
  Future connect() async {}

  @override
  String hostname;
}

/// Une stratégie de stockage de map dans un fichier local.
class LocalStorageStrategy implements StorageStrategy {
  final _storage;

  LocalStorageStrategy(String _filename) : _storage = LocalStorage(_filename);

  /// Écrit [map] sur le fichier `courses3.json`.
  @override
  Future<void> write(Map<String, dynamic> map) async {
    await _storage.ready;
    await _storage.setItem('modele', json.encode(map));
  }

  /// Lit une map depuis le fichier `courses3.json`. Si le fichier n'existe pas,
  /// lit depuis les _assets_.
  @override
  Future<Map<String, dynamic>> read() async {
    await _storage.ready;
    dynamic str = await _storage.getItem('modele');
    Map<String, dynamic> map;
    try {
      map = json.decode(str as String) as Map<String, dynamic>;
    } on Error {
      map = {};
    }
    return map;
  }

  @override
  bool isConnected = false;

  @override
  Future<void> advertise(String path, Map<String, dynamic> map) async {}

  @override
  void disconnect() {}

  @override
  Future connect() async {}

  @override
  String hostname = '';
}

/// Un _wrapper_ de stratégie de stockage qui simule un délai en lecture.
class DelayedStrategy implements StorageStrategy {
  final StorageStrategy _storage;
  final int _seconds;

  /// Crée une [DelayedStrategy] depuis un [StorageStrategy] et ajoute un délai
  /// de [_seconds] secondes à [read()].
  DelayedStrategy(this._storage, this._seconds);

  /// Appelle [write()] du [StorageStrategy].
  @override
  Future<void> write(Map<String, dynamic> map) async {
    return _storage.write(map);
  }

  /// Appelle [read()] du [StorageStrategy] et attend de façon asynchrone
  /// [_seconds] secondes avant de renvoyer la map.
  @override
  Future<Map<String, dynamic>> read() async {
    var map = _storage.read();
    await Future.delayed(Duration(seconds: _seconds));
    return map;
  }

  @override
  Future<void> advertise(String path, Map<String, dynamic> map) async {}

  @override
  void disconnect() {
    _storage.disconnect();
  }

  @override
  Future connect() async {
    unawaited(_storage.connect());
  }

  @override
  bool get isConnected => _storage.isConnected;

  @override
  set isConnected(bool _isConnected) {
    _storage.isConnected = _isConnected;
  }

  @override
  String get hostname => _storage.hostname;

  @override
  set hostname(String _hostname) => _storage.hostname = _hostname;
}
