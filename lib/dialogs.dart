import 'package:flutter/material.dart';

import 'modele.dart';

class ConnectDialog extends StatefulWidget {
  const ConnectDialog({
    Key? key,
  }) : super(key: key);

  @override
  _ConnectDialogState createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  // TODO: Get values from modele / prefs
  bool _isNgrok = false;
  String _subDomain = '';
  String _user = '';
  String _password = '';
  String _ip = '127.0.0.1:8067';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(child: Text('Connexion')),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      children: [
        SwitchListTile(
          title: Text('Connexion Sécurisée'),
          subtitle: Text('HTTP/LAN ou HTTPS/ngrok'),
          value: _isNgrok,
          onChanged: (v) => setState(() => _isNgrok = v),
        ),
        IndexedStack(
          index: _isNgrok ? 0 : 1,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(hintText: 'Utilisateur'),
                    initialValue: _user,
                    onChanged: (name) => setState(() => _user = name),
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: 'Mot de passe'),
                    initialValue: _password,
                    onChanged: (name) => setState(() => _password = name),
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: 'Sous-domaine ngrok'),
                    initialValue: _subDomain,
                    onChanged: (name) => setState(() => _subDomain = name),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                decoration: InputDecoration(hintText: 'HTTP ip:port'),
                initialValue: _ip,
                onChanged: (name) => setState(() => _ip = name),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Divider(),
        ),
        SimpleDialogItem(
          icon: Icons.cloud_done,
          color: Colors.green,
          text: 'Synchroniser les produits',
          onPressed: () {
            // TODO: Set values into modele / prefs
            Navigator.pop(context);
            modele.ctrlSync('export');
          },
        ),
        SimpleDialogItem(
          icon: Icons.cloud_download,
          color: Colors.blue,
          text: 'Télécharger les produits',
          onPressed: () {
            // TODO: Set values into modele / prefs
            Navigator.pop(context);
            modele.ctrlSync('import');
          },
        ),
        Divider(),
        SimpleDialogItem(
          icon: Icons.cloud_off,
          color: Colors.red,
          text: 'Rester déconnecté',
          onPressed: () {
            // TODO: Set values into modele / prefs
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class SimpleDialogItem extends StatelessWidget {
  final IconData? icon;

  final Color? color;
  final String? text;
  final VoidCallback? onPressed;
  const SimpleDialogItem(
      {Key? key, this.icon, this.color, this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text!),
          ),
        ],
      ),
    );
  }
}
