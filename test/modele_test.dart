import 'package:flutter_test/flutter_test.dart';

import 'package:courses2/modele.dart';
import 'package:courses2/storage.dart';
import 'dataset.dart';

class DatasetStorageCourses extends StorageCourses {
  Future<void> writeAll(String json) async {}

  Future<String> readAll() async {
    return dataset;
  }
}

void main() async {
  modele = ModeleCourses(DatasetStorageCourses());
  modele.readAll();
  await modele.isLoaded;
  test('modele initialization', () {
    assert(modele.produits[0].nom == "Escalope de porc");
  });
  test('ctrlProduitPlus / ctrlProduitMoins / produitsCheck', () {
    Produit p = modele.produits[0];
    modele.ctrlProduitPlus(p);
    assert(p.quantite == 1);
    assert(modele.produitsCheck.isNotEmpty);
    assert(modele.produitsCheck[0].nom == p.nom);
    modele.ctrlProduitMoins(p);
    assert(p.quantite == 0);
    assert(modele.produitsCheck.isEmpty);
    modele.ctrlProduitMoins(p);
    assert(p.quantite == 0);
    assert(modele.produitsCheck.isEmpty);
  });
}
