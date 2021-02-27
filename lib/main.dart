import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'modele.dart';
import 'liste_screen.dart';
import 'produit_screen.dart';
import 'storage.dart';

void main() {
  if (!kDebugMode) debugPrint = (String message, {int wrapWidth}) {};

  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      setWindowTitle('Exemple Courses II');
      setWindowFrame(Rect.fromLTRB(0, 0, 400, 600));
    }
  }
  modele = ModeleCourses(LocalStorageCourses());
  modele.readAll();
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => ListeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ProduitScreen.path) {
          final args = settings.arguments as ProduitArgs;
          return MaterialPageRoute(builder: (context) => ProduitScreen(args));
        } else {
          return null;
        }
      },
    ),
  );
}
