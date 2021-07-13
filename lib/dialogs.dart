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
  bool _is_ngrok = false;
  String _userInfo = '';
  String _host = '';
  final _hostCtrl = TextEditingController();

  _ConnectDialogState() {
    _is_ngrok = modele.uri?.scheme == 'https';
    _userInfo = modele.uri?.userInfo ?? '';
    _host = modele.uri?.host ?? '';
    if (_is_ngrok) {
      var sep = _host.indexOf('.');
      if (sep > 0) _host = _host.substring(0, sep);
    }
    if (modele.uri?.hasPort == true) {
      var port = modele.uri?.port;
      _host = _host + ':' + port.toString();
    }
    _hostCtrl.text = _host;
  }

  Uri _computeUri() {
    String? host;
    int? port;
    var sep = _host.indexOf(':');
    if (sep != -1) {
      host = _host.substring(0, sep);
      port = int.tryParse(_host.substring(sep + 1));
    } else {
      host = _host;
    }
    if (_is_ngrok) {
      return Uri(
        scheme: 'https',
        host: host + '.eu.ngrok.io',
        userInfo: _userInfo == '' ? null : '$_userInfo',
      );
    } else {
      return Uri(
        scheme: 'http',
        host: host,
        port: port,
      );
    }
  }

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
          value: _is_ngrok,
          onChanged: (v) => setState(() => _is_ngrok = v),
        ),
        IndexedStack(
          index: _is_ngrok ? 0 : 1,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _hostCtrl,
                    decoration: InputDecoration(hintText: 'Sous-domaine ngrok'),
                    onChanged: (data) => setState(() => _host = data),
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: 'login:pass'),
                    initialValue: _userInfo,
                    onChanged: (data) => setState(() => _userInfo = data),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _hostCtrl,
                    decoration: InputDecoration(hintText: 'ip:port'),
                    onChanged: (data) => setState(() {
                      _host = data;
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _host = 'localhost:8067';
                          _hostCtrl.text = _host;
                        });
                      },
                      child: const Text('localhost:8067'),
                    ),
                  )
                ],
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
            Navigator.pop(context);
            modele.ctrlUri(_computeUri());
            modele.ctrlSync('export');
          },
        ),
        SimpleDialogItem(
          icon: Icons.cloud_download,
          color: Colors.blue,
          text: 'Télécharger les produits',
          onPressed: () {
            Navigator.pop(context);
            modele.ctrlUri(_computeUri());
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
            modele.ctrlUri(_computeUri());
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
