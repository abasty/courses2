// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courses2/modele.dart';
import 'package:courses2/liste_screen.dart';

import 'dataset.dart';

void main() async {
  modele = ModeleCourses(DatasetStorageCourses());
  modele.readAll();
  await modele.isLoaded;

  testWidgets('ListeScreen Widget Test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(home: ListeScreen()),
      );

      // La première image n'affiche que le "progress indicator"
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // On prend une image pour que le FutureBuilder se réalise
      await tester.pump();
      // Le "progress indicator" laisse place à la liste des produits
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Produits'), findsOneWidget);
      // On doit avoir autant d'icones (+) que de produits dans le modèle
      var icon = find.byIcon(Icons.add_circle);
      expect(icon, findsNWidgets(modele.produits.length));
      // On appuie sur le premier (+)
      await tester.tap(icon.first);
      // Le modèle a été mis à jour mais pas encore l'UI
      assert(modele.produits[0].quantite == 1);
      expect(find.text('1'), findsNothing);

      // On prend une autre image
      await tester.pump();
      // Le widget doit afficher la nouvelle valeur
      expect(find.text('1'), findsOneWidget);
    });
  });
}
