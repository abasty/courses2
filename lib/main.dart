/// Le point d'entrée de l'application `courses2`
library main;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'modele.dart';
import 'liste_screen.dart';
import 'produit_screen.dart';
import 'storage.dart';

/// Crée le modèle en lui associant une [StorageStrategy], crée la [MaterialApp]
/// et définit les routes vers [ListeScreen] et [ProduitScreen].
void main() {
  if (!kDebugMode) debugPrint = (String? message, {int? wrapWidth}) {};

  modele = VueModele(DelayedStrategy(LocalStorageStrategy(), 2));
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
