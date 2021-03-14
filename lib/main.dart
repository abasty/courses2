import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'modele.dart';
import 'liste_screen.dart';
import 'produit_screen.dart';
import 'storage.dart';

void main() {
  if (!kDebugMode) debugPrint = (String? message, {int? wrapWidth}) {};

  modele = ModeleCourses(LocalStorageCourses());
  modele.readAll();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: ListeScreen.name,
      routes: {
        ListeScreen.name: (context) => ListeScreen(),
      },
      onGenerateRoute: (r) {
        if (r.name == ProduitScreen.name) {
          return MaterialPageRoute(
              builder: (context) => ProduitScreen(r.arguments as Produit?));
        }
        return null;
      },
    ),
  );
}
