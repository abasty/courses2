import 'package:flutter_test/flutter_test.dart';
import 'package:courses2/modele.dart';
import 'package:mockito/mockito.dart';

//import '../lib/modele.dart';

class MockModele extends Mock implements ModeleCoursesSingleton {}

var mockModele = MockModele();

void main() {
  test('modele initialization', () async {
    mockModele.readAll();
    await mockModele.isLoaded;
    print(mockModele.rayons); // is null
    print(modele.rayons); // is []
    //expect(mockModele.produits[0].nom, "Escalope de porc");
  });
}
