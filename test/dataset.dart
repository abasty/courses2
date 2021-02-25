import 'package:courses2/storage.dart';

class DatasetStorageCourses extends StorageCourses {
  Future<void> writeAll(String json) async {}

  Future<String> readAll() async {
    return dataset;
  }
}

const dataset = '''
{
    "rayons": [
        {
            "nom": "Divers"
        },
        {
            "nom": "Boucherie"
        },
        {
            "nom": "Légumes"
        },
        {
            "nom": "Fruits"
        },
        {
            "nom": "Épicerie"
        },
        {
            "nom": "Frais"
        },
        {
            "nom": "Fromagerie"
        },
        {
            "nom": "Poissonnerie"
        },
        {
            "nom": "Surgelés"
        },
        {
            "nom": "Boulangerie"
        },
        {
            "nom": "Hygiène"
        },
        {
            "nom": "Boisson"
        }
    ],
    "produits": [
        {
            "nom": "Escalope de porc",
            "rayon": {
                "nom": "Boucherie"
            },
            "quantite": 0,
            "fait": false
        },
        {
            "nom": "Gîte de boeuf",
            "rayon": {
                "nom": "Boucherie"
            },
            "quantite": 0,
            "fait": false
        },
        {
            "nom": "Paleron de boeuf",
            "rayon": {
                "nom": "Boucherie"
            },
            "quantite": 0,
            "fait": false
        },
        {
            "nom": "Pomme de terre",
            "rayon": {
                "nom": "Légumes"
            },
            "quantite": 0,
            "fait": false
        },
        {
            "nom": "Carotte",
            "rayon": {
                "nom": "Légumes"
            },
            "quantite": 0,
            "fait": false
        },
        {
            "nom": "Poireau",
            "rayon": {
                "nom": "Légumes"
            },
            "quantite": 0,
            "fait": false
        },
        {
            "nom": "Sel",
            "rayon": {
                "nom": "Épicerie"
            },
            "quantite": 0,
            "fait": false
        }
    ]
}
''';
