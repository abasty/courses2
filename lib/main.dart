import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'modele.dart';
import 'liste_screen.dart';
import 'produit_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      setWindowTitle('Exemple Courses II');
      setWindowFrame(Rect.fromLTRB(0, 0, 400, 600));
    }
  }
  modele.readAll();
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => ListeScreen(),
      },
      onGenerateRoute: (settings) => settings.name == ProduitScreen.path
          ? MaterialPageRoute(
              builder: (context) => ProduitScreen(settings.arguments))
          : null,
    ),
  );
}
