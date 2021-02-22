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
          builder: (context, vm, child) {
            return ListView.builder(
              itemCount: modele.produits.length,
              itemBuilder: (context, index) {
                return ChangeNotifierProvider<Produit>.value(
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
    print(p);
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
      builder: (context, vm, child) {
        return Stack(
          children: [
            ListView.builder(
              itemCount: modele.listeSelect.length,
              itemBuilder: (context, index) {
                return ChangeNotifierProvider<Produit>.value(
                  value: modele.listeSelect[index],
                  child: Consumer<Produit>(
                    builder: _produitSelTile,
                  ),
                );
              },
            ),
            _actionButton(Icons.remove_shopping_cart, modele.ctrlValideChariot),
          ],
        );
      },
    );
  }

  Widget _produitSelTile(BuildContext context, Produit p, Widget child) {
    print(p);
    return CheckboxListTile(
      title: Text("${p.nom} ${p.quantite > 1 ? '(${p.quantite})' : ''}"),
      subtitle: Text(p.rayon.nom),
      value: p.fait,
      onChanged: (bool value) => modele.ctrlProduitPrend(p, value),
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
