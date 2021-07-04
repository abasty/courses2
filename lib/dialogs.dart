import 'package:flutter/material.dart';

import 'modele.dart';

class ConnectDialog extends StatelessWidget {
  const ConnectDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(child: Text('Connexion')),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            onChanged: (name) => modele.ctrlHostname('$name.eu.ngrok.io'),
            decoration: InputDecoration(hintText: 'URL'),
            initialValue: modele.hostname.contains('.eu.ngrok.io')
                ? modele.hostname.substring(0, modele.hostname.indexOf('.'))
                : modele.hostname,
          ),
        ),
        SimpleDialogItem(
          icon: Icons.cloud_done,
          color: Colors.green,
          text: 'Synchroniser les produits',
          onPressed: () {
            Navigator.pop(context);
            modele.ctrlSync('export');
          },
        ),
        SimpleDialogItem(
          icon: Icons.cloud_download,
          color: Colors.blue,
          text: 'Télécharger les produits',
          onPressed: () {
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
