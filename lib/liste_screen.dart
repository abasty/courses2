import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'modele.dart';
import 'produit_screen.dart';

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
        body: ChangeNotifierProvider<ModeleStocksSingleton>.value(
          value: modele,
          builder: (context, snapshot) => TabBarView(
            children: [
              _produitListTab(),
              _produitCheckTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _produitListTab() {
    return Stack(
      children: [
        Consumer<ModeleStocksSingleton>(
          builder: (context, vm, child) {
            return ListView.builder(
              itemCount: modele.produits.length,
              itemBuilder: (context, index) =>
                  ProduitConsumer(modele.produits[index], _produitListTile),
            );
          },
        ),
        Builder(
          builder: (context) => LocalActionButton(
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

  Widget _produitListTile(BuildContext context, Produit p, Widget child) {
    debugPrint(p.toString());
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

  Widget _produitCheckTab() {
    return Consumer<ModeleStocksSingleton>(
      builder: (context, vm, child) {
        return Stack(
          children: [
            ListView.builder(
              itemCount: modele.listeSelect.length,
              itemBuilder: (context, index) =>
                  ProduitConsumer(modele.listeSelect[index], _produitCheckTile),
            ),
            LocalActionButton(
                Icons.remove_shopping_cart, modele.ctrlValideChariot)
          ],
        );
      },
    );
  }

  Widget _produitCheckTile(BuildContext context, Produit p, Widget child) {
    debugPrint(p.toString());
    return CheckboxListTile(
      title: Text("${p.nom} ${p.quantite > 1 ? '(${p.quantite})' : ''}"),
      subtitle: Text(p.rayon.nom),
      value: p.fait,
      onChanged: (bool value) => modele.ctrlProduitPrend(p, value),
    );
  }
}

class ProduitConsumer extends StatelessWidget {
  final Produit _p;
  final Widget Function(BuildContext context, Produit p, Widget child) _builder;

  const ProduitConsumer(this._p, this._builder);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Produit>.value(
      value: _p,
      child: Consumer<Produit>(builder: _builder),
    );
  }
}

class LocalActionButton extends StatelessWidget {
  final IconData _icon;
  final Function _action;

  const LocalActionButton(this._icon, this._action);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(child: Icon(_icon), onPressed: _action),
      ),
    );
  }
}
