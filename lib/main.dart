import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

import 'modele.dart';

class ListeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: modele.isLoaded,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? _scaffold()
              : Container(
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
    );
  }

  Widget _scaffold() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stocks'),
          bottom: TabBar(
            tabs: [
              Tab(text: "Produits"),
              Tab(text: "Liste"),
            ],
          ),
        ),
        body: ChangeNotifierProvider.value(
          value: modele,
          builder: (context, snapshot) => TabBarView(
            children: [
              _tabProduits(),
              _tabListe(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabProduits() {
    return Stack(
      children: [
        Consumer<ModeleStocksSingleton>(
          builder: (context, stocks, child) {
            return ListView.builder(
              itemCount: modele.produits.length,
              itemBuilder: (context, index) {
                return ChangeNotifierProvider.value(
                  value: modele.produits[index],
                  child: Consumer<Produit>(
                    builder: (context, p, child) => _produitTile(p, context),
                  ),
                );
              },
            );
          },
        ),
        Builder(
          builder: (context) => _actionButton(
            Icons.add,
            () => Navigator.pushNamed(
              context,
              ProduitScreen.path,
              arguments: ProduitArgs(null),
            ),
          ),
        ),
      ],
    );
  }

  ListTile _produitTile(Produit p, BuildContext context) {
    print(p.nom);
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
      onLongPress: () => Navigator.pushNamed(
        context,
        ProduitScreen.path,
        arguments: ProduitArgs(p),
      ),
    );
  }

  Widget _tabListe() {
    return Consumer<ModeleStocksSingleton>(
      builder: (context, stocks, child) {
        return Stack(
          children: [
            ListView.builder(
              itemCount: modele.listeSelect.length,
              itemBuilder: (context, index) {
                Produit p = modele.listeSelect[index];
                return CheckboxListTile(
                  title: Text(
                      "${p.nom} ${p.quantite > 1 ? '(${p.quantite})' : ''}"),
                  subtitle: Text(p.rayon.nom),
                  value: p.fait,
                  onChanged: (bool value) => modele.ctrlProduitPrend(p, value),
                );
              },
            ),
            _actionButton(Icons.remove_shopping_cart, modele.ctrlValideChariot),
          ],
        );
      },
    );
  }

  Widget _actionButton(IconData icon, Function action) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
          alignment: Alignment.bottomCenter,
          child: Ink(
            decoration: const ShapeDecoration(
              color: Colors.lightBlue,
              shape: CircleBorder(),
            ),
            child: FloatingActionButton(child: Icon(icon), onPressed: action),
          )),
    );
  }
}

class ProduitArgs {
  final Produit p;

  ProduitArgs(this.p);
}

class ProduitScreen extends StatefulWidget {
  static const path = '/produit';
  final Produit _init;

  ProduitScreen(ProduitArgs args) : _init = args.p;

  @override
  ProduitScreenState createState() {
    return ProduitScreenState(_init);
  }
}

class ProduitScreenState extends State<ProduitScreen> {
  final _formKey = GlobalKey<FormState>();
  final Produit _init;
  Produit _maj;

  ProduitScreenState(this._init) {
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
      body: _form(),
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
              onChanged: (Rayon r) => setState(() => _maj.rayon = r),
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isLinux) {
      setWindowTitle('Exemple Stocks');
      setWindowFrame(Rect.fromLTRB(0, 0, 400, 600));
    }
  }
  modele.readAll();
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => ListeScreen(),
      },
      onGenerateRoute: (settings) => settings.name == ProduitScreen.path
          ? MaterialPageRoute(
              builder: (context) => ProduitScreen(settings.arguments))
          : null,
    ),
  );
}
