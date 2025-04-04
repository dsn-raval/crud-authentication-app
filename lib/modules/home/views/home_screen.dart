import 'dart:convert';
import 'dart:io';

import 'package:crud_authentication_task/core/constant/app_color.dart';
import 'package:crud_authentication_task/modules/home/providers/api_provider.dart';
import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/settings/views/settings_scrren.dart';
import 'package:crud_authentication_task/widgets/common_image_pickup.dart';
import 'package:crud_authentication_task/widgets/common_textfiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  String Base64String = "";
  String imagePath = "";
  File? selectedImage;

  Future<void> getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);

      if (image == null) return;

      imagePath = image.path;
      selectedImage = File(image.path);

      setState(() {
        Base64String = base64Encode(selectedImage!.readAsBytesSync());
      });
    } on PlatformException catch (e) {
      throw Text(e.toString());
    }
  }

  @override
  void initState() {
    Future.microtask(() {
      Provider.of<ApiProvider>(context, listen: false).fetchData();
      Provider.of<AuthProvider>(context, listen: false).fetchUserRole();
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAdmin = authProvider.role == "admin";
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: Text("H O M E", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body:
          apiProvider.datas.isEmpty
              ? Center(child: Text("No data..."))
              : Consumer<ApiProvider>(
                builder: (context, api, child) {
                  return ListView.builder(
                    itemCount: api.datas.length,
                    itemBuilder: (context, index) {
                      var data = api.datas[index];
                      final imageUrl = data['image'] ?? "";
                      return Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Card(
                          color: Colors.white,
                          child: ListTile(
                            leading:
                                imageUrl.isNotEmpty
                                    ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: FileImage(
                                        File(imageUrl),
                                      ),
                                      onBackgroundImageError:
                                          (_, __) => Icon(Icons.broken_image),
                                    )
                                    : Icon(Icons.image_not_supported),
                            title: Text(
                              data["title"],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(data["body"]),
                            trailing:
                                isAdmin
                                    ? _buildAdminActions(apiProvider, data)
                                    : null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: IgnorePointer(
        ignoring: !isAdmin,
        child: Opacity(
          opacity: isAdmin ? 1 : 0.5,
          child: FloatingActionButton(
            backgroundColor: CColor.primaryColor,
            onPressed:
                () => _showDataDialog(context, "Add", "Create Data", () async {
                  await apiProvider.addData(
                    _titleController.text,
                    _subtitleController.text,
                    imagePath,
                  );
                  _clearForm();
                }),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminActions(ApiProvider apiProvider, Map data) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.edit,
          color: Colors.indigo,
          onTap: () {
            _titleController.text = data["title"];
            _subtitleController.text = data["body"];
            imagePath = data["image"];
            _showDataDialog(context, "Update", "Update Data", () async {
              await apiProvider.updateData(
                data["id"],
                _titleController.text,
                _subtitleController.text,
                imagePath,
              );
              _clearForm();
            });
          },
        ),
        SizedBox(width: 10),
        _actionButton(
          icon: Icons.delete,
          color: Colors.red,
          onTap: () async {
            await apiProvider.deleteData(data["id"]);
            apiProvider.fetchData();
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 20,
      child: InkWell(onTap: onTap, child: Icon(icon, color: Colors.white)),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _subtitleController.clear();
    imagePath = '';
  }

  void _showDataDialog(
    BuildContext context,
    String actionText,
    String dialogTitle,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => PopScope(
            canPop: false,
            child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(dialogTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => ImagePickPopup(
                                  cameraOnTap: () async {
                                    await getImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                  galleryOnTap: () async {
                                    await getImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        child:
                            imagePath.isEmpty
                                ? CircleAvatar(
                                  radius: 35,
                                  child: Icon(Icons.add_a_photo_outlined),
                                )
                                : CircleAvatar(
                                  radius: 35,
                                  backgroundImage: FileImage(File(imagePath)),
                                ),
                      ),
                      SizedBox(height: 10),
                      _buildTextField(_titleController, "Title"),
                      SizedBox(height: 10),
                      _buildTextField(_subtitleController, "Subtitle"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearForm();
                      },
                      child: Text("Cancel"),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context);
                      },
                      child: Text(actionText),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return CommonTextFiled(
      controller: controller,
      isEnable: false,
      labelText: label,
    );
  }
}
