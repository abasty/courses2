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
      // test code here
      await tester.pumpWidget(
        // Wrap our widget in a MaterialApp for MediaQuery
        MaterialApp(home: ListeScreen()),
      );

      // First frame just display the progress indicator
      var progress = find.byType(CircularProgressIndicator);
      print(progress);

      // Take a frame for the FutureBuilder to realize
      await tester.pump();

      // The progress indicator went away and the list is displayed
      progress = find.byType(CircularProgressIndicator);
      print(progress);
      final text = find.text('Produits');
      print(text);
      final icon = find.byIcon(Icons.add_circle);
      print(icon);
    });
  });
}
