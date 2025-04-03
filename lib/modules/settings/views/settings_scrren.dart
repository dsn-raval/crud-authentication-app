import 'package:crud_authentication_task/core/theme/app_theme_provider.dart';
import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/auth/views/signin_screen.dart';
import 'package:crud_authentication_task/modules/settings/views/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("S E T T I N G S"), centerTitle: true),
      body: Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            leading: CircleAvatar(
              radius: 30,
              backgroundImage:
                  (authProvider.profileImageUrl != "" &&
                          authProvider.profileImageUrl != null)
                      ? NetworkImage(authProvider.profileImageUrl!)
                      : AssetImage("assets/avtar.png"),
            ),
            title: Text(authProvider.user?.displayName ?? "User"),
            subtitle: Text(authProvider.user?.email ?? ""),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.light),
            title: Text("Theme"),
            subtitle: Text(
              "${themeProvider.isDarkMode ? 'Enabled' : 'Disabled'}",
            ),
            trailing: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text("Logout"),
            onTap: () async {
              await authProvider.signOut();
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SigninScreen()),
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
