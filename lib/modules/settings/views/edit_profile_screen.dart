import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/settings/providers/profile_provider.dart';
import 'package:crud_authentication_task/widgets/common_textfiled.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(
      text: authProvider.user?.displayName ?? '',
    );
    _emailController = TextEditingController(
      text: authProvider.user?.email ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("P R O F I L E"), centerTitle: true),
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
            CommonTextFiled(
              controller: _nameController,
              isEnable: true,
              labelText: "Name",
            ),
            SizedBox(height: 30),
            CommonTextFiled(
              controller: _emailController,
              isEnable: true,
              labelText: "Email",
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
