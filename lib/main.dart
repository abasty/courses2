import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'modele.dart';
import 'liste_screen.dart';
import 'produit_screen.dart';
import 'storage.dart';

void main() {
  if (!kDebugMode) debugPrint = (String? message, {int? wrapWidth}) {};

  modele = Modele(LocalStorageStrategy());
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
