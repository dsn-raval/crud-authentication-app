import 'dart:io';

import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/settings/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? image1;
  bool imageChange = false;
  String Base64string = '';

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    _nameController.text = authProvider.user!.displayName!;
    _emailController.text = authProvider.user!.email!;
    return Scaffold(
      appBar: AppBar(title: Text("P R O F I L E")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profileProvider.photoUrl.isNotEmpty
                      ? NetworkImage(profileProvider.photoUrl)
                      : AssetImage("assets/avtar.png") as ImageProvider,
            ),
            SizedBox(height: 40),
            TextField(
              ignorePointers: true,
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              ignorePointers: true,
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
