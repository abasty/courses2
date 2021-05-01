/// Définit [ProduitScreen], l'écran de création / modification d'un [Produit]
/// et le [ProduitScreenState] associé.
library produit_screen;

import 'package:flutter/material.dart';

import 'modele.dart';

class ProduitScreen extends StatefulWidget {
  static const name = '/produit';
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

  ProduitScreenState(this._init)
      : _maj = _init != null
            ? Produit(_init.nom, _init.rayon)
            : Produit('', modele.divers);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => Navigator.pop(context),
        ),
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

  void _validePressed() {
    if (_formKey.currentState!.validate()) {
      modele.ctrlProduitMaj(_init, _maj);
      Navigator.pop(context);
    }
  }

  Widget _rayonButtons() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Scrollbar(
          isAlwaysShown: true,
          child: ListView.builder(
            itemCount: modele.rayons.length,
            itemBuilder: (context, index) {
              return RadioListTile<Rayon>(
                title: Text(modele.rayons[index].nom),
                dense: true,
                value: modele.rayons[index],
                groupValue: _maj.rayon,
                onChanged: (Rayon? r) => setState(() => _maj.rayon = r!),
              );
            },
          ),
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _produitNom(),
            _rayonButtons(),
            if (_init != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  child: Text('Supprimer'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
