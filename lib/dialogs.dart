import 'package:flutter/material.dart';

/*void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}*/

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dialog = ConnectDialog();

    return Scaffold(
      body: Center(
        // ignore: deprecated_member_use
        child: FlatButton(
          textColor: Color(0xFF6200EE),
          highlightColor: Colors.transparent,
          onPressed: () {
            var r = showDialog(context: context, builder: (context) => dialog);
            print(r);
          },
          child: Text('SHOW DIALOG'),
        ),
      ),
    );
  }
}

class ConnectDialog extends StatelessWidget {
  const ConnectDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Connexion au serveur'),
      children: [
        SimpleDialogItem(
          icon: Icons.cloud_download,
          color: Colors.green,
          text: 'Importer les données',
          onPressed: () {
            Navigator.pop(context, 'import');
          },
        ),
        SimpleDialogItem(
          icon: Icons.cloud_upload,
          color: Colors.red,
          text: 'Exporter les données',
          onPressed: () {
            Navigator.pop(context, 'export');
          },
        ),
        SimpleDialogItem(
          icon: Icons.cloud_off,
          color: Colors.red,
          text: 'Rester déconnecté',
          onPressed: () {
            Navigator.pop(context, 'disconnect');
          },
        ),
      ],
    );
  }
}

class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem(
      {Key? key, this.icon, this.color, this.text, this.onPressed})
      : super(key: key);

  final IconData? icon;
  final Color? color;
  final String? text;
  final VoidCallback? onPressed;

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
