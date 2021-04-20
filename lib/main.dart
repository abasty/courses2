/// Le point d'entrée de l'application `courses3`
library main;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'backend.dart';
import 'liste_screen.dart';
import 'modele.dart';
import 'produit_screen.dart';

/// Crée le modèle en lui associant une [StorageStrategy], crée la [MaterialApp]
/// et définit les routes vers [ListeScreen] et [ProduitScreen].
void main() {
  if (!kDebugMode) debugPrint = (String? message, {int? wrapWidth}) {};

  modele = VueModele(BackendStrategy('localhost:8067'));
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        ListeScreen.name: (context) => ListeScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == ProduitScreen.name) {
          return MaterialPageRoute(
            builder: (context) => ProduitScreen(settings.arguments as Produit?),
          );
        }
        return null;
      },
      initialRoute: ListeScreen.name,
    ),
  );
}
