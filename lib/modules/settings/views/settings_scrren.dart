import 'package:crud_authentication_task/widgets/common_setting_listtile.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("S E T T I N G S"), centerTitle: true),
      body: Column(
        children: [
          ProfileTile(),
          Divider(),
          ThemeTile(),
          Divider(),
          LogoutTile(),
          Divider(),
        ],
      ),
    );
  }
}
