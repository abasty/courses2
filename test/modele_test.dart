import 'package:flutter_test/flutter_test.dart';

import 'package:courses2/modele.dart';
import 'dataset.dart';

void main() async {
  modele = ModeleCourses(DatasetStorageCourses());
  await modele.isLoaded;
  test('modele init', () {
    assert(modele.produits.length >= 4);
    assert(modele.produits[0].nom == 'Escalope de porc');
    assert(modele.produits[3].nom == 'Pomme de terre');
  });
  test('ctrlProduitPlus / ctrlProduitMoins / produitsCheck', () {
    assert(modele.produits.length >= 4);
    var p = modele.produits[3];
    modele.ctrlProduitPlus(p);
    assert(p.quantite == 1);
    assert(modele.selection.isNotEmpty);
    assert(modele.selection[0].nom == p.nom);
    modele.ctrlProduitMoins(p);
    assert(p.quantite == 0);
    assert(modele.selection.isEmpty);
    modele.ctrlProduitMoins(p);
    assert(p.quantite == 0);
    assert(modele.selection.isEmpty);
  });
}
