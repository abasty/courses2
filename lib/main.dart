import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

import 'modele.dart';

class StocksApp extends StatefulWidget {
  @override
  StocksAppState createState() => StocksAppState();
}

class StocksAppState extends State<StocksApp> with TickerProviderStateMixin {
  TabController _tabController;
  var _actionIcon = Icons.add;
  var _isLoaded = modele.readAll();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      if (Platform.isLinux) {
        setWindowTitle('Exemple Stocks');
        setWindowFrame(Rect.fromLTRB(0, 0, 400, 600));
      }
    }

    _tabController = TabController(vsync: this, length: 2)
      ..addListener(
        () => setState(
          () => _tabController.index == 0
              ? _actionIcon = Icons.add
              : _actionIcon = Icons.remove_shopping_cart,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => FutureBuilder(
          future: _isLoaded,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.done
                  ? _buildScaffold(context)
                  : Container(
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
        ),
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Produits"),
            Tab(text: "Liste"),
          ],
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: modele,
        builder: (context, snapshot) => TabBarView(
          controller: _tabController,
          children: [
            _buildTabProduits(),
            _buildTabListe(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(_actionIcon),
        onPressed: () => _tabController.index == 0
            ? _editeProduit(context, null)
            : modele.ctrlValideChariot(),
      ),
    );
  }

  Widget _buildTabProduits() {
    return ListView.builder(
      itemCount: modele.produits.length,
      itemBuilder: (context, index) {
        Produit p = modele.produits[index];
        return Consumer<ModeleStocksSingleton>(
          builder: (context, stocks, child) {
            return ListTile(
              title: Text(p.nom),
              subtitle: Text(p.rayon.nom),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () => modele.ctrlProduitMoins(p),
                  ),
                  Text("${p.quantite}"),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: () => modele.ctrlProduitPlus(p),
                  ),
                ],
              ),
              selected: p.quantite > 0,
              onTap: () => modele.ctrlProduitInverse(p),
              onLongPress: () => _editeProduit(context, p),
            );
          },
        );
      },
    );
  }

  Widget _buildTabListe() {
    return Consumer<ModeleStocksSingleton>(
      builder: (context, stocks, child) {
        return ListView.builder(
          itemCount: modele.listeSelect.length,
          itemBuilder: (context, index) {
            Produit p = modele.listeSelect[index];
            return CheckboxListTile(
              title:
                  Text("${p.nom} ${p.quantite > 1 ? '(${p.quantite})' : ''}"),
              subtitle: Text(p.rayon.nom),
              value: p.fait,
              onChanged: (bool value) => modele.ctrlProduitPrend(p, value),
            );
          },
        );
      },
    );
  }

  void _editeProduit(BuildContext context, Produit p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProduitForm(p),
      ),
    );
    setState(() {});
  }
}

class EditProduitForm extends StatefulWidget {
  final Produit _p;

  EditProduitForm(this._p);

  @override
  EditProduitFormState createState() {
    return EditProduitFormState(_p);
  }
}

class EditProduitFormState extends State<EditProduitForm> {
  final _formKey = GlobalKey<FormState>();
  final Produit _init;
  Produit _maj;

  EditProduitFormState(this._init) {
    _init != null
        ? _maj = Produit(_init.nom, _init.rayon)
        : _maj = Produit("", modele.rayonDivers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.clear), onPressed: _annulePressed),
        title: Text(_init == null ? "Création" : "Édition"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _validePressed,
          ),
        ],
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildForm(),
    );
  }

  void _annulePressed() {
    Navigator.pop(context);
  }

  void _validePressed() {
    if (_formKey.currentState.validate()) {
      modele.ctrlMajProduit(_init, _maj);
      Navigator.pop(context);
    }
  }

  Widget _buildRayonButtons() {
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
              onChanged: (Rayon r) => setState(() => _maj.rayon = r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProduitNom() {
    return TextFormField(
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Nom*',
        hintText: 'Nom du produit',
      ),
      initialValue: _maj.nom,
      validator: (nom) {
        if (nom.length < 2) {
          return 'Le nom doit contenir au moins deux caractères';
        } else {
          _maj.nom = nom;
          return null;
        }
      },
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildProduitNom(),
          ),
          _buildRayonButtons(),
        ],
      ),
    );
  }
}

void main() {
  runApp(StocksApp());
}
