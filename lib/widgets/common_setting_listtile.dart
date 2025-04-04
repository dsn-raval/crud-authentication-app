import 'package:crud_authentication_task/core/theme/app_theme_provider.dart';
import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/auth/views/signin_screen.dart';
import 'package:crud_authentication_task/modules/settings/views/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      },
      leading: CircleAvatar(
        radius: 30,
        backgroundImage:
            authProvider.profileImageUrl!.isNotEmpty
                ? NetworkImage(authProvider.profileImageUrl!)
                : const AssetImage("assets/avtar.png") as ImageProvider,
      ),
      title: Text(authProvider.user!.displayName!),
      subtitle: Text(authProvider.user!.email!),
    );
  }
}

class ThemeTile extends StatelessWidget {
  const ThemeTile();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListTile(
      leading: const Icon(Icons.light),
      title: const Text("Theme"),
      subtitle: Text(themeProvider.isDarkMode ? "Enabled" : "Disabled"),
      trailing: IconButton(
        icon: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        ),
        onPressed: () => themeProvider.toggleTheme(),
      ),
    );
  }
}

class LogoutTile extends StatelessWidget {
  const LogoutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout_rounded),
      title: const Text("Logout"),
      onTap: () async {
        await Provider.of<AuthProvider>(context, listen: false).signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SigninScreen()),
        );
      },
    );
  }
}
