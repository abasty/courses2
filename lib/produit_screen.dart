import 'package:flutter/material.dart';

import 'modele.dart';

class ProduitArgs {
  final Produit? produit;

  ProduitArgs([this.produit]);
}

class ProduitScreen extends StatefulWidget {
  static const path = '/produit';
  final Produit? _init;

  ProduitScreen(this._init);

  @override
  ProduitScreenState createState() {
    return ProduitScreenState(_init);
  }
}

class ProduitScreenState extends State<ProduitScreen> {
  final _formKey = GlobalKey<FormState>();
  final Produit? _init;
  final Produit _maj;

  ProduitScreenState([this._init])
      : _maj = _init != null
            ? Produit(_init.nom, _init.rayon)
            : Produit('', modele.divers);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.clear), onPressed: _annulePressed),
        title: Text(_init == null ? 'Création' : 'Édition'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _validePressed,
          ),
        ],
        backgroundColor: Colors.deepPurple,
      ),
      body: _form(),
    );
  }

  void _annulePressed() {
    Navigator.pop(context);
  }

  void _validePressed() {
    if (_formKey.currentState!.validate()) {
      modele.ctrlMajProduit(_init, _maj);
      Navigator.pop(context);
    }
  }

  Widget _rayonButtons() {
    return Expanded(
      child: ListView.builder(
        itemCount: modele.rayons.length,
        itemBuilder: (context, index) {
          return Container(
            height: 32,
            child: RadioListTile<Rayon>(
              title: Text(modele.rayons[index].nom),
              value: modele.rayons[index],
              groupValue: _maj.rayon,
              onChanged: (Rayon? r) => setState(() => _maj.rayon = r!),
            ),
          );
        },
      ),
    );
  }

  Widget _produitNom() {
    return TextFormField(
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Nom*',
        hintText: 'Nom du produit',
      ),
      initialValue: _maj.nom,
      validator: (nom) {
        if (nom == null) return '';
        if (nom.length < 2) {
          return 'Le nom doit contenir au moins deux caractères';
        } else {
          _maj.nom = nom;
          return null;
        }
      },
    );
  }

  Form _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _produitNom(),
          ),
          _rayonButtons(),
        ],
      ),
    );
  }
}
