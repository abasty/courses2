import 'package:flutter_test/flutter_test.dart';
import 'package:courses2/modele.dart';
import 'package:mockito/mockito.dart';

//import '../lib/modele.dart';

class MockModele extends Mock implements ModeleCoursesSingleton {}

var mockModele = MockModele();

// Ce qu'il faut mocker c'est pas le modèle, c'est le storage
// => on passe le storage à la création du singleton. Donc il faut que le
// constructeur du singleton est en paramètre le storage

void main() {
  test('modele initialization', () async {
    var rayon = Rayon("Divers");
    var produits = [Produit("Pantoufles", rayon)];
    when(mockModele.produits).thenReturn(produits);
    modele.ctrlProduitPlus(produits[0]);
    //verify(mockModele.ctrlProduitPlus(produits[0]));
    print(mockModele.produits);
  });
}
