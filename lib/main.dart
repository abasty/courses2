import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'modele.dart';
import 'liste_screen.dart';
import 'produit_screen.dart';
import 'storage.dart';

void main() {
  if (!kDebugMode) debugPrint = (String message, {int wrapWidth}) {};

  modele = ModeleCourses(LocalStorageCourses());
  modele.readAll();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: ListeScreen.path,
      routes: {
        ListeScreen.path: (context) => ListeScreen(),
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
